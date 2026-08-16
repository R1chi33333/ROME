//
//  ProductCard.swift
//  ROME
//
//  Grid card: placeholder thumbnail, favourite heart, name, price, rating.
//

import SwiftUI

/// The card surface on its own, with no tap handling. Callers wrap it — see
/// `ProductGridItem` for the standard composition.
struct ProductCard: View {

    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // The thumbnail carries the product name, standing in for the
            // photo. There is deliberately no separate title line beneath it —
            // that would print the same words twice. When real images land,
            // restore a `Text(product.name)` here alongside the image.
            PlaceholderThumbnail(
                label: product.name,
                tint: product.primarySpecies.tint
            )

            Text(product.category.displayName)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textTertiary)

            HStack(alignment: .firstTextBaseline) {
                Text(product.formattedPrice)
                    .font(AppFont.price)
                    .foregroundStyle(AppColor.accentText)

                Spacer(minLength: AppSpacing.xs)

                RatingLabel(rating: product.rating)
            }
        }
        .cardStyle(padding: AppSpacing.md)
    }
}

// MARK: - Grid item

/// Card plus navigation plus favourite heart.
///
/// The heart is layered on top of the `NavigationLink` rather than inside its
/// label: a button nested in a link's label does not reliably receive taps,
/// so the two controls have to be siblings.
struct ProductGridItem: View {

    let product: Product

    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: product) {
                ProductCard(product: product)
            }
            .buttonStyle(.pressableCard)
            .accessibilityIdentifier("product-\(product.name)")

            FavoriteButton(isFavorite: favorites.binding(for: product))
                .padding(AppSpacing.md + AppSpacing.xs)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Row variant

/// Horizontal layout used in the cart and in dense lists.
struct ProductRow<Trailing: View>: View {

    let product: Product
    var variant: String?
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            PlaceholderThumbnail(
                label: product.name,
                tint: product.primarySpecies.tint,
                size: .row,
                symbolName: product.category.symbolName
            )
            .frame(width: 68, height: 68)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(product.name)
                    .font(AppFont.cardTitle)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let variant {
                    Text(variant)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }

                Text(product.formattedPrice)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.accentText)
            }

            Spacer(minLength: AppSpacing.sm)

            trailing()
        }
    }
}

extension ProductRow where Trailing == EmptyView {
    init(product: Product, variant: String? = nil) {
        self.init(product: product, variant: variant) { EmptyView() }
    }
}

#Preview("Product card") {
    NavigationStack {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.md),
                          GridItem(.flexible(), spacing: AppSpacing.md)],
                spacing: AppSpacing.md
            ) {
                ForEach(SampleData.featured.prefix(4)) { product in
                    ProductGridItem(product: product)
                }
            }
            .padding(AppSpacing.screenGutter)

            VStack(spacing: AppSpacing.lg) {
                ForEach(SampleData.featured.prefix(3)) { product in
                    ProductRow(product: product, variant: "Medium")
                }
            }
            .padding(AppSpacing.screenGutter)
        }
        .background(AppColor.background)
    }
    .environment(FavoritesStore())
}
