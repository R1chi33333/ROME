//
//  AppRadius.swift
//  ROME
//
//  Design tokens — corner radius.
//
//  Generous radii: the reference design leans on large, soft corners rather
//  than borders to separate surfaces.
//

import Foundation

enum AppRadius {

    /// 8 — badges, small tags.
    static let sm: CGFloat = 8

    /// 16 — text fields, buttons, chips with square-ish ends.
    static let base: CGFloat = 16

    /// 20 — thumbnails, inner panels.
    static let md: CGFloat = 20

    /// 24 — cards.
    static let lg: CGFloat = 24

    /// 32 — promo banners, sheets, hero surfaces.
    static let xl: CGFloat = 32

    /// Fully rounded ends. Applied via `Capsule()` rather than this value where
    /// possible; kept here for cases needing an explicit number.
    static let full: CGFloat = 999
}
