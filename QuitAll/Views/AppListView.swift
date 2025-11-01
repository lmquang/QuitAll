//
//  AppListView.swift
//  QuitAll
//
//  Scrollable list of running applications
//  See SPEC-003: UI/UX Design - App List Component
//

import SwiftUI

struct AppListView: View {
    // MARK: - Properties

    @ObservedObject var appManager: AppManager
    @ObservedObject var whitelistManager: WhitelistManager
    @ObservedObject var quitManager: QuitManager

    @State private var searchQuery = ""

    // MARK: - Computed Properties

    private var filteredApps: [AppInfo] {
        if searchQuery.isEmpty {
            return appManager.runningApps
        } else {
            return appManager.filteredApps(matching: searchQuery)
        }
    }

    private var appCount: Int {
        appManager.runningAppCount
    }

    private var displayedCount: Int {
        filteredApps.count
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar

            Divider()

            // Section header
            sectionHeader

            Divider()

            // Column header (only show when apps exist)
            if !filteredApps.isEmpty {
                columnHeader
                Divider()
            }

            // App list or empty state
            if filteredApps.isEmpty {
                emptyState
            } else {
                appList
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Colors.tertiary)

            TextField("Search apps...", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(Typography.appName)

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Colors.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.xs)
        .background(Colors.controlBackground)
        .cornerRadius(8)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
    }

    private var sectionHeader: some View {
        HStack {
            if searchQuery.isEmpty {
                Text("Running Apps (\(appCount))")
                    .font(Typography.subtitle.weight(.bold))
                    .foregroundColor(Colors.secondary)
            } else {
                Text("Showing \(displayedCount) of \(appCount) apps")
                    .font(Typography.subtitle.weight(.bold))
                    .foregroundColor(Colors.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Colors.controlBackground.opacity(0.5))
    }

    private var columnHeader: some View {
        HStack(spacing: Spacing.sm) {
            // App icon and name column
            HStack(spacing: Spacing.sm) {
                // Spacer for icon
                Color.clear.frame(width: Dimensions.iconSize, height: 1)
                Text("Application")
                    .font(Typography.subtitle.weight(.semibold))
                    .foregroundColor(Colors.secondary)
            }

            Spacer()

            // Quit column
            Text("Quit")
                .font(Typography.subtitle.weight(.semibold))
                .foregroundColor(Colors.secondary)
                .frame(width: 40, alignment: .center)

            // Protect column
            Text("Protect")
                .font(Typography.subtitle.weight(.semibold))
                .foregroundColor(Colors.secondary)
                .frame(width: 60, alignment: .center)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 6)
        .background(Colors.controlBackground.opacity(0.3))
    }

    private var appList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredApps) { app in
                    AppRowView(
                        app: app,
                        whitelistManager: whitelistManager,
                        quitManager: quitManager
                    )

                    if app.id != filteredApps.last?.id {
                        Divider()
                            .padding(.leading, 52) // Align with app name
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            if searchQuery.isEmpty {
                // No apps running
                Image(systemName: "checkmark.circle")
                    .font(.system(size: Dimensions.iconSizeLarge, weight: .light))
                    .foregroundColor(Colors.tertiary)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                VStack(spacing: Spacing.xs) {
                    Text("No Apps Running")
                        .font(Typography.emptyStateTitle)
                        .foregroundColor(Colors.primary)

                    Text("Your workspace is clean")
                        .font(Typography.description)
                        .foregroundColor(Colors.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                // No search results
                Image(systemName: "magnifyingglass")
                    .font(.system(size: Dimensions.iconSizeLarge, weight: .light))
                    .foregroundColor(Colors.tertiary)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)

                VStack(spacing: Spacing.xs) {
                    Text("No Results")
                        .font(Typography.emptyStateTitle)
                        .foregroundColor(Colors.primary)

                    Text("Try a different search term")
                        .font(Typography.description)
                        .foregroundColor(Colors.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.md)
    }
}

// MARK: - Preview

#if DEBUG
struct AppListView_Previews: PreviewProvider {
    static var previews: some View {
        AppListView(
            appManager: AppManager(),
            whitelistManager: WhitelistManager(),
            quitManager: QuitManager()
        )
        .frame(width: 360, height: 400)
        .onAppear {
            // Start refreshing for preview
            let manager = AppManager()
            manager.startRefreshing()
        }
    }
}
#endif
