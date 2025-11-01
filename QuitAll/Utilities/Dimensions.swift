//
//  Dimensions.swift
//  QuitAll
//
//  Component dimensional constants for the UI modernization
//  See SPEC-002: Layout & Spacing System
//

import Foundation

/// Dimensional constants for UI components
///
/// Defines fixed dimensions for popover, rows, icons, and interactive elements.
/// All values align with the 8-point grid system where possible.
///
/// Usage:
/// ```swift
/// .frame(width: Dimensions.popoverWidth, height: Dimensions.rowHeight)
/// ```
enum Dimensions {
    // MARK: - Popover

    /// Popover width (320pt)
    /// - 40 × 8 = perfect grid alignment
    /// - Comfortable for app names + controls
    /// - Matches Control Center width
    static let popoverWidth: CGFloat = 320

    /// Minimum popover height (200pt)
    /// - 25 × 8 = grid aligned
    /// - Prevents tiny popover with 1-2 apps
    static let popoverMinHeight: CGFloat = 200

    /// Maximum popover height (500pt)
    /// - ~63 × 8 = grid aligned
    /// - Caps growth with many apps
    /// - Prevents full-screen takeover
    static let popoverMaxHeight: CGFloat = 500

    /// Popover container padding (16pt)
    /// - Base padding for popover content
    /// - Matches Spacing.md
    static let popoverPadding: CGFloat = 16

    /// Popover corner radius (16pt)
    /// - Matches macOS Sonoma/Sequoia standard
    /// - Applied to background material
    static let popoverCornerRadius: CGFloat = 16

    // MARK: - Components

    /// Row height for app list items (44pt)
    /// - 11 × 4 = grid aligned
    /// - Apple HIG minimum touch target (44×44pt)
    /// - Matches Control Center, System Settings
    static let rowHeight: CGFloat = 44

    /// Header height (44pt)
    /// - Consistent with row height
    /// - Sufficient for title + count
    static let headerHeight: CGFloat = 44

    /// Footer height (56pt)
    /// - 7 × 8 = grid aligned
    /// - More padding than rows (visual weight for action)
    /// - Comfortable for primary button
    static let footerHeight: CGFloat = 56

    // MARK: - Elements

    /// App icon size (20pt)
    /// - Standard list icon size
    /// - Fits comfortably in 44pt row
    static let iconSize: CGFloat = 20

    /// Empty state icon size (56pt)
    /// - 7 × 8 = grid aligned
    /// - Larger for visual prominence
    static let iconSizeLarge: CGFloat = 56

    /// Icon to text spacing (12pt)
    /// - Comfortable spacing between icon and label
    /// - Matches Spacing.sm
    static let iconToText: CGFloat = 12

    /// Toggle visual width (28pt)
    /// - System toggle control size
    /// - Not a touch target (system manages that)
    static let toggleWidth: CGFloat = 28

    /// Button height (44pt)
    /// - Matches Apple HIG minimum touch target
    /// - Standard button height
    static let buttonHeight: CGFloat = 44

    /// Minimum touch target size (44pt)
    /// - Apple HIG accessibility requirement
    /// - Use for all interactive elements
    static let minimumTouchTarget: CGFloat = 44
}

/// Convenience calculations for adaptive height
extension Dimensions {
    /// Calculate adaptive popover height based on content
    /// - Parameter contentHeight: Height of all content
    /// - Returns: Clamped height between min and max
    static func adaptivePopoverHeight(for contentHeight: CGFloat) -> CGFloat {
        return min(max(contentHeight, popoverMinHeight), popoverMaxHeight)
    }

    /// Calculate adaptive popover height with screen bounds consideration
    /// - Parameters:
    ///   - contentHeight: Height of all content
    ///   - screenHeight: Available screen height
    /// - Returns: Clamped height that doesn't exceed screen bounds
    static func adaptivePopoverHeight(for contentHeight: CGFloat, screenHeight: CGFloat) -> CGFloat {
        let maxHeightForScreen = screenHeight - 100  // Leave 100pt margin
        let effectiveMax = min(popoverMaxHeight, maxHeightForScreen)
        return min(max(contentHeight, popoverMinHeight), effectiveMax)
    }
}
