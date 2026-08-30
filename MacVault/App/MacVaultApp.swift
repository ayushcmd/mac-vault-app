import SwiftUI

/// Main entry point for MacVault.
/// Runs as a menu bar app with a shield icon.
@main
struct MacVaultApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage(FGConstants.setupCompletedKey) private var setupCompleted = false
    @State private var showSetup = false

    var body: some Scene {
        // Menu bar extra — the primary UI.
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(FGConstants.menuBarIcon)
        }
        .menuBarExtraStyle(.window)
    }
}
