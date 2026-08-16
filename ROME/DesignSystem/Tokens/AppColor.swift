//
//  AppColor.swift
//  ROME
//
//  Design tokens — color.
//
//  Palette: white-first, minimal, with orange used sparingly as an accent.
//
//  ACCESSIBILITY CONSTRAINT (measured, do not violate):
//    white on orange500  2.84:1  ✗ fails WCAG AA
//    white on orange700  4.98:1  ✓ AA normal text
//    orange500 on white  2.84:1  ✗ unusable for small text
//    orange700 on white  4.98:1  ✓ AA normal text
//    white on ink        ~18:1   ✓ AAA
//
//  Therefore: primary actions use `ink` (near-black) fills with white text.
//  Orange is reserved for accents — selected chips, prices, rating stars,
//  favourite hearts, badges. When orange must carry text, use `accentText`.
//

import SwiftUI

enum AppColor {

    // MARK: - Accent ramp (orange)

    static let accent50 = Color(hex: 0xFFF6F3)
    static let accent100 = Color(hex: 0xFFEDE7)
    static let accent200 = Color(hex: 0xFFD9CA)
    static let accent300 = Color(hex: 0xFFBEA6)
    static let accent400 = Color(hex: 0xFF9772)
    static let accent500 = Color(hex: 0xFF6B35)
    static let accent600 = Color(hex: 0xDE5E30)
    static let accent700 = Color(hex: 0xB8502B)
    static let accent800 = Color(hex: 0x8D4025)
    static let accent900 = Color(hex: 0x62301F)

    /// The accent at full strength. Fills and glyphs only — never small text.
    static let accent = accent500

    /// Accent tuned for text on a light background, and for fills that carry
    /// white text. Passes AA at normal size.
    static let accentText = accent700

    /// Very light accent wash for selected chips and highlighted rows.
    static let accentSoft = accent100

    // MARK: - Neutral ramp

    static let neutral50 = Color(hex: 0xF9FAFB)
    static let neutral100 = Color(hex: 0xF3F4F6)
    static let neutral200 = Color(hex: 0xE5E7EB)
    static let neutral300 = Color(hex: 0xD1D5DB)
    static let neutral400 = Color(hex: 0x9CA3AF)
    static let neutral500 = Color(hex: 0x6B7280)
    static let neutral600 = Color(hex: 0x4B5563)
    static let neutral700 = Color(hex: 0x374151)
    static let neutral800 = Color(hex: 0x1F2937)
    static let neutral900 = Color(hex: 0x111827)

    // MARK: - Semantic surfaces (light / dark pairs)

    /// Page background. Very slightly off-white so white cards separate from it.
    static let background = Color(light: 0xF7F7F8, dark: 0x0B0B0C)

    /// Card and sheet surfaces.
    static let surface = Color(light: 0xFFFFFF, dark: 0x1A1A1C)

    /// A surface nested inside another surface (e.g. a field inside a card).
    static let surfaceSunken = Color(light: 0xF3F4F6, dark: 0x232326)

    /// Near-black. The primary action fill — see the constraint note above.
    static let ink = Color(light: 0x111113, dark: 0xF5F5F7)

    /// Text on top of `ink`.
    static let onInk = Color(light: 0xFFFFFF, dark: 0x111113)

    // MARK: - Text

    static let textPrimary = Color(light: 0x111827, dark: 0xF5F5F7)
    static let textSecondary = Color(light: 0x6B7280, dark: 0x9CA3AF)
    static let textTertiary = Color(light: 0x9CA3AF, dark: 0x6B7280)

    // MARK: - Lines

    static let divider = Color(light: 0xE5E7EB, dark: 0x2C2C30)
    static let border = Color(light: 0xE5E7EB, dark: 0x333338)

    // MARK: - Status

    static let success = Color(hex: 0x0E9F6E)
    static let warning = Color(hex: 0xD97706)
    static let error = Color(hex: 0xDC2626)

    /// Rating stars. Warmer than the accent so the two never read as the same token.
    static let rating = Color(hex: 0xF5A524)
}

// MARK: - Hex helpers

extension Color {

    /// Builds a color from a 24-bit RGB literal, e.g. `Color(hex: 0xFF6B35)`.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    /// Builds a color that resolves differently in light and dark appearance.
    init(light: UInt32, dark: UInt32) {
        self.init(
            uiColor: UIColor { traits in
                let value = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(
                    red: CGFloat((value >> 16) & 0xFF) / 255,
                    green: CGFloat((value >> 8) & 0xFF) / 255,
                    blue: CGFloat(value & 0xFF) / 255,
                    alpha: 1
                )
            }
        )
    }
}
