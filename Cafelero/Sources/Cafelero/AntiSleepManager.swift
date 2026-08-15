//
//  AntiSleepManager.swift
//  Cafelero
//
//  Encapsula toda la lógica de anti-reposo:
//   1) Mecanismo nativo con IOKit (IOPMAssertionCreateWithName).
//   2) Mecanismo de respaldo opcional simulando una pulsación de tecla
//      "neutra" (F15) mediante CGEvent cada 59 segundos.
//

import Foundation
import IOKit.pwr_mgt
import CoreGraphics
import Combine
import ServiceManagement

/// Duraciones disponibles en el selector del popover.
enum SleepDuration: CaseIterable, Identifiable {
    case indefinite
    case min15
    case min30
    case min45
    case hour1
    case hour4
    case hour8
    case hour12

    var id: Self { self }

    /// Etiqueta corta que se muestra en la "pill" del selector.
    var label: String {
        switch self {
        case .indefinite: return "∞"
        case .min15: return "15 min"
        case .min30: return "30 min"
        case .min45: return "45 min"
        case .hour1: return "1 hora"
        case .hour4: return "4 horas"
        case .hour8: return "8 horas"
        case .hour12: return "12 horas"
        }
    }

    /// Duración en segundos. `nil` significa indefinido.
    var seconds: TimeInterval? {
        switch self {
        case .indefinite: return nil
        case .min15: return 15 * 60
        case .min30: return 30 * 60
        case .min45: return 45 * 60
        case .hour1: return 60 * 60
        case .hour4: return 4 * 60 * 60
        case .hour8: return 8 * 60 * 60
        case .hour12: return 12 * 60 * 60
        }
    }
}

/// Gestiona el estado de "no dormir" del Mac y expone propiedades
/// observables para que la interfaz (MenuBarView) se actualice sola.
@MainActor
final class AntiSleepManager: ObservableObject {

    // MARK: - Estado publicado hacia la UI

    @Published private(set) var isActive: Bool = false
    @Published var selectedDuration: SleepDuration = .indefinite
    @Published private(set) var activeUntil: Date? = nil

    /// Si está a `true`, además de la IOPMAssertion se simula una pulsación
    /// de tecla neutra cada 59s como mecanismo de respaldo. Configurable
    /// desde el panel de Configuración.
    @Published var useKeystrokeFallback: Bool = false

    @Published var launchAtLogin: Bool = false {
        didSet { updateLaunchAtLogin() }
    }

    // MARK: - Estado interno

    /// ID de la assertion de IOKit. `0` cuando no hay ninguna activa.
    private var assertionID: IOPMAssertionID = 0

    /// Timer que apaga automáticamente el modo anti-reposo al cumplirse
    /// la duración seleccionada.
    private var durationTimer: Timer?

    /// Timer de respaldo que simula la pulsación de tecla cada 59s.
    private var keystrokeTimer: Timer?

    /// Refresca el texto "Activo hasta las HH:MM" cada segundo mientras
    /// el modo esté activo con duración definida.
    private var uiRefreshTimer: Timer?

    // MARK: - Formateo de hora para la UI

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()

    init() {
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
    }

    deinit {
        durationTimer?.invalidate()
        keystrokeTimer?.invalidate()
        uiRefreshTimer?.invalidate()
    }

    // MARK: - Toggle principal

    /// Activa o desactiva el modo anti-reposo respetando la duración
    /// seleccionada en `selectedDuration`.
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate(duration: selectedDuration)
        }
    }

    /// Activa el modo anti-reposo con una duración concreta. Si se llama
    /// mientras ya está activo, reinicia el temporizador con la nueva
    /// duración (permite cambiar de "30 min" a "1 hora" sobre la marcha).
    func activate(duration: SleepDuration) {
        selectedDuration = duration

        if assertionID == 0 {
            createAssertion()
        }

        isActive = true

        durationTimer?.invalidate()
        durationTimer = nil
        activeUntil = nil

        if let seconds = duration.seconds {
            let endDate = Date().addingTimeInterval(seconds)
            activeUntil = endDate

            durationTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.deactivate()
                }
            }
        }

        if useKeystrokeFallback {
            startKeystrokeFallback()
        }

        startUIRefreshTimer()
    }

    /// Desactiva el modo anti-reposo y limpia todos los timers/assertions.
    func deactivate() {
        releaseAssertion()
        stopKeystrokeFallback()

        durationTimer?.invalidate()
        durationTimer = nil

        uiRefreshTimer?.invalidate()
        uiRefreshTimer = nil

        isActive = false
        activeUntil = nil
    }

    /// Cambia la duración seleccionada. Si el modo ya está activo,
    /// reprograma el apagado automático con la nueva duración.
    func selectDuration(_ duration: SleepDuration) {
        selectedDuration = duration
        if isActive {
            activate(duration: duration)
        }
    }

    // MARK: - Texto de estado para la UI

    var statusText: String {
        guard isActive else { return "Inactivo" }
        guard let until = activeUntil else { return "Activo indefinidamente" }
        return "Activo hasta las \(timeFormatter.string(from: until))"
    }

    // MARK: - IOKit: mecanismo nativo anti-reposo

    private func createAssertion() {
        // Combinamos no-idle-sleep (no dormir el sistema) con
        // no-display-sleep (no apagar la pantalla), que es el
        // comportamiento esperado de una app tipo "Amphetamine".
        let reason = "Cafelero mantiene el Mac despierto" as CFString

        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &id
        )

        if result == kIOReturnSuccess {
            assertionID = id
        } else {
            print("⚠️ Cafelero: no se pudo crear la IOPMAssertion (código \(result)).")
        }
    }

    private func releaseAssertion() {
        guard assertionID != 0 else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
    }

    // MARK: - Respaldo: simulación de pulsación de tecla (F15)

    /// Envía una pulsación "invisible" de F15 mediante CGEvent. F15 no
    /// tiene ninguna acción por defecto en macOS, por lo que resulta
    /// neutra para el usuario pero cuenta como actividad para el sistema.
    private func simulateNeutralKeystroke() {
        let keyCode: CGKeyCode = 0x71 // F15

        guard let source = CGEventSource(stateID: .hidSystemState) else { return }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private func startKeystrokeFallback() {
        keystrokeTimer?.invalidate()
        keystrokeTimer = Timer.scheduledTimer(withTimeInterval: 59, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.simulateNeutralKeystroke()
            }
        }
    }

    private func stopKeystrokeFallback() {
        keystrokeTimer?.invalidate()
        keystrokeTimer = nil
    }

    // MARK: - Refresco de UI

    private func startUIRefreshTimer() {
        uiRefreshTimer?.invalidate()
        uiRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                // Simplemente forzamos un refresco de la vista;
                // `objectWillChange` se dispara al tocar @Published,
                // así que reasignamos activeUntil a sí mismo.
                self?.objectWillChange.send()
            }
        }
    }

    // MARK: - Inicio automático al arrancar el Mac

    private func updateLaunchAtLogin() {
        do {
            if launchAtLogin {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            print("⚠️ Cafelero: error al configurar el inicio automático: \(error)")
        }
    }
}
