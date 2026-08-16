//
//  CardStyle.swift
//  ROME
//
//  The surface treatment shared by every card in the app.
//

import SwiftUI

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppSpacing.lg
    var radius: CGFloat = AppRadius.lg
    var shadow: AppShadow = .card

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppColor.surface)
            )
            .appShadow(shadow)
    }
}

extension View {
    /// Wraps the view in the standard card surface: white fill, large
    /// continuous corners, soft shadow.
    func cardStyle(
        padding: CGFloat = AppSpacing.lg,
        radius: CGFloat = AppRadius.lg,
        shadow: AppShadow = .card
    ) -> some View {
        modifier(CardStyle(padding: padding, radius: radius, shadow: shadow))
    }
}
