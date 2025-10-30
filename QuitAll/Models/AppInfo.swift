//
//  AppInfo.swift
//  QuitAll
//
//  Model representing a running application
//  See SPEC-001: Application Architecture Overview
//

import Foundation
import AppKit

/// Represents information about a running application
struct AppInfo: Identifiable, Hashable {
    /// Unique identifier for SwiftUI list
    let id: UUID

    /// Bundle identifier (e.g., com.apple.Safari)
    let bundleIdentifier: String

    /// Display name of the application
    let name: String

    /// Application icon
    let icon: NSImage

    /// Reference to the underlying NSRunningApplication
    /// Note: This is not Hashable, so we exclude it from hash/equality
    let nsRunningApp: NSRunningApplication

    // MARK: - Initialization

    /// Initialize from NSRunningApplication
    /// - Parameter runningApp: The NSRunningApplication to extract info from
    init?(from runningApp: NSRunningApplication) {
        // Bundle identifier is required
        guard let bundleID = runningApp.bundleIdentifier else {
            return nil
        }

        self.id = UUID()
        self.bundleIdentifier = bundleID

        // Get localized name, fallback to bundle identifier
        self.name = runningApp.localizedName ?? bundleID

        // Get icon, fallback to default app icon
        if let icon = runningApp.icon {
            self.icon = icon
        } else {
            // Fallback to generic app icon
            self.icon = NSImage(systemSymbolName: "app", accessibilityDescription: "App Icon")
                ?? NSWorkspace.shared.icon(forFile: "/System/Applications/Finder.app")
        }

        self.nsRunningApp = runningApp
    }

    // MARK: - Hashable & Equatable

    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }

    // MARK: - Computed Properties

    /// Whether this app is currently running (process might have quit)
    var isRunning: Bool {
        nsRunningApp.isTerminated == false
    }

    /// Process identifier
    var processIdentifier: pid_t {
        nsRunningApp.processIdentifier
    }

    /// Whether this is a regular GUI application
    var isRegularApp: Bool {
        nsRunningApp.activationPolicy == .regular
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension AppInfo {
    /// Creates a mock AppInfo for SwiftUI previews
    static func mock(
        bundleIdentifier: String = "com.example.TestApp",
        name: String = "Test App",
        icon: NSImage? = nil
    ) -> AppInfo? {
        // This won't work in previews since NSRunningApplication requires a real process
        // Instead, we'll need to create mock data differently
        return nil
    }
}
#endif
