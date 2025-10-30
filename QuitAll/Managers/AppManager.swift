//
//  AppManager.swift
//  QuitAll
//
//  Manages running applications list and monitoring
//  See SPEC-002: Manager Layer - AppManager
//

import Foundation
import AppKit
import Combine

/// Manages the list of running applications
final class AppManager: ObservableObject {

    // MARK: - Published Properties

    /// List of currently running applications
    @Published private(set) var runningApps: [AppInfo] = []

    /// Whether the manager is actively refreshing
    @Published private(set) var isRefreshing = false

    // MARK: - Private Properties

    private var refreshTimer: Timer?
    private var observers: [NSObjectProtocol] = []
    private let refreshInterval: TimeInterval = 1.0

    // MARK: - Initialization

    init() {
        // Don't start refreshing automatically
        // Will be started when popover is shown
    }

    deinit {
        stopRefreshing()
    }

    // MARK: - Public Methods

    /// Start refreshing the app list
    func startRefreshing() {
        guard !isRefreshing else { return }

        print("▶️ AppManager: Starting refresh")
        isRefreshing = true

        // Immediate refresh
        refreshApps()

        // Setup periodic refresh (every second)
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: true
        ) { [weak self] _ in
            self?.refreshApps()
        }

        // Setup NSWorkspace notifications for real-time updates
        setupObservers()
    }

    /// Stop refreshing the app list
    func stopRefreshing() {
        guard isRefreshing else { return }

        print("⏸️ AppManager: Stopping refresh")
        isRefreshing = false

        // Stop timer
        refreshTimer?.invalidate()
        refreshTimer = nil

        // Remove observers
        removeObservers()

        // Optionally clear apps to free memory
        // runningApps = []
    }

    /// Force an immediate refresh
    func forceRefresh() {
        refreshApps()
    }

    // MARK: - App Fetching

    /// Refresh the list of running applications
    private func refreshApps() {
        let workspace = NSWorkspace.shared

        // Get all running applications
        let allApps = workspace.runningApplications

        // Filter and convert to AppInfo
        let apps = allApps
            .filter { app in
                // Only regular GUI applications
                guard app.activationPolicy == .regular else { return false }

                // Must have a bundle identifier
                guard let bundleID = app.bundleIdentifier else { return false }

                // Must not be terminated
                guard !app.isTerminated else { return false }

                // Exclude system-protected apps from the list
                guard !SystemProtection.isProtected(bundleID: bundleID) else { return false }

                return true
            }
            .compactMap { AppInfo(from: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        // Update published property on main thread
        DispatchQueue.main.async { [weak self] in
            self?.runningApps = apps
        }
    }

    // MARK: - Real-Time Monitoring

    private func setupObservers() {
        let center = NSWorkspace.shared.notificationCenter

        // App launched notification
        let launchObserver = center.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            print("🚀 App launched")
            self?.refreshApps()
        }

        // App terminated notification
        let quitObserver = center.addObserver(
            forName: NSWorkspace.didTerminateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            print("🛑 App quit")
            self?.refreshApps()
        }

        // App activated notification (optional - for more responsive UI)
        let activateObserver = center.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            // Could use this to highlight active app
            // For now, just refresh
            self?.refreshApps()
        }

        observers = [launchObserver, quitObserver, activateObserver]
        print("✅ Observers setup complete")
    }

    private func removeObservers() {
        let center = NSWorkspace.shared.notificationCenter
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
        print("✅ Observers removed")
    }

    // MARK: - Query Methods

    /// Get app by bundle identifier
    /// - Parameter bundleID: Bundle identifier to search for
    /// - Returns: AppInfo if found
    func app(withBundleID bundleID: String) -> AppInfo? {
        runningApps.first { $0.bundleIdentifier == bundleID }
    }

    /// Get count of running apps
    var runningAppCount: Int {
        runningApps.count
    }

    /// Get apps that are not system-protected
    var userApps: [AppInfo] {
        runningApps.filter { app in
            !SystemProtection.isProtected(bundleID: app.bundleIdentifier)
        }
    }

    /// Get system-protected apps
    var systemApps: [AppInfo] {
        runningApps.filter { app in
            SystemProtection.isProtected(bundleID: app.bundleIdentifier)
        }
    }

    /// Filter apps by search query
    /// - Parameter query: Search string
    /// - Returns: Filtered apps matching the query
    func filteredApps(matching query: String) -> [AppInfo] {
        guard !query.isEmpty else { return runningApps }

        let lowercasedQuery = query.lowercased()
        return runningApps.filter { app in
            app.name.lowercased().contains(lowercasedQuery) ||
            app.bundleIdentifier.lowercased().contains(lowercasedQuery)
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension AppManager {
    /// Print current status for debugging
    func printStatus() {
        print("📱 AppManager Status:")
        print("  Running apps: \(runningAppCount)")
        print("  User apps: \(userApps.count)")
        print("  System apps: \(systemApps.count)")
        print("  Refreshing: \(isRefreshing)")
        print("\n  Apps:")
        for app in runningApps {
            print("    - \(app.name) (\(app.bundleIdentifier))")
        }
    }
}
#endif
