//
//  ProductDetailView.swift
//  ROME
//
//  Hero placeholder, price, rating, variants, quantity, add to cart.
//

import SwiftUI

struct ProductDetailView: View {

    let product: Product

    @Environment(CartStore.self) private var cart
    @Environment(FavoritesStore.self) private var favorites
    @Environment(\.showToast) private var showToast

    @State private var selectedVariant: String?
    @State private var quantity = 1

    private var alreadyInCart: Int {
        cart.quantity(of: product, variant: selectedVariant)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                hero

                titleBlock

                if !product.variants.isEmpty {
                    variantPicker
                }

                summaryBlock

                specsBlock
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.bottom, 140)
        }
        .background(AppColor.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: favorites.binding(for: product))
            }
        }
        .safeAreaInset(edge: .bottom) { addToCartBar }
        .onAppear {
            if selectedVariant == nil { selectedVariant = product.variants.first }
        }
    }

    // MARK: - Sections

    private var hero: some View {
        PlaceholderThumbnail(
            label: product.name,
            tint: product.primarySpecies.tint,
            size: .hero
        )
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .staggeredAppear(index: 0, offset: 18)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                StatusTag(text: product.category.displayName, style: .accent)

                ForEach(product.species, id: \.self) { species in
                    StatusTag(text: species.displayName, style: .neutral)
                }
            }

            Text(product.name)
                .font(AppFont.display)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: AppSpacing.lg) {
                Text(product.formattedPrice)
                    .font(AppFont.priceLarge)
                    .foregroundStyle(AppColor.accentText)

                RatingLabel(rating: product.rating, reviewCount: product.reviewCount, showsCount: true)
            }
        }
        .staggeredAppear(index: 1, offset: 14)
    }

    private var variantPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Size")
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            HStack(spacing: AppSpacing.sm) {
                ForEach(product.variants, id: \.self) { variant in
                    variantButton(variant)
                }
                Spacer(minLength: 0)
            }
        }
        .staggeredAppear(index: 2, offset: 14)
    }

    private func variantButton(_ variant: String) -> some View {
        let isSelected = selectedVariant == variant

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedVariant = variant
            }
        } label: {
            Text(variant)
                .font(AppFont.chip)
                .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textSecondary)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .background(
                    Capsule().fill(isSelected ? AppColor.accentSoft : AppColor.surface)
                )
                .overlay(
                    Capsule().strokeBorder(
                        isSelected ? AppColor.accent.opacity(0.4) : AppColor.border,
                        lineWidth: 1.5
                    )
                )
        }
        .buttonStyle(.pressable)
    }

    private var summaryBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("About this item")
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(product.summary)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .staggeredAppear(index: 3, offset: 14)
    }

    private var specsBlock: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Category", value: product.category.displayName, icon: product.category.symbolName)
            Divider().overlay(AppColor.divider)
            DetailRow(
                label: "Suitable for",
                value: product.species.map(\.displayName).joined(separator: ", "),
                icon: "pawprint"
            )
            Divider().overlay(AppColor.divider)
            DetailRow(label: "Rating", value: "\(product.rating.formatted(.number.precision(.fractionLength(1)))) / 5", icon: "star")
            Divider().overlay(AppColor.divider)
            DetailRow(label: "Reviews", value: product.reviewCount.formatted(), icon: "text.bubble")
        }
        .cardStyle()
        .staggeredAppear(index: 4, offset: 14)
    }

    private var addToCartBar: some View {
        HStack(spacing: AppSpacing.lg) {
            QuantityStepper(quantity: $quantity)

            PrimaryButton(title: "Add to Cart", icon: "bag.fill") {
                cart.add(product, variant: selectedVariant, quantity: quantity)
                showToast(
                    ToastMessage(text: "\(quantity) × \(product.name) added to cart")
                )
                quantity = 1
            }
        }
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
        .background {
            Rectangle()
                .fill(AppColor.background)
                .ignoresSafeArea()
                .appShadow(.bar)
        }
        .overlay(alignment: .top) {
            if alreadyInCart > 0 {
                Text("\(alreadyInCart) already in cart")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textTertiary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AppColor.surfaceSunken))
                    .offset(y: -10)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: alreadyInCart)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: SampleData.featured[0])
    }
    .environment(CartStore())
    .environment(FavoritesStore())
}
