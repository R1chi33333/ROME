//
//  AppSpacing.swift
//  ROME
//
//  Design tokens — spacing, on an 8pt grid.
//

import Foundation

enum AppSpacing {

    /// 4 — icon-to-label gaps, tight inline pairs.
    static let xs: CGFloat = 4

    /// 8 — inner padding of small controls.
    static let sm: CGFloat = 8

    /// 12 — gap between grid items.
    static let md: CGFloat = 12

    /// 16 — card padding, standard screen gutter.
    static let lg: CGFloat = 16

    /// 24 — gap between stacked cards, spacing inside a section.
    static let xl: CGFloat = 24

    /// 32 — gap between sections.
    static let xxl: CGFloat = 32

    /// 48 — major breaks, space above a lone call to action.
    static let xxxl: CGFloat = 48

    /// Horizontal inset every screen shares, so content lines up across tabs.
    static let screenGutter: CGFloat = 20
}
