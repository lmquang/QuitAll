//
//  ContentView.swift
//  QuitAll
//
//  Main popover content view
//  See SPEC-003: UI/UX Design - Layout Structure
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties

    @ObservedObject var appManager: AppManager
    @ObservedObject var whitelistManager: WhitelistManager
    @ObservedObject var preferencesManager: PreferencesManager
    @ObservedObject var quitManager: QuitManager
    @ObservedObject var hotkeyManager: HotkeyManager

    @State private var showSettings = false
    @State private var isQuitting = false

    // Accessibility: Detect Reduce Transparency preference
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    // MARK: - Computed Properties

    private var appsToQuit: [AppInfo] {
        appManager.runningApps.filter { app in
            !whitelistManager.isWhitelisted(bundleID: app.bundleIdentifier)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            if showSettings {
                // Settings header
                settingsHeader

                Divider()

                // Settings content
                SettingsView(
                    preferencesManager: preferencesManager,
                    whitelistManager: whitelistManager,
                    hotkeyManager: hotkeyManager
                )
            } else {
                // Main app list view with header
                HeaderView(
                    appCount: appManager.runningAppCount,
                    onSettingsTap: { showSettings = true }
                )

                Divider()

                // App list (scrollable content)
                AppListView(
                    appManager: appManager,
                    whitelistManager: whitelistManager,
                    quitManager: quitManager
                )

                // Fixed footer at bottom
                FooterView(
                    onQuitAll: handleQuitAll,
                    isDisabled: appsToQuit.isEmpty,
                    isQuitting: isQuitting
                )
            }
        }
        .frame(width: Dimensions.popoverWidth)
        .frame(minHeight: Dimensions.popoverMinHeight, maxHeight: Dimensions.popoverMaxHeight)
        .background(popoverBackground)
        .cornerRadius(Dimensions.popoverCornerRadius)
        .onAppear {
            // Start refreshing when view appears
            appManager.startRefreshing()

            // Validate system protection
            _ = SystemProtection.validateProtection()
        }
        .onDisappear {
            // Stop refreshing when view disappears
            appManager.stopRefreshing()
        }
    }

    // MARK: - Background

    /// Popover background with accessibility support
    /// Uses translucent material or solid color based on Reduce Transparency setting
    @ViewBuilder
    private var popoverBackground: some View {
        if reduceTransparency {
            // Solid color fallback for Reduce Transparency
            Colors.windowBackground
                .overlay(
                    RoundedRectangle(cornerRadius: Dimensions.popoverCornerRadius)
                        .stroke(Colors.fallbackBorder, lineWidth: 0.5)
                )
        } else {
            // Translucent material background
            PopoverMaterialBackground()
        }
    }

    // MARK: - Subviews

    private var settingsHeader: some View {
        HStack {
            Button(action: { showSettings = false }) {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(Colors.primary)

            Spacer()
        }
        .padding(Spacing.md)
        .frame(height: Dimensions.headerHeight)
    }

    // MARK: - Actions

    private func handleQuitAll() {
        guard !appsToQuit.isEmpty else { return }

        isQuitting = true

        quitManager.quitAllApps(
            apps: appsToQuit,
            whitelistManager: whitelistManager,
            onProgress: { app, result in
                switch result {
                case .success:
                    print("✅ Quit \(app.name)")
                case .failure(let error):
                    print("❌ Failed to quit \(app.name): \(error.localizedDescription)")
                }
            },
            onComplete: {
                isQuitting = false
                print("✅ Quit all complete")
            }
        )
    }

}

// MARK: - Preview

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            appManager: AppManager(),
            whitelistManager: WhitelistManager(),
            preferencesManager: PreferencesManager(),
            quitManager: QuitManager(),
            hotkeyManager: HotkeyManager { }
        )
    }
}
#endif
