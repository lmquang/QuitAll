//
//  QuitAllButton.swift
//  QuitAll
//
//  Main action button to quit all non-whitelisted apps
//  See SPEC-003: UI/UX Design - Quit All Button
//

import SwiftUI

struct QuitAllButton: View {
    // MARK: - Properties

    @ObservedObject var appManager: AppManager
    @ObservedObject var whitelistManager: WhitelistManager
    @ObservedObject var preferencesManager: PreferencesManager
    @ObservedObject var quitManager: QuitManager

    @State private var showConfirmation = false
    @State private var isQuitting = false

    // MARK: - Computed Properties

    private var appsToQuit: [AppInfo] {
        appManager.runningApps.filter { app in
            !whitelistManager.isWhitelisted(bundleID: app.bundleIdentifier)
        }
    }

    private var quitCount: Int {
        appsToQuit.count
    }

    private var isDisabled: Bool {
        appsToQuit.isEmpty || isQuitting
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            // Help text
            HStack {
                Image(systemName: "info.circle")
                    .font(.caption)
                Text("Whitelisted apps will not quit")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Main button
            Button(action: handleQuitAll) {
                HStack {
                    if isQuitting {
                        ProgressView()
                            .controlSize(.small)
                        Text("Quitting...")
                    } else {
                        Image(systemName: "power")
                        Text("Quit All Apps")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isDisabled)
        }
        .padding(.horizontal)
        .confirmationDialog(
            "Quit \(quitCount) Application\(quitCount == 1 ? "" : "s")?",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Quit All", role: .destructive) {
                performQuitAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            VStack(alignment: .leading, spacing: 8) {
                Text("The following apps will quit:")

                ForEach(appsToQuit.prefix(5)) { app in
                    Text("• \(app.name)")
                }

                if quitCount > 5 {
                    Text("... and \(quitCount - 5) more")
                }

                Text("Whitelisted apps will be preserved.")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func handleQuitAll() {
        if preferencesManager.showConfirmation {
            showConfirmation = true
        } else {
            performQuitAll()
        }
    }

    private func performQuitAll() {
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
struct QuitAllButton_Previews: PreviewProvider {
    static var previews: some View {
        QuitAllButton(
            appManager: AppManager(),
            whitelistManager: WhitelistManager(),
            preferencesManager: PreferencesManager(),
            quitManager: QuitManager()
        )
        .frame(width: 360)
        .padding()
    }
}
#endif
