//
//  RatingLabel.swift
//  ROME
//
//  Star plus numeric rating. One of the few places the app uses colour for
//  emphasis, and the number is always present so the colour is never the only
//  carrier of the information.
//

import SwiftUI

struct RatingLabel: View {

    let rating: Double
    var reviewCount: Int?
    var showsCount: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundStyle(AppColor.rating)

            Text(rating.formatted(.number.precision(.fractionLength(1))))
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textPrimary)

            if showsCount, let reviewCount {
                Text("(\(reviewCount.formatted(.number.notation(.compactName))))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let base = "Rated \(rating.formatted(.number.precision(.fractionLength(1)))) out of 5"
        guard showsCount, let reviewCount else { return base }
        return base + ", \(reviewCount) reviews"
    }
}

// MARK: - Favourite toggle

/// Heart that springs and fills when tapped.
struct FavoriteButton: View {

    @Binding var isFavorite: Bool

    @State private var pulse: CGFloat = 1

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.5)) {
                isFavorite.toggle()
            }
            // A separate, faster pop layered on top of the fill change.
            withAnimation(.spring(response: 0.18, dampingFraction: 0.45)) {
                pulse = 1.35
            } completion: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                    pulse = 1
                }
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isFavorite ? AppColor.accent : AppColor.textTertiary)
                .scaleEffect(pulse)
                .frame(width: 34, height: 34)
                .background(Circle().fill(AppColor.surface.opacity(0.9)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
    }
}

#Preview("Rating") {
    @Previewable @State var favorite = false

    return HStack(spacing: AppSpacing.xl) {
        RatingLabel(rating: 4.5)
        RatingLabel(rating: 4.8, reviewCount: 1832, showsCount: true)
        FavoriteButton(isFavorite: $favorite)
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
