//
//  Version.swift
//  QuitAll
//
//  Application version and build information
//

import Foundation

enum AppVersion {
    static let version = "1.0.0"
    static let build = "1"

    static var fullVersion: String {
        "\(version) (\(build))"
    }

    /// Returns version from Info.plist if available, falls back to hardcoded version
    static var bundleVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return AppVersion.version
    }

    /// Returns build number from Info.plist if available, falls back to hardcoded build
    static var bundleBuild: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return AppVersion.build
    }

    /// Full version string with build number
    static var displayVersion: String {
        "\(bundleVersion) (\(bundleBuild))"
    }
}
