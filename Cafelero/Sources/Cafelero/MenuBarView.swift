//
//  MenuBarView.swift
//  Cafelero
//
//  Vista SwiftUI que se muestra al hacer clic en el icono de la barra
//  de menú. Contiene el toggle principal, el selector de duración,
//  la configuración y las acciones inferiores.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var manager: AntiSleepManager
    @State private var showingSettings = false
    @State private var showingAbout = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            header

            Divider()

            durationPicker

            Divider()

            footerActions
        }
        .padding(16)
        .frame(width: 280)
    }

    // MARK: - Cabecera: icono + toggle + estado

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: manager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                    .font(.system(size: 22))
                    .foregroundStyle(manager.isActive ? .brown : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cafelero")
                        .font(.headline)
                    Text(manager.statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { manager.isActive },
                    set: { _ in manager.toggle() }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }
        }
    }

    // MARK: - Selector de duración (pills)

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duración")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Distribuido en dos filas de "pills" para que quepan bien
            // las 8 opciones dentro del ancho del popover.
            let columns = [GridItem(.adaptive(minimum: 58), spacing: 8)]

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(SleepDuration.allCases) { duration in
                    durationPill(duration)
                }
            }
        }
    }

    private func durationPill(_ duration: SleepDuration) -> some View {
        let isSelected = manager.selectedDuration == duration

        return Button {
            manager.selectDuration(duration)
        } label: {
            Text(duration.label)
                .font(.caption)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Acciones inferiores

    private var footerActions: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                showingSettings.toggle()
            } label: {
                Label("Configuración", systemImage: "gearshape")
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingSettings, arrowEdge: .trailing) {
                SettingsView()
                    .environmentObject(manager)
            }

            Button {
                showingAbout.toggle()
            } label: {
                Label("Acerca de", systemImage: "info.circle")
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingAbout, arrowEdge: .trailing) {
                AboutView()
            }

            Divider()
                .padding(.vertical, 4)

            Button(role: .destructive) {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Salir", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Vista de Configuración

private struct SettingsView: View {
    @EnvironmentObject private var manager: AntiSleepManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuración")
                .font(.headline)

            Toggle("Iniciar Cafelero al arrancar el Mac", isOn: $manager.launchAtLogin)
                .toggleStyle(.switch)

            Toggle("Usar respaldo de tecla neutra (F15)", isOn: $manager.useKeystrokeFallback)
                .toggleStyle(.switch)

            Text("El respaldo simula una pulsación de F15 cada 59 segundos además de la assertion de IOKit. Solo necesario en entornos donde la assertion nativa no sea suficiente.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(width: 260)
    }
}

// MARK: - Vista Acerca de

private struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 32))
                .foregroundStyle(.brown)
            Text("Cafelero")
                .font(.headline)
            Text("Versión 1.0")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Mantiene tu Mac despierto, a tu manera.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(width: 220)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AntiSleepManager())
}
