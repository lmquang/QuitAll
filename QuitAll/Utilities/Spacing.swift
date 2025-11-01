//
//  Spacing.swift
//  QuitAll
//
//  Design system spacing constants following 8-point grid
//  See SPEC-002: Layout & Spacing System
//

import Foundation

/// Spacing constants for the 8-point grid system
///
/// All spacing values follow multiples of 4 or 8 to maintain visual rhythm and consistency.
/// Use these constants throughout the app instead of magic numbers.
///
/// Usage:
/// ```swift
/// VStack(spacing: Spacing.xs) {  // 8pt spacing
///     // content
/// }
/// .padding(Spacing.md)  // 16pt padding
/// ```
enum Spacing {
    /// Extra extra small spacing (4pt)
    /// - Use for: Fine-tuning, tight internal component spacing
    /// - Examples: Minimal gaps between closely related elements
    static let xxs: CGFloat = 4

    /// Extra small spacing (8pt)
    /// - Use for: Default element spacing, vertical stack spacing
    /// - Examples: Spacing between list items, default VStack spacing
    static let xs: CGFloat = 8

    /// Small spacing (12pt)
    /// - Use for: Comfortable spacing between related elements
    /// - Examples: Icon to text distance, element to element
    static let sm: CGFloat = 12

    /// Medium spacing (16pt)
    /// - Use for: Section spacing, base container padding
    /// - Examples: Container padding, section breaks, row padding
    static let md: CGFloat = 16

    /// Large spacing (24pt)
    /// - Use for: Major section breaks, significant visual separation
    /// - Examples: Between major sections, large gaps
    static let lg: CGFloat = 24

    /// Extra large spacing (32pt)
    /// - Use for: Very large container padding (rarely needed in menu bar apps)
    /// - Examples: Unused in compact popover UI
    static let xl: CGFloat = 32
}

/// Convenience extensions for common spacing patterns
extension Spacing {
    /// Horizontal padding for container edges
    static let containerHorizontal: CGFloat = md  // 16pt

    /// Vertical padding for container edges
    static let containerVertical: CGFloat = md  // 16pt

    /// Icon to text spacing
    static let iconToText: CGFloat = sm  // 12pt

    /// Row internal padding (horizontal)
    static let rowHorizontalPadding: CGFloat = xs  // 8pt

    /// Row internal padding (vertical)
    static let rowVerticalPadding: CGFloat = xs  // 8pt
}
