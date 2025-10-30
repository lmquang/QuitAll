//
//  PreferencesManager.swift
//  QuitAll
//
//  Manages user preferences with UserDefaults persistence
//  See SPEC-002: Manager Layer - PreferencesManager
//

import Foundation
import Combine
import ServiceManagement

/// Manages application preferences
final class PreferencesManager: ObservableObject {

    // MARK: - Published Properties

    @Published var showConfirmation: Bool {
        didSet {
            defaults.set(showConfirmation, forKey: Keys.showConfirmation)
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            updateLaunchAtLogin()
        }
    }

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let showConfirmation = "showConfirmation"
        static let launchAtLogin = "launchAtLogin"
    }

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Load saved preferences or use defaults
        self.showConfirmation = defaults.bool(forKey: Keys.showConfirmation, default: true)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin, default: false)

        // Validate launch at login state on init
        validateLaunchAtLoginState()
    }

    // MARK: - Public Methods

    /// Reset all preferences to defaults
    func resetToDefaults() {
        showConfirmation = true
        launchAtLogin = false
    }

    /// Export preferences as dictionary (for backup/restore)
    func exportPreferences() -> [String: Any] {
        [
            Keys.showConfirmation: showConfirmation,
            Keys.launchAtLogin: launchAtLogin
        ]
    }

    /// Import preferences from dictionary
    func importPreferences(_ dict: [String: Any]) {
        if let showConfirm = dict[Keys.showConfirmation] as? Bool {
            showConfirmation = showConfirm
        }

        if let launchAtLogin = dict[Keys.launchAtLogin] as? Bool {
            self.launchAtLogin = launchAtLogin
        }
    }

    // MARK: - Launch at Login

    @available(macOS 13.0, *)
    private func updateLaunchAtLogin() {
        Task {
            do {
                if launchAtLogin {
                    // Register login item
                    try SMAppService.mainApp.register()
                    print("✅ Registered as login item")
                } else {
                    // Unregister login item
                    try SMAppService.mainApp.unregister()
                    print("✅ Unregistered as login item")
                }

                // Save preference
                defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            } catch {
                print("❌ Failed to update launch at login: \(error)")
                // Revert the toggle on failure
                DispatchQueue.main.async {
                    self.launchAtLogin = !self.launchAtLogin
                }
            }
        }
    }

    @available(macOS 13.0, *)
    private func validateLaunchAtLoginState() {
        Task {
            let status = SMAppService.mainApp.status
            let isEnabled = (status == .enabled)

            // Sync UI state with actual system state
            if isEnabled != launchAtLogin {
                DispatchQueue.main.async {
                    self.launchAtLogin = isEnabled
                }
            }
        }
    }
}

// MARK: - UserDefaults Extension

private extension UserDefaults {
    /// Get bool with default value if key doesn't exist
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}
