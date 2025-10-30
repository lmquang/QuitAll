//
//  SystemProtection.swift
//  QuitAll
//
//  System app protection and safety checks
//  See SPEC-002: Manager Layer - SystemProtection
//

import Foundation
import AppKit

/// Provides safety checks to prevent quitting critical system apps
final class SystemProtection {

    // MARK: - Critical Apps Blacklist

    /// Bundle identifiers that should NEVER be quit
    /// These are essential macOS system processes
    private static let criticalBundleIdentifiers: Set<String> = [
        // Core System
        "com.apple.finder",              // Finder - file management
        "com.apple.dock",                // Dock - app launcher
        "com.apple.systemuiserver",      // System UI (menu bar extras)
        "com.apple.WindowServer",        // Window management
        "com.apple.loginwindow",         // Login window

        // QuitAll itself
        "dwr.QuitAll",                   // This app - never quit self!
        "com.yourcompany.QuitAll",       // Alternative bundle ID

        // Critical Background Services
        "com.apple.CoreServices.UIAgent",
        "com.apple.notificationcenterui",
        "com.apple.controlcenter",
    ]

    /// Bundle ID prefixes that indicate system apps
    private static let systemBundleIDPrefixes: [String] = [
        "com.apple.AmbientDisplayAgent",
        "com.apple.security.",
        "com.apple.Safari.SafeBrowsing",
    ]

    // MARK: - Public Safety Checks

    /// Check if an app can be safely quit
    /// - Parameter app: The NSRunningApplication to check
    /// - Returns: true if safe to quit, false if protected
    static func canQuit(_ app: NSRunningApplication) -> Bool {
        // Check bundle identifier
        guard let bundleID = app.bundleIdentifier else {
            // No bundle ID = likely a system process, don't quit
            return false
        }

        // Check critical blacklist
        if criticalBundleIdentifiers.contains(bundleID) {
            return false
        }

        // Check system bundle ID patterns
        for prefix in systemBundleIDPrefixes {
            if bundleID.hasPrefix(prefix) {
                return false
            }
        }

        // Check if it's a background-only app (daemon/agent)
        if app.activationPolicy != .regular {
            // Not a regular GUI app - don't quit
            return false
        }

        // Safe to quit
        return true
    }

    /// Check if a bundle identifier is protected
    /// - Parameter bundleID: The bundle identifier to check
    /// - Returns: true if protected, false if can be quit
    static func isProtected(bundleID: String) -> Bool {
        // Check critical blacklist
        if criticalBundleIdentifiers.contains(bundleID) {
            return true
        }

        // Check system bundle ID patterns
        for prefix in systemBundleIDPrefixes {
            if bundleID.hasPrefix(prefix) {
                return true
            }
        }

        return false
    }

    /// Check if this is QuitAll itself
    /// - Parameter bundleID: The bundle identifier to check
    /// - Returns: true if this is QuitAll
    static func isSelf(bundleID: String) -> Bool {
        guard let ownBundleID = Bundle.main.bundleIdentifier else {
            return false
        }
        return bundleID == ownBundleID
    }

    /// Get human-readable reason why an app is protected
    /// - Parameter bundleID: The bundle identifier
    /// - Returns: Reason string, or nil if not protected
    static func protectionReason(for bundleID: String) -> String? {
        if isSelf(bundleID: bundleID) {
            return "QuitAll cannot quit itself"
        }

        if bundleID == "com.apple.finder" {
            return "Finder is essential to macOS"
        }

        if bundleID == "com.apple.dock" {
            return "Dock is essential to macOS"
        }

        if criticalBundleIdentifiers.contains(bundleID) {
            return "Critical system component"
        }

        for prefix in systemBundleIDPrefixes {
            if bundleID.hasPrefix(prefix) {
                return "System service"
            }
        }

        return nil
    }

    // MARK: - Validation

    /// Validate that critical system protection is working
    /// Used for debugging and testing
    static func validateProtection() -> Bool {
        // Check that Finder is protected
        guard isProtected(bundleID: "com.apple.finder") else {
            print("❌ SystemProtection FAILED: Finder not protected!")
            return false
        }

        // Check that Dock is protected
        guard isProtected(bundleID: "com.apple.dock") else {
            print("❌ SystemProtection FAILED: Dock not protected!")
            return false
        }

        // Check that self is protected
        if let ownBundleID = Bundle.main.bundleIdentifier {
            guard isProtected(bundleID: ownBundleID) else {
                print("❌ SystemProtection FAILED: QuitAll not protected!")
                return false
            }
        }

        print("✅ SystemProtection validation passed")
        return true
    }
}
