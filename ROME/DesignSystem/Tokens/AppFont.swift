//
//  AppFont.swift
//  ROME
//
//  Design tokens — typography.
//
//  Every token is built from a semantic text style, which is what makes it
//  respond to Dynamic Type.
//
//  This was originally written as `Font.system(size:)` with hand-picked point
//  sizes, on the belief that SwiftUI scaled those the way it scales text
//  styles. It does not: that overload has no `relativeTo:` and produces a
//  fixed size. The app therefore had no Dynamic Type support at all, and the
//  failure was invisible — at the largest accessibility size nothing clipped,
//  because nothing grew.
//
//  The cost of the correction is that sizes now land on Apple's scale rather
//  than on the ones chosen by eye. That is the right trade: on iOS the text
//  styles *are* the type scale, and matching them is what lets the system
//  reason about the text.
//

import SwiftUI

enum AppFont {

    /// The single knob that sets the app's typographic character. Switching to
    /// `.rounded` restyles every screen.
    static let design: Font.Design = .default

    // MARK: - Display & headings

    /// Screen-owning titles, e.g. "Popular" on the shop home.
    static let display = Font.system(.largeTitle, design: design, weight: .bold)

    static let title = Font.system(.title2, design: design, weight: .bold)

    static let headline = Font.system(.title3, design: design, weight: .semibold)

    /// Section headers above a list or grid.
    static let sectionTitle = Font.system(.headline, design: design)

    // MARK: - Body

    static let body = Font.system(.body, design: design)

    static let bodyMedium = Font.system(.body, design: design, weight: .medium)

    static let callout = Font.system(.callout, design: design)

    static let subheadline = Font.system(.subheadline, design: design, weight: .medium)

    static let footnote = Font.system(.footnote, design: design)

    static let caption = Font.system(.caption, design: design, weight: .medium)

    // MARK: - Component-specific

    /// Product and pet names on cards.
    static let cardTitle = Font.system(.callout, design: design, weight: .semibold)

    /// Prices. Heavier so the number carries without needing colour.
    static let price = Font.system(.callout, design: design, weight: .bold)

    static let priceLarge = Font.system(.title, design: design, weight: .bold)

    /// Label inside a `PlaceholderThumbnail`, standing in for a product photo.
    static let thumbnailLabel = Font.system(.subheadline, design: design, weight: .semibold)

    static let button = Font.system(.body, design: design, weight: .semibold)

    static let chip = Font.system(.subheadline, design: design, weight: .medium)
}
