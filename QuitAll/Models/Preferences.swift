//
//  Preferences.swift
//  QuitAll
//
//  User preferences model
//  See SPEC-002: Manager Layer - PreferencesManager
//

import Foundation

/// User preferences for QuitAll
struct Preferences: Codable {
    /// Whether to show confirmation dialog before quitting all apps
    var showConfirmation: Bool

    /// Whether to launch QuitAll at login
    var launchAtLogin: Bool

    /// Default preferences
    static let `default` = Preferences(
        showConfirmation: true,  // Default to safe option
        launchAtLogin: false
    )

    init(showConfirmation: Bool = true, launchAtLogin: Bool = false) {
        self.showConfirmation = showConfirmation
        self.launchAtLogin = launchAtLogin
    }
}
