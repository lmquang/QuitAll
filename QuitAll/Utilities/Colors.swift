//
//  Colors.swift
//  QuitAll
//
//  Semantic color system for consistent theming
//  See SPEC-001: Visual Foundation, section 3.1
//

import SwiftUI
import AppKit

/// Semantic color constants that adapt to light/dark mode
///
/// All colors use system semantic colors that automatically adjust for:
/// - Light/Dark mode
/// - Increase Contrast accessibility setting
/// - System accent color preferences
///
/// Usage:
/// ```swift
/// Text("App Name")
///     .foregroundColor(Colors.primary)
/// ```
enum Colors {
    // MARK: - Text Colors

    /// Primary text color (85%/95% opacity)
    /// - Use for: App names, headers, main content
    /// - Contrast: 4.5:1+ (WCAG AA)
    static let primary = Color(.labelColor)

    /// Secondary text color (75% opacity)
    /// - Use for: Counts, subtitles, supporting information
    /// - Contrast: 4.5:1+ (WCAG AA)
    static let secondary = Color(.secondaryLabelColor)

    /// Tertiary text color (50% opacity)
    /// - Use for: Placeholders, de-emphasized content
    /// - Contrast: 3:1+ (WCAG A)
    static let tertiary = Color(.tertiaryLabelColor)

    /// Quaternary text color (25% opacity)
    /// - Use for: Disabled text only
    /// - Contrast: <3:1 (Not WCAG compliant - use sparingly)
    static let quaternary = Color(.quaternaryLabelColor)

    // MARK: - Background Colors

    /// Window background color
    /// - Use for: Reduce Transparency fallback
    /// - Adapts to light/dark mode
    static let windowBackground = Color(.windowBackgroundColor)

    /// Control background color
    /// - Use for: Buttons, toggles, interactive controls
    /// - Adapts to light/dark mode
    static let controlBackground = Color(.controlBackgroundColor)

    /// Separator color
    /// - Use for: Dividers, borders
    /// - Low contrast, subtle separation
    static let separator = Color(.separatorColor)

    // MARK: - Accent Colors

    /// System accent color
    /// - Use for: Non-destructive interactive elements
    /// - User-customizable in System Preferences
    static let accent = Color.accentColor

    /// Destructive action color (red)
    /// - Use for: "Quit All" button, delete actions
    /// - Always red, regardless of accent color
    static let destructive = Color.red

    // MARK: - Hover/Selection Colors

    /// Hover overlay color
    /// - Use for: Hover effects on rows
    /// - Light: 5% black, Dark: 5% white
    static let hoverOverlay = Color.gray.opacity(0.05)

    /// Selection color
    /// - Use for: Selected rows, highlighted items
    /// - Uses system accent color
    static let selection = Color.accentColor.opacity(0.15)
}

/// Convenience extensions for common color patterns
extension Colors {
    /// Color for system-protected apps (dimmed)
    static let systemProtected = Color.gray.opacity(0.6)

    /// Background for empty states
    static let emptyStateBackground = Color.clear

    /// Border color for fallback mode
    static let fallbackBorder = Color.gray.opacity(0.2)
}

/// NSColor convenience accessors for AppKit interop
extension Colors {
    /// NSColor variants for AppKit components
    enum NS {
        static let primary: NSColor = .labelColor
        static let secondary: NSColor = .secondaryLabelColor
        static let tertiary: NSColor = .tertiaryLabelColor
        static let quaternary: NSColor = .quaternaryLabelColor
        static let windowBackground: NSColor = .windowBackgroundColor
        static let controlBackground: NSColor = .controlBackgroundColor
        static let separator: NSColor = .separatorColor
    }
}
