//
//  PlaceholderThumbnail.swift
//  ROME
//
//  Stands in for a product photo by showing the product's name as text.
//
//  This view deliberately occupies the exact frame and aspect ratio a real
//  image will occupy later, so dropping in an `AsyncImage` is a change to this
//  file alone — no layout anywhere else moves.
//

import SwiftUI

struct PlaceholderThumbnail: View {

    let label: String
    let tint: Color

    /// Larger contexts (the product detail hero) want bigger text than a grid
    /// card does.
    var size: Size = .card

    /// Shown instead of `label` at `.row` size, where the tile is too small
    /// for the name to be legible — and where the name already appears as the
    /// row's title, so repeating it would just truncate the same words twice.
    var symbolName: String?

    enum Size: Equatable {
        case card
        case hero
        case row

        var font: Font {
            switch self {
            case .card: return AppFont.thumbnailLabel
            case .hero: return AppFont.title
            case .row: return AppFont.caption
            }
        }

        var radius: CGFloat {
            switch self {
            case .card: return AppRadius.md
            case .hero: return AppRadius.xl
            case .row: return AppRadius.base
            }
        }

        var padding: CGFloat {
            switch self {
            case .card: return AppSpacing.md
            case .hero: return AppSpacing.xl
            case .row: return AppSpacing.sm
            }
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: size.radius, style: .continuous)
            // Opaque base under the tint. Without it the block is a wash of
            // the same hue as the ambient background behind it and the product
            // dissolves into the page.
            .fill(AppColor.surface)
            .overlay {
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .fill(tint.opacity(0.16))
            }
            .overlay {
                // A hairline of the same hue keeps the block from dissolving
                // into a white card on light backgrounds.
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .strokeBorder(tint.opacity(0.16), lineWidth: 1)
            }
            .overlay {
                if size == .row, let symbolName {
                    Image(systemName: symbolName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(tint)
                } else {
                    Text(label)
                        .font(size.font)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        .padding(size.padding)
                }
            }
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Pet monogram

/// The pet equivalent: a circle carrying the pet's first initial.
struct PetMonogram: View {

    let pet: Pet
    var diameter: CGFloat = 52

    var body: some View {
        Circle()
            .fill(pet.species.tint.opacity(0.14))
            .overlay {
                Circle().strokeBorder(pet.species.tint.opacity(0.2), lineWidth: 1)
            }
            .overlay {
                Text(pet.monogram)
                    .font(.system(size: diameter * 0.4, weight: .semibold, design: AppFont.design))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .frame(width: diameter, height: diameter)
    }
}

#Preview("Thumbnails") {
    VStack(spacing: AppSpacing.xl) {
        HStack(spacing: AppSpacing.md) {
            PlaceholderThumbnail(label: "Cat Food", tint: PetSpecies.cat.tint)
            PlaceholderThumbnail(label: "Terrarium Moss", tint: PetSpecies.amphibian.tint)
        }
        .frame(height: 150)

        PlaceholderThumbnail(label: "Adult Dog Food", tint: PetSpecies.dog.tint, size: .hero)
            .frame(height: 220)

        HStack(spacing: AppSpacing.lg) {
            ForEach(SampleData.pets) { pet in
                PetMonogram(pet: pet)
            }
        }
    }
    .padding()
    .background(AppColor.background)
}
