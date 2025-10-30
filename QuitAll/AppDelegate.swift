//
//  AppDelegate.swift
//  QuitAll
//
//  AppKit integration - menu bar and popover management
//  See SPEC-001: Application Architecture and ADR-006: Menu Bar App Lifecycle
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    // Managers (created once, shared across views)
    private lazy var appManager = AppManager()
    private lazy var whitelistManager = WhitelistManager()
    private lazy var preferencesManager = PreferencesManager()
    private lazy var quitManager = QuitManager()

    // MARK: - App Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 QuitAll starting...")

        // Validate system protection
        if !SystemProtection.validateProtection() {
            print("❌ System protection validation failed!")
            // Continue anyway, but log the issue
        }

        // Create menu bar status item
        setupStatusItem()

        print("✅ QuitAll ready")
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("👋 QuitAll quitting...")

        // Stop refreshing
        appManager.stopRefreshing()

        // Clean up
        removeStatusItem()
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Allow termination
        // Could show confirmation if needed
        return .terminateNow
    }

    // MARK: - Status Item Setup

    private func setupStatusItem() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            print("❌ Failed to create status item button")
            return
        }

        // Configure icon
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        if let icon = NSImage(systemSymbolName: "power", accessibilityDescription: "QuitAll") {
            button.image = icon.withSymbolConfiguration(config)
            button.image?.isTemplate = true // Adapts to menu bar theme
        }

        // Set action
        button.action = #selector(togglePopover)
        button.target = self

        // Optional: Right-click menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "Quit QuitAll",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        // Option+click or right-click shows menu
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        print("✅ Status item created")
    }

    private func removeStatusItem() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }

    // MARK: - Popover Management

    @objc private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else { return }

        // Check if Option key or right-click
        if let event = NSApp.currentEvent {
            if event.type == .rightMouseUp || event.modifierFlags.contains(.option) {
                showMenu(sender)
                return
            }
        }

        // Toggle popover
        if let popover = popover, popover.isShown {
            hidePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button else { return }

        // Create popover if needed
        if popover == nil {
            createPopover()
        }

        guard let popover = popover else { return }

        // Show popover
        popover.show(
            relativeTo: button.bounds,
            of: button,
            preferredEdge: .minY
        )

        // Activate app to bring popover to front
        NSApp.activate(ignoringOtherApps: true)

        print("✅ Popover shown")
    }

    private func hidePopover() {
        popover?.performClose(nil)
        print("✅ Popover hidden")
    }

    private func createPopover() {
        let popover = NSPopover()

        // Configure popover
        popover.contentSize = NSSize(width: 360, height: 500)
        popover.behavior = .transient // Closes when clicked outside
        popover.animates = true

        // Create SwiftUI content
        let contentView = ContentView(
            appManager: appManager,
            whitelistManager: whitelistManager,
            preferencesManager: preferencesManager,
            quitManager: quitManager
        )

        // Host SwiftUI view
        popover.contentViewController = NSHostingController(rootView: contentView)

        self.popover = popover

        print("✅ Popover created")
    }

    @objc private func showMenu(_ sender: Any?) {
        guard let button = statusItem?.button else { return }

        let menu = NSMenu()

        // Add menu items
        menu.addItem(NSMenuItem(
            title: "About QuitAll",
            action: #selector(showAbout),
            keyEquivalent: ""
        ))

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(
            title: "Quit QuitAll",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        // Show menu
        statusItem?.menu = menu
        button.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "QuitAll"
        alert.informativeText = "Version \(AppVersion.displayVersion)\n\nA menu bar utility to quit all running applications.\n\n© 2025. All rights reserved."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
