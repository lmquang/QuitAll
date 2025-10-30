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
                .foregroundColor(.secondary)

            TextField("Search apps...", text: $searchQuery)
                .textFieldStyle(.plain)

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var sectionHeader: some View {
        HStack {
            if searchQuery.isEmpty {
                Text("Running Apps (\(appCount))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            } else {
                Text("Showing \(displayedCount) of \(appCount) apps")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    private var appList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredApps) { app in
                    AppRowView(
                        app: app,
                        whitelistManager: whitelistManager
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
        VStack(spacing: 16) {
            if searchQuery.isEmpty {
                // No apps running
                Text("🎉")
                    .font(.system(size: 48))

                Text("No apps running!")
                    .font(.title2.bold())

                Text("Your workspace is clean.")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                // No search results
                Text("🔍")
                    .font(.system(size: 48))

                Text("No apps match \"\(searchQuery)\"")
                    .font(.title3.bold())

                Text("Try a different search term.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct AppListView_Previews: PreviewProvider {
    static var previews: some View {
        AppListView(
            appManager: AppManager(),
            whitelistManager: WhitelistManager()
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
