//
//  CategoryDetailView.swift
//  ROME
//
//  The categories available for one species — the second level of the shop.
//

import SwiftUI

struct CategoryDetailView: View {

    let species: PetSpecies

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header

                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(Array(species.categories.enumerated()), id: \.element) { index, category in
                        NavigationLink(value: CategorySelection(species: species, category: category)) {
                            categoryTile(category)
                        }
                        .buttonStyle(.pressableCard)
                        .accessibilityIdentifier("category-\(category.rawValue)")
                        .staggeredAppear(index: index, stagger: 0.05)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColor.background)
        .navigationTitle(species.pluralName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: AppSpacing.lg) {
            Image(systemName: species.symbolName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(species.tint)
                .frame(width: 58, height: 58)
                .background(Circle().fill(species.tint.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text("Everything for \(species.pluralName.lowercased())")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(species.categories.count) categories")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, AppSpacing.sm)
    }

    private func categoryTile(_ category: ProductCategory) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Image(systemName: category.symbolName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColor.accentText)
                .frame(width: 46, height: 46)
                .background(Circle().fill(AppColor.accentSoft))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(category.displayName)
                    .font(AppFont.cardTitle)
                    .foregroundStyle(AppColor.textPrimary)

                Text(category.blurb)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(species: .reptile)
            .shopNavigationDestinations()
    }
    .environment(FavoritesStore())
    .environment(CartStore())
}
