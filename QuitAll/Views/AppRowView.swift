//
//  AppRowView.swift
//  QuitAll
//
//  Individual app row with icon, name, and whitelist toggles
//  See SPEC-003: UI/UX Design - App Row Layout
//

import SwiftUI

struct AppRowView: View {
    // MARK: - Properties

    let app: AppInfo
    @ObservedObject var whitelistManager: WhitelistManager
    @ObservedObject var quitManager: QuitManager

    @State private var isHovered = false
    @State private var isQuitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // MARK: - Computed Properties

    private var isWhitelisted: Bool {
        whitelistManager.isPersistentlyWhitelisted(bundleID: app.bundleIdentifier)
    }

    private var isSystemProtected: Bool {
        whitelistManager.isSystemProtected(bundleID: app.bundleIdentifier)
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // App Icon
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 32, height: 32)
                .cornerRadius(6)
                .opacity(isSystemProtected ? 0.6 : 1.0)

            // App Name
            Text(app.name)
                .font(.system(size: 13))
                .lineLimit(1)
                .foregroundColor(isSystemProtected ? .secondary : .primary)

            Spacer()

            if isSystemProtected {
                // System protected apps: no quit button, disabled checkbox
                Color.clear.frame(width: 40)
                protectedCheckbox
            } else {
                // User apps: quit button and checkbox
                quitButton
                whitelistToggle
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .help(isSystemProtected ? "System apps cannot be quit" : app.bundleIdentifier)
        .alert("Quit App", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Subviews

    private var quitButton: some View {
        Button(action: {
            quitSingleApp()
        }) {
            if isQuitting {
                ProgressView()
                    .controlSize(.small)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: isHovered ? "xmark.circle.fill" : "xmark.circle")
                    .foregroundColor(.secondary)
                    .opacity(isHovered ? 1.0 : 0.6)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 40, alignment: .center)
        .disabled(isQuitting || isWhitelisted)
        .help(isWhitelisted ? "Uncheck 'Protect' to quit this app" : "Quit \(app.name)")
    }

    private var protectedCheckbox: some View {
        Toggle("", isOn: .constant(true))
            .toggleStyle(.checkbox)
            .disabled(true)
            .help("System app - always protected")
            .frame(width: 60, alignment: .center)
    }

    private var whitelistToggle: some View {
        Toggle("", isOn: Binding(
            get: { isWhitelisted },
            set: { isOn in
                if isOn {
                    whitelistManager.addToPersistent(bundleID: app.bundleIdentifier)
                } else {
                    whitelistManager.removeFromPersistent(bundleID: app.bundleIdentifier)
                }
            }
        ))
        .toggleStyle(.checkbox)
        .help(isWhitelisted ? "Protected - won't be quit" : "Not protected - will be quit")
        .frame(width: 60, alignment: .center)
    }

    // MARK: - Actions

    private func quitSingleApp() {
        guard !isQuitting else { return }

        // Safety check - system protection
        guard SystemProtection.canQuit(app.nsRunningApp) else {
            alertMessage = "Cannot quit system app: \(app.name)"
            showAlert = true
            return
        }

        // Check if whitelisted
        if isWhitelisted {
            alertMessage = "\(app.name) is protected. Uncheck 'Protect' to quit it."
            showAlert = true
            return
        }

        isQuitting = true

        // Quit the app
        quitManager.quitApp(app.nsRunningApp) { result in
            DispatchQueue.main.async {
                isQuitting = false

                switch result {
                case .success:
                    print("✅ Successfully quit: \(app.name)")
                    // App will disappear from list automatically via AppManager monitoring

                case .failure(let error):
                    alertMessage = "Failed to quit \(app.name): \(error.localizedDescription ?? "Unknown error")"
                    showAlert = true
                    print("❌ Failed to quit \(app.name): \(error)")
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AppRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Mock user app
            if let app = createMockApp(name: "Safari", bundleID: "com.apple.Safari") {
                AppRowView(
                    app: app,
                    whitelistManager: WhitelistManager(),
                    quitManager: QuitManager()
                )
            }

            Divider()

            // Mock system app
            if let app = createMockApp(name: "Finder", bundleID: "com.apple.finder") {
                AppRowView(
                    app: app,
                    whitelistManager: WhitelistManager(),
                    quitManager: QuitManager()
                )
            }
        }
        .frame(width: 360)
        .padding()
    }

    static func createMockApp(name: String, bundleID: String) -> AppInfo? {
        // Find a running app to use as mock
        let runningApps = NSWorkspace.shared.runningApplications
        if let mockApp = runningApps.first(where: { $0.activationPolicy == .regular }) {
            return AppInfo(from: mockApp)
        }
        return nil
    }
}
#endif
