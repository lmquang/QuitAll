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

    @State private var isHovered = false

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
                // Protected badge for system apps
                protectedBadge
            } else {
                // Whitelist toggle for user apps
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
    }

    // MARK: - Subviews

    private var protectedBadge: some View {
        Text("Protected")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
    }

    private var whitelistToggle: some View {
        Toggle("Protect", isOn: Binding(
            get: { isWhitelisted },
            set: { isOn in
                if isOn {
                    whitelistManager.addToPersistent(bundleID: app.bundleIdentifier)
                } else {
                    whitelistManager.removeFromPersistent(bundleID: app.bundleIdentifier)
                }
            }
        ))
        .toggleStyle(.switch)
        .help(isWhitelisted ? "Protected - won't be quit" : "Not protected - will be quit")
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
                    whitelistManager: WhitelistManager()
                )
            }

            Divider()

            // Mock system app
            if let app = createMockApp(name: "Finder", bundleID: "com.apple.finder") {
                AppRowView(
                    app: app,
                    whitelistManager: WhitelistManager()
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
