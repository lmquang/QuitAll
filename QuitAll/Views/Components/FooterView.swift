//
//  FooterView.swift
//  QuitAll
//
//  Footer component with main action button
//  See SPEC-002: Layout & Spacing System, section 3.3
//

import SwiftUI

struct FooterView: View {
    // MARK: - Properties

    let onQuitAll: () -> Void
    let isDisabled: Bool
    let isQuitting: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            Button(action: onQuitAll) {
                HStack(spacing: Spacing.xs) {
                    if isQuitting {
                        ProgressView()
                            .controlSize(.small)
                        Text("Quitting...")
                    } else {
                        Image(systemName: "power")
                        Text("Quit All Apps")
                    }
                }
                .font(Typography.buttonPrimary)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Dimensions.buttonHeight)
            }
            .buttonStyle(.plain)
            .background(Colors.destructive)
            .cornerRadius(8)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .accessibilityLabel("Quit all applications")
            .accessibilityHint("Quits all running applications except system apps and protected apps")
        }
        .frame(height: Dimensions.footerHeight)
    }
}

// MARK: - Preview

#if DEBUG
struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FooterView(
                onQuitAll: { print("Quit all") },
                isDisabled: false,
                isQuitting: false
            )

            FooterView(
                onQuitAll: { print("Quit all") },
                isDisabled: true,
                isQuitting: false
            )

            FooterView(
                onQuitAll: { print("Quit all") },
                isDisabled: false,
                isQuitting: true
            )
        }
        .frame(width: Dimensions.popoverWidth)
    }
}
#endif
