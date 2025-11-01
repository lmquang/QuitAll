//
//  SettingsView.swift
//  QuitAll
//
//  Settings and preferences view
//  See SPEC-003: UI/UX Design - Settings View
//

import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    // MARK: - Properties

    @ObservedObject var preferencesManager: PreferencesManager
    @ObservedObject var whitelistManager: WhitelistManager
    @ObservedObject var hotkeyManager: HotkeyManager

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // General settings
                generalSection

                // Hotkey settings
                hotkeySection

                // Whitelist management
                whitelistSection

                // About section
                aboutSection
            }
            .padding(Spacing.md)
        }
    }

    // MARK: - Sections

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("General")
                .font(Typography.popoverTitle)
                .foregroundColor(Colors.primary)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Toggle("Show confirmation before quit",
                       isOn: $preferencesManager.showConfirmation)
                    .toggleStyle(.switch)
                    .font(Typography.appName)

                if #available(macOS 13.0, *) {
                    Toggle("Launch at login",
                           isOn: $preferencesManager.launchAtLogin)
                        .toggleStyle(.switch)
                        .font(Typography.appName)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var whitelistSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Persistent Whitelist")
                    .font(Typography.popoverTitle)
                    .foregroundColor(Colors.primary)
                Spacer()
                Text("(\(userWhitelistedApps.count))")
                    .font(Typography.count)
                    .foregroundColor(Colors.secondary)
            }

            if userWhitelistedApps.isEmpty {
                Text("No apps whitelisted")
                    .font(Typography.description)
                    .foregroundColor(Colors.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.xs)
            } else {
                VStack(spacing: Spacing.xxs) {
                    ForEach(userWhitelistedApps, id: \.self) { bundleID in
                        HStack(spacing: Spacing.xs) {
                            // App name from bundle ID
                            Text(bundleID.components(separatedBy: ".").last ?? bundleID)
                                .font(Typography.appName)
                                .foregroundColor(Colors.primary)
                                .lineLimit(1)

                            Spacer()

                            Button(action: {
                                whitelistManager.removeFromPersistent(bundleID: bundleID)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: Dimensions.iconSize))
                                    .foregroundColor(Colors.destructive.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                            .help("Remove from whitelist")
                        }
                        .padding(.vertical, Spacing.xxs + 2)
                        .padding(.horizontal, Spacing.xs)
                        .background(Colors.controlBackground.opacity(0.5))
                        .cornerRadius(Spacing.xxs + 2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hotkeySection: some View {
        GroupBox(label: Label("Global Hotkey", systemImage: "keyboard")) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Enable toggle
                Toggle("Enable Global Hotkey", isOn: $hotkeyManager.isEnabled)
                    .font(Typography.appName)
                    .help("Allow triggering Quit All with a keyboard shortcut from anywhere")

                Divider()

                // Hotkey recorder
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Keyboard Shortcut:")
                        .font(Typography.subtitle)
                        .foregroundColor(Colors.secondary)

                    KeyboardShortcuts.Recorder(for: .quitAllApps)
                        .disabled(!hotkeyManager.isEnabled)
                }

                // Permission status warning
                if !hotkeyManager.hasPermission && hotkeyManager.isEnabled {
                    HStack(alignment: .top, spacing: Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: Dimensions.iconSize))

                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Input Monitoring Permission Required")
                                .font(Typography.subtitle.weight(.semibold))

                            Text("Grant permission in System Settings to use global hotkeys.")
                                .font(Typography.caption)
                                .foregroundColor(Colors.secondary)
                        }

                        Spacer()

                        Button("Open Settings") {
                            hotkeyManager.openPermissionSettings()
                        }
                        .controlSize(.small)
                    }
                    .padding(Spacing.xs + 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(Spacing.xxs + 2)
                }

                // Help text
                Text("Press the keyboard shortcut from anywhere to quit all running apps (respecting protected apps). Default: Cmd+Option+Shift+Q")
                    .font(Typography.caption)
                    .foregroundColor(Colors.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var userWhitelistedApps: [String] {
        Array(whitelistManager.persistentWhitelist)
            .filter { !whitelistManager.isSystemProtected(bundleID: $0) }
            .sorted()
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("About")
                .font(Typography.popoverTitle)
                .foregroundColor(Colors.primary)

            VStack(spacing: Spacing.xs) {
                HStack {
                    Text("Version")
                        .font(Typography.appName)
                        .foregroundColor(Colors.primary)
                    Spacer()
                    Text(AppVersion.displayVersion)
                        .font(Typography.appName)
                        .foregroundColor(Colors.secondary)
                }

                HStack {
                    Text("Copyright")
                        .font(Typography.appName)
                        .foregroundColor(Colors.primary)
                    Spacer()
                    Text("© 2025")
                        .font(Typography.appName)
                        .foregroundColor(Colors.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            preferencesManager: PreferencesManager(),
            whitelistManager: WhitelistManager(),
            hotkeyManager: HotkeyManager { }
        )
    }
}
#endif
