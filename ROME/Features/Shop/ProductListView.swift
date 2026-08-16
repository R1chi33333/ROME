//
//  ProductListView.swift
//  ROME
//
//  Products for one species + category pair, with a sort control.
//

import SwiftUI

struct ProductListView: View {

    let species: PetSpecies
    let category: ProductCategory

    @Environment(\.dataStore) private var dataStore

    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var sort: SortOrder = .popular

    enum SortOrder: String, CaseIterable, Identifiable {
        case popular = "Popular"
        case priceLow = "Price: low"
        case priceHigh = "Price: high"

        var id: String { rawValue }
    }

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                sortBar

                if isLoading {
                    loadingGrid
                } else if products.isEmpty {
                    EmptyState(
                        systemName: category.symbolName,
                        title: "Nothing here yet",
                        message: "We have no \(category.displayName.lowercased()) for \(species.pluralName.lowercased()) in stock right now."
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(Array(sortedProducts.enumerated()), id: \.element.id) { index, product in
                            ProductGridItem(product: product)
                                .staggeredAppear(index: min(index, 7), stagger: 0.045)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColor.background)
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .task { await load() }
    }

    private var sortBar: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("\(products.count) items")
                .font(AppFont.footnote)
                .foregroundStyle(AppColor.textSecondary)

            Spacer(minLength: AppSpacing.md)

            Menu {
                Picker("Sort", selection: $sort) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .semibold))
                    Text(sort.rawValue)
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(Capsule().fill(AppColor.surface).appShadow(.sm))
            }
        }
    }

    private var loadingGrid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SkeletonBlock(height: 130, radius: AppRadius.md)
                    SkeletonBlock(height: 14)
                    SkeletonBlock(height: 14, radius: AppRadius.sm).frame(width: 70)
                }
                .cardStyle(padding: AppSpacing.md)
            }
        }
    }

    private var sortedProducts: [Product] {
        switch sort {
        case .popular: return products.sorted { $0.reviewCount > $1.reviewCount }
        case .priceLow: return products.sorted { $0.price < $1.price }
        case .priceHigh: return products.sorted { $0.price > $1.price }
        }
    }

    private func load() async {
        isLoading = true
        products = (try? await dataStore.products(species: species, category: category)) ?? []
        withAnimation(.smooth(duration: 0.3)) { isLoading = false }
    }
}

#Preview {
    NavigationStack {
        ProductListView(species: .cat, category: .toys)
            .shopNavigationDestinations()
    }
    .environment(FavoritesStore())
    .environment(CartStore())
}
