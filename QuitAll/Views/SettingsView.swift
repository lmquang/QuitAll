//
//  SettingsView.swift
//  QuitAll
//
//  Settings and preferences view
//  See SPEC-003: UI/UX Design - Settings View
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties

    @ObservedObject var preferencesManager: PreferencesManager
    @ObservedObject var whitelistManager: WhitelistManager

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // General settings
                generalSection

                // Whitelist management
                whitelistSection

                // About section
                aboutSection
            }
            .padding()
        }
    }

    // MARK: - Sections

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("General")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Show confirmation before quit",
                       isOn: $preferencesManager.showConfirmation)
                    .toggleStyle(.switch)

                if #available(macOS 13.0, *) {
                    Toggle("Launch at login",
                           isOn: $preferencesManager.launchAtLogin)
                        .toggleStyle(.switch)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var whitelistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Persistent Whitelist")
                    .font(.headline)
                Spacer()
                Text("(\(userWhitelistedApps.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if userWhitelistedApps.isEmpty {
                Text("No apps whitelisted")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 4) {
                    ForEach(userWhitelistedApps, id: \.self) { bundleID in
                        HStack(spacing: 8) {
                            // App name from bundle ID
                            Text(bundleID.components(separatedBy: ".").last ?? bundleID)
                                .font(.system(.body, design: .rounded))
                                .lineLimit(1)

                            Spacer()

                            Button(action: {
                                whitelistManager.removeFromPersistent(bundleID: bundleID)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                            .help("Remove from whitelist")
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
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
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(AppVersion.displayVersion)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Copyright")
                    Spacer()
                    Text("© 2025")
                        .foregroundColor(.secondary)
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
            whitelistManager: WhitelistManager()
        )
    }
}
#endif
