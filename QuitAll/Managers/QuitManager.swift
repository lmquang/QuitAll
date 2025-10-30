//
//  QuitManager.swift
//  QuitAll
//
//  Manages application quitting logic with safety checks
//  See SPEC-002: Manager Layer - QuitManager
//

import Foundation
import AppKit
import Combine

/// Manages quitting applications with graceful and force quit support
final class QuitManager: ObservableObject {

    // MARK: - Published Properties

    /// Current quit operations in progress
    @Published private(set) var quittingApps: Set<String> = []

    /// Apps that failed to quit
    @Published private(set) var failedQuits: [String: QuitError] = [:]

    // MARK: - Configuration

    /// Timeout for graceful quit before considering it failed
    private let gracefulQuitTimeout: TimeInterval = 5.0

    /// Polling interval to check if app has quit
    private let checkInterval: TimeInterval = 0.5

    // MARK: - Types

    enum QuitError: LocalizedError {
        case permissionDenied
        case appRefusedToQuit
        case systemAppProtected
        case timeout
        case alreadyQuitting
        case unknown(Error)

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Permission denied to quit this app"
            case .appRefusedToQuit:
                return "App refused to quit"
            case .systemAppProtected:
                return "System app cannot be quit"
            case .timeout:
                return "App did not quit within timeout"
            case .alreadyQuitting:
                return "App is already being quit"
            case .unknown(let error):
                return "Unknown error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Single App Quit

    /// Quit a single application gracefully
    /// - Parameters:
    ///   - app: The NSRunningApplication to quit
    ///   - completion: Completion handler with result
    func quitApp(
        _ app: NSRunningApplication,
        completion: @escaping (Result<Void, QuitError>) -> Void
    ) {
        let bundleID = app.bundleIdentifier ?? "unknown"

        // Safety check - system protection
        guard SystemProtection.canQuit(app) else {
            print("🛡️ Blocked quit attempt: \(bundleID) (system protected)")
            completion(.failure(.systemAppProtected))
            return
        }

        // Check if already quitting
        guard !quittingApps.contains(bundleID) else {
            completion(.failure(.alreadyQuitting))
            return
        }

        // Mark as quitting
        quittingApps.insert(bundleID)
        print("🚪 Quitting: \(bundleID)")

        // Try graceful quit
        guard app.terminate() else {
            print("❌ Failed to terminate: \(bundleID)")
            quittingApps.remove(bundleID)
            failedQuits[bundleID] = .permissionDenied
            completion(.failure(.permissionDenied))
            return
        }

        // Wait for app to quit (with timeout)
        waitForAppToQuit(app, bundleID: bundleID, completion: completion)
    }

    /// Wait for an app to quit, with timeout
    private func waitForAppToQuit(
        _ app: NSRunningApplication,
        bundleID: String,
        completion: @escaping (Result<Void, QuitError>) -> Void
    ) {
        let startTime = Date()
        var checkCount = 0

        Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            checkCount += 1

            // Check if app has quit
            if app.isTerminated {
                timer.invalidate()
                self.quittingApps.remove(bundleID)
                self.failedQuits.removeValue(forKey: bundleID)
                print("✅ Successfully quit: \(bundleID) (after \(checkCount) checks)")
                completion(.success(()))
                return
            }

            // Check for timeout
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed > self.gracefulQuitTimeout {
                timer.invalidate()
                self.quittingApps.remove(bundleID)
                self.failedQuits[bundleID] = .timeout
                print("⏱️ Timeout quitting: \(bundleID) (after \(elapsed)s)")
                completion(.failure(.timeout))
                return
            }
        }
    }

    // MARK: - Batch Quit

    /// Quit multiple applications
    /// - Parameters:
    ///   - apps: Array of AppInfo to quit
    ///   - whitelistManager: Whitelist manager to check against
    ///   - onProgress: Called for each app with result
    ///   - onComplete: Called when all operations complete
    func quitAllApps(
        apps: [AppInfo],
        whitelistManager: WhitelistManager,
        onProgress: @escaping (AppInfo, Result<Void, QuitError>) -> Void,
        onComplete: @escaping () -> Void
    ) {
        // Filter out whitelisted apps
        let appsToQuit = apps.filter { app in
            !whitelistManager.isWhitelisted(bundleID: app.bundleIdentifier)
        }

        print("🚫 Quitting \(appsToQuit.count) apps (filtered from \(apps.count))")

        guard !appsToQuit.isEmpty else {
            print("ℹ️ No apps to quit")
            onComplete()
            return
        }

        var remaining = appsToQuit.count

        // Quit each app
        for app in appsToQuit {
            quitApp(app.nsRunningApp) { result in
                // Report progress
                onProgress(app, result)

                // Check if all done
                remaining -= 1
                if remaining == 0 {
                    print("✅ Quit all operations complete")
                    onComplete()
                }
            }
        }
    }

    // MARK: - Force Quit

    /// Force quit an application (last resort)
    /// - Parameters:
    ///   - app: The NSRunningApplication to force quit
    ///   - completion: Completion handler
    func forceQuitApp(
        _ app: NSRunningApplication,
        completion: @escaping (Result<Void, QuitError>) -> Void
    ) {
        let bundleID = app.bundleIdentifier ?? "unknown"

        // Safety check
        guard SystemProtection.canQuit(app) else {
            completion(.failure(.systemAppProtected))
            return
        }

        print("⚠️ Force quitting: \(bundleID)")

        // Force quit
        app.forceTerminate()

        // Give it a moment, then check
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if app.isTerminated {
                self.quittingApps.remove(bundleID)
                self.failedQuits.removeValue(forKey: bundleID)
                print("✅ Force quit successful: \(bundleID)")
                completion(.success(()))
            } else {
                self.failedQuits[bundleID] = .appRefusedToQuit
                print("❌ Force quit failed: \(bundleID)")
                completion(.failure(.appRefusedToQuit))
            }
        }
    }

    // MARK: - Utility Methods

    /// Check if an app is currently being quit
    /// - Parameter bundleID: Bundle identifier
    /// - Returns: true if currently quitting
    func isQuitting(bundleID: String) -> Bool {
        quittingApps.contains(bundleID)
    }

    /// Get error for a failed quit
    /// - Parameter bundleID: Bundle identifier
    /// - Returns: Error if quit failed, nil otherwise
    func quitError(for bundleID: String) -> QuitError? {
        failedQuits[bundleID]
    }

    /// Clear failed quit errors
    func clearFailedQuits() {
        failedQuits.removeAll()
    }

    /// Get count of apps currently being quit
    var quittingCount: Int {
        quittingApps.count
    }

    /// Get count of failed quits
    var failedCount: Int {
        failedQuits.count
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension QuitManager {
    /// Print current status for debugging
    func printStatus() {
        print("🚪 QuitManager Status:")
        print("  Currently quitting: \(quittingCount)")
        print("  Failed quits: \(failedCount)")

        if !quittingApps.isEmpty {
            print("\n  Quitting:")
            for bundleID in quittingApps {
                print("    - \(bundleID)")
            }
        }

        if !failedQuits.isEmpty {
            print("\n  Failed:")
            for (bundleID, error) in failedQuits {
                print("    - \(bundleID): \(error.errorDescription ?? "Unknown")")
            }
        }
    }
}
#endif
