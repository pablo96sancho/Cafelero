//
//  CafeleroApp.swift
//  Cafelero
//
//  Punto de entrada de la aplicación. Es una MenuBarExtra pura de SwiftUI,
//  sin ventana principal ni icono en el Dock (ver Info.plist -> LSUIElement).
//

import SwiftUI

@main
struct CafeleroApp: App {

    // NSApplicationDelegateAdaptor nos permite engancharnos al ciclo de vida
    // de AppKit si en el futuro necesitamos algo que SwiftUI no cubre
    // (por ejemplo, gestionar el inicio automático con SMAppService).
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var antiSleepManager = AntiSleepManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(antiSleepManager)
        } label: {
            // El icono cambia dinámicamente según el estado activo/inactivo.
            Image(systemName: antiSleepManager.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                .environmentObject(antiSleepManager)
        }
        .menuBarExtraStyle(.window) // .window nos da un popover en lugar de un menú de lista
    }
}

/// AppDelegate mínimo. Se usa sobre todo para asegurarnos de que la app
/// se comporta como "agent app" también a nivel de AppKit (sin activarse
/// en el Dock ni robar el foco) y como punto de extensión futuro.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
