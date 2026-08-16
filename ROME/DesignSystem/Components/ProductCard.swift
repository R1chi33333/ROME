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

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    priceLabel
                    Spacer(minLength: AppSpacing.xs)
                    RatingLabel(rating: product.rating)
                }

                VStack(alignment: .leading, spacing: 2) {
                    priceLabel
                    RatingLabel(rating: product.rating)
                }
            }
        }
        .cardStyle(padding: AppSpacing.md)
    }

    private var priceLabel: some View {
        Text(product.formattedPrice)
            .font(AppFont.price)
            .foregroundStyle(AppColor.accentText)
            // A price is one token. Wrapping "$10.50" onto two lines makes it
            // unreadable, so it shrinks instead.
            .lineLimit(1)
            .minimumScaleFactor(0.7)
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
    @Environment(\.productZoomNamespace) private var zoomNamespace

    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: product) {
                ProductCard(product: product)
            }
            .buttonStyle(.pressableCard)
            .productZoomSource(product, in: zoomNamespace)
            .accessibilityIdentifier("product-\(product.name)")
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "\(product.name), \(product.category.displayName), \(product.formattedPrice), rated \(product.rating.formatted(.number.precision(.fractionLength(1)))) out of 5"
            )
            .accessibilityAddTraits(.isButton)

            FavoriteButton(isFavorite: favorites.binding(for: product))
                .padding(AppSpacing.md + AppSpacing.xs)
        }
        .scrollTransition(.interactive, axis: .vertical) { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.55)
                .scaleEffect(phase.isIdentity ? 1 : 0.92)
                .blur(radius: phase.isIdentity ? 0 : 1.4)
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
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                if let variant {
                    Text(variant)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }

                Text(product.formattedPrice)
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.accentText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
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
