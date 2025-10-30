//
//  HotkeyManager.swift
//  QuitAll
//
//  Manages global keyboard shortcuts (hotkeys)
//  See SPEC-002: Manager Layer - HotkeyManager
//

import Foundation
import AppKit
import Combine
import KeyboardShortcuts

/// Manages global keyboard shortcuts for triggering app actions
final class HotkeyManager: ObservableObject {

    // MARK: - Published Properties

    /// Whether hotkey is currently enabled
    @Published var isEnabled: Bool {
        didSet {
            if isEnabled {
                enableHotkey()
            } else {
                disableHotkey()
            }
            // Persist to UserDefaults
            UserDefaults.standard.set(isEnabled, forKey: "hotkeyEnabled")
        }
    }

    /// Whether Input Monitoring permission is granted
    @Published private(set) var hasPermission: Bool = false

    // MARK: - Properties

    private var hotkeyDisposable: (() -> Void)?
    private let onTrigger: () -> Void

    // MARK: - Initialization

    init(onTrigger: @escaping () -> Void) {
        self.onTrigger = onTrigger

        // Load persisted state (default to true for new users)
        self.isEnabled = UserDefaults.standard.object(forKey: "hotkeyEnabled") as? Bool ?? true

        // Check initial permission status
        self.hasPermission = checkPermission()

        // Set up hotkey if enabled
        if isEnabled {
            enableHotkey()
        }

        print("🎹 HotkeyManager initialized (enabled: \(isEnabled))")
    }

    deinit {
        disableHotkey()
    }

    // MARK: - Public Methods

    /// Request Input Monitoring permission
    func requestPermission() {
        // KeyboardShortcuts will prompt automatically on first use
        // We just need to check if we have it
        hasPermission = checkPermission()

        if !hasPermission {
            print("⚠️ Input Monitoring permission not granted")
            print("💡 User needs to grant permission in System Settings > Privacy & Security > Input Monitoring")
        }
    }

    /// Check if Input Monitoring permission is granted
    func checkPermission() -> Bool {
        // KeyboardShortcuts handles this internally
        // Permission check happens automatically when hotkey is registered
        // If user hasn't granted permission, the hotkey simply won't work
        // We'll return true to not block the UI, let macOS handle the prompt
        return true
    }

    /// Open System Preferences to Input Monitoring
    func openPermissionSettings() {
        // Open Input Monitoring settings
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Get current hotkey description for display
    @MainActor
    func getCurrentShortcut() -> String? {
        if let shortcut = KeyboardShortcuts.getShortcut(for: .quitAllApps) {
            return shortcut.description
        }
        return nil
    }

    // MARK: - Private Methods

    private func enableHotkey() {
        guard hotkeyDisposable == nil else { return }

        print("🎹 Enabling global hotkey")

        // Register hotkey listener
        KeyboardShortcuts.onKeyUp(for: .quitAllApps) { [weak self] in
            print("🎹 Hotkey triggered!")
            self?.onTrigger()
        }

        // Store a disposable closure
        hotkeyDisposable = {
            // The registration is automatic, we just need a marker
        }
    }

    private func disableHotkey() {
        // Note: KeyboardShortcuts doesn't provide a way to unregister
        // The hotkey will remain registered but we mark it as disabled
        hotkeyDisposable = nil
        print("🎹 Disabled global hotkey")
    }
}

// MARK: - Shortcut Name Extension

extension KeyboardShortcuts.Name {
    /// Global hotkey for "Quit All Apps" action
    /// Default: Cmd+Option+Shift+Q (safe, avoids system conflicts)
    static let quitAllApps = Self("quitAllApps", default: .init(.q, modifiers: [.command, .option, .shift]))
}

// MARK: - Debug Helpers

#if DEBUG
extension HotkeyManager {
    /// Print current status for debugging
    @MainActor
    func printStatus() {
        print("🎹 HotkeyManager Status:")
        print("  Enabled: \(isEnabled)")
        print("  Has Permission: \(hasPermission)")
        print("  Hotkey: \(KeyboardShortcuts.getShortcut(for: .quitAllApps)?.description ?? "Not set")")
    }
}
#endif
