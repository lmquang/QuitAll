//
//  HeaderView.swift
//  QuitAll
//
//  Header component with title and app count
//  See SPEC-002: Layout & Spacing System, section 3.1
//

import SwiftUI

struct HeaderView: View {
    // MARK: - Properties

    let appCount: Int
    let onSettingsTap: () -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text("Quit All")
                .font(Typography.popoverTitle)
                .foregroundColor(Colors.primary)

            Spacer()

            Button(action: onSettingsTap) {
                Image(systemName: "gearshape")
                    .font(.system(size: Dimensions.iconSize))
                    .foregroundColor(Colors.secondary)
            }
            .buttonStyle(.plain)
            .help("Settings")
            .accessibilityLabel("Open settings")
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: Dimensions.headerHeight)
    }
}

// MARK: - Preview

#if DEBUG
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            HeaderView(appCount: 5, onSettingsTap: { print("Settings tapped") })
            Divider()
            HeaderView(appCount: 15, onSettingsTap: { print("Settings tapped") })
            Divider()
            HeaderView(appCount: 0, onSettingsTap: { print("Settings tapped") })
        }
        .frame(width: Dimensions.popoverWidth)
    }
}
#endif
