//
//  QuitAllApp.swift
//  QuitAll
//
//  Main app entry point
//  See ADR-006: Menu Bar App Lifecycle
//

import SwiftUI

@main
struct QuitAllApp: App {
    // Use AppDelegate for AppKit integration
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty scene - we're menu bar only
        // The AppDelegate handles all UI via NSStatusItem and NSPopover
        Settings {
            EmptyView()
        }
    }
}
