//
//  AppFont.swift
//  ROME
//
//  Design tokens — typography.
//
//  System font (SF) throughout: no bundled font files, no licensing, no
//  download size. SwiftUI's `Font.system(size:)` already scales with Dynamic
//  Type (unlike UIKit's `UIFont.systemFont`), so these fixed sizes are the
//  reference sizes at the default content size and grow from there.
//
//  To give the whole app a rounder, friendlier voice, change `design` to
//  `.rounded` — that single edit restyles every screen.
//

import SwiftUI

enum AppFont {

    /// The single knob that sets the app's typographic character.
    static let design: Font.Design = .default

    // MARK: - Display & headings

    /// Screen-owning titles, e.g. "Popular" on the shop home.
    static let display = Font.system(size: 32, weight: .bold, design: design)

    static let title = Font.system(size: 24, weight: .bold, design: design)

    static let headline = Font.system(size: 19, weight: .semibold, design: design)

    /// Section headers above a list or grid.
    static let sectionTitle = Font.system(size: 17, weight: .semibold, design: design)

    // MARK: - Body

    static let body = Font.system(size: 16, weight: .regular, design: design)

    static let bodyMedium = Font.system(size: 16, weight: .medium, design: design)

    static let callout = Font.system(size: 15, weight: .regular, design: design)

    static let subheadline = Font.system(size: 14, weight: .medium, design: design)

    static let footnote = Font.system(size: 13, weight: .regular, design: design)

    static let caption = Font.system(size: 12, weight: .medium, design: design)

    // MARK: - Component-specific

    /// Product and pet names on cards.
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: design)

    /// Prices. Slightly heavier so the number carries without needing colour.
    static let price = Font.system(size: 16, weight: .bold, design: design)

    static let priceLarge = Font.system(size: 26, weight: .bold, design: design)

    /// Label inside a `PlaceholderThumbnail`, standing in for a product photo.
    static let thumbnailLabel = Font.system(size: 15, weight: .semibold, design: design)

    static let button = Font.system(size: 16, weight: .semibold, design: design)

    static let chip = Font.system(size: 14, weight: .medium, design: design)
}
