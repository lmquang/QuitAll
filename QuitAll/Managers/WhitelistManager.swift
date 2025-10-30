//
//  WhitelistManager.swift
//  QuitAll
//
//  Manages temporary and persistent whitelist for apps
//  See SPEC-002: Manager Layer - WhitelistManager
//

import Foundation
import Combine

/// Manages application whitelist (both temporary and persistent)
final class WhitelistManager: ObservableObject {

    // MARK: - Published Properties

    /// Temporary whitelist - cleared when app restarts
    @Published private(set) var temporaryWhitelist: Set<String> = []

    /// Persistent whitelist - saved to UserDefaults
    @Published private(set) var persistentWhitelist: Set<String> = []

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private let systemProtection = SystemProtection.self

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let persistentWhitelist = "persistentWhitelist"
    }

    // MARK: - Initialization

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Load persistent whitelist from UserDefaults
        loadPersistentWhitelist()

        // Add system-protected apps to persistent whitelist automatically
        addSystemProtectedApps()
    }

    // MARK: - Query Methods

    /// Check if an app is whitelisted (either temporary or persistent)
    /// - Parameter bundleID: Bundle identifier to check
    /// - Returns: true if whitelisted
    func isWhitelisted(bundleID: String) -> Bool {
        temporaryWhitelist.contains(bundleID) || persistentWhitelist.contains(bundleID)
    }

    /// Check if an app is in temporary whitelist
    /// - Parameter bundleID: Bundle identifier to check
    /// - Returns: true if in temporary whitelist
    func isTemporarilyWhitelisted(bundleID: String) -> Bool {
        temporaryWhitelist.contains(bundleID)
    }

    /// Check if an app is in persistent whitelist
    /// - Parameter bundleID: Bundle identifier to check
    /// - Returns: true if in persistent whitelist
    func isPersistentlyWhitelisted(bundleID: String) -> Bool {
        persistentWhitelist.contains(bundleID)
    }

    /// Check if an app is system-protected (cannot be removed from whitelist)
    /// - Parameter bundleID: Bundle identifier to check
    /// - Returns: true if system-protected
    func isSystemProtected(bundleID: String) -> Bool {
        systemProtection.isProtected(bundleID: bundleID)
    }

    // MARK: - Temporary Whitelist Operations

    /// Add app to temporary whitelist
    /// - Parameter bundleID: Bundle identifier to add
    func addToTemporary(bundleID: String) {
        temporaryWhitelist.insert(bundleID)
    }

    /// Remove app from temporary whitelist
    /// - Parameter bundleID: Bundle identifier to remove
    func removeFromTemporary(bundleID: String) {
        temporaryWhitelist.remove(bundleID)
    }

    /// Toggle temporary whitelist status
    /// - Parameter bundleID: Bundle identifier to toggle
    func toggleTemporary(bundleID: String) {
        if temporaryWhitelist.contains(bundleID) {
            removeFromTemporary(bundleID: bundleID)
        } else {
            addToTemporary(bundleID: bundleID)
        }
    }

    /// Clear all temporary whitelist entries
    func clearTemporary() {
        temporaryWhitelist.removeAll()
    }

    // MARK: - Persistent Whitelist Operations

    /// Add app to persistent whitelist
    /// - Parameter bundleID: Bundle identifier to add
    func addToPersistent(bundleID: String) {
        persistentWhitelist.insert(bundleID)
        savePersistentWhitelist()
    }

    /// Remove app from persistent whitelist
    /// - Parameter bundleID: Bundle identifier to remove
    /// - Returns: true if removed, false if system-protected
    @discardableResult
    func removeFromPersistent(bundleID: String) -> Bool {
        // Cannot remove system-protected apps
        guard !systemProtection.isProtected(bundleID: bundleID) else {
            print("⚠️ Cannot remove system-protected app: \(bundleID)")
            return false
        }

        persistentWhitelist.remove(bundleID)
        savePersistentWhitelist()
        return true
    }

    /// Toggle persistent whitelist status
    /// - Parameter bundleID: Bundle identifier to toggle
    func togglePersistent(bundleID: String) {
        if persistentWhitelist.contains(bundleID) {
            removeFromPersistent(bundleID: bundleID)
        } else {
            addToPersistent(bundleID: bundleID)
        }
    }

    /// Clear all non-protected persistent whitelist entries
    func clearPersistent() {
        // Keep only system-protected apps
        persistentWhitelist = persistentWhitelist.filter { bundleID in
            systemProtection.isProtected(bundleID: bundleID)
        }
        savePersistentWhitelist()
    }

    // MARK: - Batch Operations

    /// Add multiple apps to temporary whitelist
    /// - Parameter bundleIDs: Bundle identifiers to add
    func addMultipleToTemporary(bundleIDs: [String]) {
        temporaryWhitelist.formUnion(bundleIDs)
    }

    /// Add multiple apps to persistent whitelist
    /// - Parameter bundleIDs: Bundle identifiers to add
    func addMultipleToPersistent(bundleIDs: [String]) {
        persistentWhitelist.formUnion(bundleIDs)
        savePersistentWhitelist()
    }

    // MARK: - Persistence

    private func loadPersistentWhitelist() {
        if let savedArray = defaults.array(forKey: Keys.persistentWhitelist) as? [String] {
            persistentWhitelist = Set(savedArray)
            print("✅ Loaded \(persistentWhitelist.count) persistent whitelist entries")
        }
    }

    private func savePersistentWhitelist() {
        let array = Array(persistentWhitelist)
        defaults.set(array, forKey: Keys.persistentWhitelist)
        print("💾 Saved \(persistentWhitelist.count) persistent whitelist entries")
    }

    /// Add system-protected apps to persistent whitelist
    /// These apps should always be whitelisted and cannot be removed
    private func addSystemProtectedApps() {
        // Get current bundle ID (QuitAll itself)
        if let ownBundleID = Bundle.main.bundleIdentifier {
            persistentWhitelist.insert(ownBundleID)
        }

        // Add critical system apps
        let criticalApps = [
            "com.apple.finder",
            "com.apple.dock",
            "com.apple.systemuiserver",
            "com.apple.WindowServer",
            "com.apple.loginwindow"
        ]

        persistentWhitelist.formUnion(criticalApps)

        // Save to ensure system apps are always persisted
        savePersistentWhitelist()
    }

    // MARK: - Utility Methods

    /// Get all whitelisted bundle IDs (combined temporary and persistent)
    var allWhitelistedBundleIDs: Set<String> {
        temporaryWhitelist.union(persistentWhitelist)
    }

    /// Get count of total whitelisted apps
    var whitelistCount: Int {
        allWhitelistedBundleIDs.count
    }

    /// Export whitelist for backup
    func exportWhitelist() -> [String: Any] {
        [
            "temporary": Array(temporaryWhitelist),
            "persistent": Array(persistentWhitelist)
        ]
    }

    /// Import whitelist from backup
    /// - Parameter data: Dictionary with temporary and persistent arrays
    func importWhitelist(from data: [String: Any]) {
        if let tempArray = data["temporary"] as? [String] {
            temporaryWhitelist = Set(tempArray)
        }

        if let persistentArray = data["persistent"] as? [String] {
            persistentWhitelist = Set(persistentArray)
            savePersistentWhitelist()
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension WhitelistManager {
    /// Print current whitelist state for debugging
    func printStatus() {
        print("📋 Whitelist Status:")
        print("  Temporary: \(temporaryWhitelist.count) apps")
        print("  Persistent: \(persistentWhitelist.count) apps")
        print("  Total: \(whitelistCount) unique apps")
    }
}
#endif
