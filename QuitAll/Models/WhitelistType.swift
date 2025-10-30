//
//  WhitelistType.swift
//  QuitAll
//
//  Enum to distinguish between temporary and persistent whitelist entries
//  See requirements.md and SPEC-002: Manager Layer
//

import Foundation

/// Type of whitelist entry
enum WhitelistType: String, Codable, CaseIterable {
    /// Temporary whitelist - lasts only for current session
    /// Cleared when QuitAll restarts
    case temporary

    /// Persistent whitelist - saved to UserDefaults
    /// Survives app restarts
    case persistent
}

/// Whitelist entry with metadata
struct WhitelistEntry: Codable, Hashable, Identifiable {
    var id: String { bundleIdentifier }

    /// Bundle identifier of the whitelisted app
    let bundleIdentifier: String

    /// Display name (optional, for UI purposes)
    var displayName: String?

    /// When this entry was added
    let dateAdded: Date

    /// Type of whitelist entry
    let type: WhitelistType

    init(bundleIdentifier: String, displayName: String? = nil, type: WhitelistType) {
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.dateAdded = Date()
        self.type = type
    }
}
