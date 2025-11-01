//
//  PopoverMaterialBackground.swift
//  QuitAll
//
//  NSVisualEffectView wrapper for translucent popover background
//  See SPEC-001: Visual Foundation, section 1.1
//

import SwiftUI
import AppKit

/// Translucent material background for popover using NSVisualEffectView
///
/// Provides system-standard `.popover` material with proper blur and translucency.
/// Automatically adapts to light/dark mode and respects system appearance.
///
/// Usage:
/// ```swift
/// ContentView()
///     .background(PopoverMaterialBackground())
/// ```
///
/// Configuration:
/// - Material: `.popover` (menu bar standard)
/// - Blending: `.behindWindow` (blurs content behind)
/// - State: `.active` (always active, even when unfocused)
/// - Corner Radius: 16pt (macOS Sonoma/Sequoia standard)
struct PopoverMaterialBackground: NSViewRepresentable {
    // MARK: - Configuration

    /// Visual effect material type
    private let material: NSVisualEffectView.Material = .popover

    /// Blending mode for transparency effect
    private let blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    /// Corner radius for rounded corners
    private let cornerRadius: CGFloat = Dimensions.popoverCornerRadius

    // MARK: - NSViewRepresentable

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()

        // Configure material and blending
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active  // Always active, even when window unfocused

        // Configure layer for corner radius
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = cornerRadius
        visualEffectView.layer?.masksToBounds = true

        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        // Update configuration (in case it changes)
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = .active

        // Update corner radius
        nsView.layer?.cornerRadius = cornerRadius
        nsView.layer?.masksToBounds = true
    }
}

// MARK: - Preview

#if DEBUG
struct PopoverMaterialBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.md) {
            Text("Popover Material Background")
                .font(Typography.popoverTitle)
                .foregroundColor(Colors.primary)

            Text("This demonstrates the translucent material effect")
                .font(Typography.description)
                .foregroundColor(Colors.secondary)

            Text("Try placing it over different wallpapers")
                .font(Typography.caption)
                .foregroundColor(Colors.tertiary)
        }
        .padding(Dimensions.popoverPadding)
        .frame(width: Dimensions.popoverWidth, height: 300)
        .background(PopoverMaterialBackground())
    }
}
#endif
