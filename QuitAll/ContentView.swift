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

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Main content
            if showSettings {
                SettingsView(
                    preferencesManager: preferencesManager,
                    whitelistManager: whitelistManager,
                    hotkeyManager: hotkeyManager
                )
            } else {
                mainContent
            }
        }
        .frame(width: 360, height: 500)
        .onAppear {
            // Start refreshing when view appears
            appManager.startRefreshing()

            // Validate system protection
            SystemProtection.validateProtection()
        }
        .onDisappear {
            // Stop refreshing when view disappears
            appManager.stopRefreshing()
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            if showSettings {
                Button(action: { showSettings = false }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .buttonStyle(.plain)
            } else {
                Text("QuitAll")
                    .font(.title2.bold())
            }

            Spacer()

            if !showSettings {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .imageScale(.medium)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // App list
            AppListView(
                appManager: appManager,
                whitelistManager: whitelistManager,
                quitManager: quitManager
            )

            Divider()

            // Quit all button
            QuitAllButton(
                appManager: appManager,
                whitelistManager: whitelistManager,
                preferencesManager: preferencesManager,
                quitManager: quitManager
            )
            .padding(.vertical, 8)
        }
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
