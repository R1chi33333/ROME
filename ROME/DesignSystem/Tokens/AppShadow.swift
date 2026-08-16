//
//  AppShadow.swift
//  ROME
//
//  Design tokens — elevation.
//
//  Wide, faint, low-opacity shadows. The goal is the "floating card on white"
//  look of the reference design, where the card has no visible edge and only a
//  soft halo beneath it.
//

import SwiftUI

struct AppShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Barely-there lift for chips and small controls.
    static let sm = AppShadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)

    /// The default card elevation.
    static let card = AppShadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 8)

    /// Raised state — a card being pressed or dragged.
    static let raised = AppShadow(color: .black.opacity(0.10), radius: 32, x: 0, y: 14)

    /// Bars that float above scrolling content.
    static let bar = AppShadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -4)
}

extension View {
    /// Applies an `AppShadow` token.
    func appShadow(_ shadow: AppShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
