//
//  Typography.swift
//  QuitAll
//
//  Typography system for consistent text styling
//  See SPEC-003: Typography System
//

import SwiftUI

/// Typography constants for text styling
///
/// Defines font styles for headers, body text, buttons, and numeric displays.
/// All fonts support Dynamic Type for accessibility.
///
/// Usage:
/// ```swift
/// Text("Running Apps")
///     .font(Typography.popoverTitle)
///     .foregroundColor(Colors.primary)
/// ```
enum Typography {
    // MARK: - Headers and Titles

    /// Popover title style (13pt Semibold)
    /// - Use for: Section headers like "Running Apps"
    /// - Combines well with Colors.primary
    static let popoverTitle = Font.system(size: 13, weight: .semibold)

    /// Empty state title style (15pt Semibold)
    /// - Use for: Empty state headlines like "No Apps Running"
    /// - Slightly larger for prominence
    static let emptyStateTitle = Font.system(size: 15, weight: .semibold)

    // MARK: - Body Text

    /// App name style (13pt Regular, Dynamic Type)
    /// - Use for: Application names in list
    /// - Scales with system text size preferences
    static let appName = Font.body

    /// Description style (13pt Regular, Dynamic Type)
    /// - Use for: Descriptive text, empty state bodies
    /// - Same as body but semantically named
    static let description = Font.body

    // MARK: - Secondary Text

    /// Subtitle style (11pt Regular, Dynamic Type)
    /// - Use for: Secondary information, metadata
    /// - Combines well with Colors.secondary
    static let subtitle = Font.subheadline

    /// Caption style (10pt Regular, Dynamic Type)
    /// - Use for: Status text, very minor details
    /// - Combines well with Colors.tertiary
    static let caption = Font.caption

    // MARK: - Numeric Display

    /// Count style (11pt Monospaced)
    /// - Use for: Numeric counts like app count
    /// - Monospaced digits prevent layout jitter
    /// - Example: "5 apps" where "5" uses this style
    static let count = Font.subheadline.monospacedDigit()

    // MARK: - Buttons

    /// Primary button text style (13pt Medium)
    /// - Use for: "Quit All Apps" and primary actions
    /// - Medium weight for emphasis
    static let buttonPrimary = Font.body.weight(.medium)

    /// Secondary button text style (13pt Regular)
    /// - Use for: Cancel, Back, and secondary actions
    /// - Regular weight for less emphasis
    static let buttonSecondary = Font.body
}

/// Typography usage extensions for common patterns
extension Typography {
    /// Header with count pattern
    /// - Use for: "Running Apps (5)" style headers
    /// - Returns tuple of (title font, count font)
    static var headerWithCount: (title: Font, count: Font) {
        (popoverTitle, count)
    }

    /// Empty state pattern
    /// - Use for: Empty state title + description
    /// - Returns tuple of (title font, body font)
    static var emptyState: (title: Font, body: Font) {
        (emptyStateTitle, description)
    }
}

/// View modifier for applying typography styles
extension View {
    /// Apply a typography style with appropriate color
    /// - Parameters:
    ///   - style: Typography constant
    ///   - color: Color to apply
    /// - Returns: Modified view with font and color
    func typographyStyle(_ style: Font, color: Color = Colors.primary) -> some View {
        self
            .font(style)
            .foregroundColor(color)
    }
}

/// Font weight reference
extension Font.Weight {
    /// Typography system uses limited weight palette:
    /// - Regular (400): Body text, app names
    /// - Medium (500): Primary buttons (optional)
    /// - Semibold (600): Headers, titles
    ///
    /// Do NOT use: Ultralight, Thin, Light, Bold, Heavy, Black
    static let typographyWeights: [Font.Weight] = [.regular, .medium, .semibold]
}
