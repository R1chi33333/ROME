//
//  HomeView.swift
//  ROME
//
//  The shop landing screen: search, species filter, promo, product grid.
//

import SwiftUI

struct HomeView: View {

    @Environment(AuthState.self) private var auth
    @Environment(PetStore.self) private var pets
    @Environment(\.dataStore) private var dataStore

    @State private var selectedSpecies: PetSpecies?
    @State private var searchText = ""
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var isPromptingSignIn = false

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        PawRefreshScrollView {
            await refresh()
        } content: {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                topBar
                    .padding(.horizontal, AppSpacing.screenGutter)

                searchField
                    .padding(.horizontal, AppSpacing.screenGutter)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SubsectionHeader(title: "Shop by Pet")
                        .padding(.horizontal, AppSpacing.screenGutter)

                    // Chip row manages its own horizontal gutter so the pills
                    // can bleed to the screen edge as they scroll.
                    SpeciesChipRow(selection: $selectedSpecies, preferred: pets.ownedSpecies)
                }

                PromoBanner(
                    headline: promoHeadline,
                    subheadline: "Free delivery on orders over $50.",
                    tag: "This week"
                ) {}
                .padding(.horizontal, AppSpacing.screenGutter)

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sectionTitle)
                                .font(AppFont.display)
                                .foregroundStyle(AppColor.textPrimary)

                            if let sectionSubtitle {
                                Text(sectionSubtitle)
                                    .font(AppFont.footnote)
                                    .foregroundStyle(AppColor.textSecondary)
                            }
                        }

                        Spacer(minLength: AppSpacing.md)

                        // Only meaningful once a species is chosen — that is
                        // what gives the category grid something to list.
                        if let selectedSpecies {
                            NavigationLink(value: selectedSpecies) {
                                HStack(spacing: AppSpacing.xs) {
                                    Text("categories")
                                        .font(AppFont.subheadline)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(AppColor.textSecondary)
                            }
                            .buttonStyle(.pressable)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                    }

                    if isLoading {
                        loadingGrid
                    } else if visibleProducts.isEmpty {
                        EmptyState(
                            systemName: "magnifyingglass",
                            title: "Nothing matches",
                            message: "Try a different pet or clear the search."
                        )
                    } else {
                        grid
                    }
                }
                .padding(.horizontal, AppSpacing.screenGutter)
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, .tabBarClearance)
        }
        .background(AmbientBackground(tint: ambientTint, extent: 0.42, intensity: 0.26))
        .navigationBarHidden(true)
        .shopNavigationDestinations()
        .sheet(isPresented: $isPromptingSignIn) {
            AuthPromptView(reason: "save your pets and favourites")
        }
        .task {
            // Applied once, on the first appearance after onboarding.
            if let species = auth.consumeOnboardingSpecies() {
                selectedSpecies = species
            }
            await loadProducts()
        }
        .task(id: selectedSpecies) { await loadProducts() }
        // A guest owns no pets, so there is nothing to fetch — and fetching
        // anyway would put someone else's sample pets in the greeting.
        .task(id: auth.isGuest) {
            guard !auth.isGuest else { return }
            await pets.load()
        }
    }

    // MARK: - Sections

    private var topBar: some View {
        HStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)

                Text(auth.currentUser?.name ?? "Guest")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer(minLength: 0)

            IconButton(
                systemName: "bell",
                background: AppColor.surface
            ) {}
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(AppColor.accent)
                    .frame(width: 8, height: 8)
                    .offset(x: -3, y: 3)
            }

            avatar
        }
    }

    /// Initials once there is an account; for a guest it becomes the way in,
    /// since a "?" that does nothing is just a puzzle.
    @ViewBuilder
    private var avatar: some View {
        if let user = auth.currentUser {
            Circle()
                .fill(AppColor.accentSoft)
                .frame(width: 42, height: 42)
                .overlay {
                    Text(user.initials)
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.accentText)
                }
        } else {
            Button {
                isPromptingSignIn = true
            } label: {
                Text("Sign In")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.onInk)
                    .padding(.horizontal, AppSpacing.md)
                    .frame(minHeight: 42)
                    .padding(.vertical, AppSpacing.sm)
                    .background(Capsule().fill(AppColor.ink))
            }
            .buttonStyle(.pressable)
            .accessibilityIdentifier("home-sign-in")
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColor.textTertiary)

            TextField("Search food, toys, habitat…", text: $searchText)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    withAnimation(.smooth(duration: 0.2)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColor.textTertiary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .frame(minHeight: 54)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .fill(AppColor.surface)
                .appShadow(.sm)
        )
        .animation(.smooth(duration: 0.2), value: searchText.isEmpty)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(Array(visibleProducts.enumerated()), id: \.element.id) { index, product in
                ProductGridItem(product: product)
                    .staggeredAppear(index: min(index, 7), stagger: 0.045)
            }
        }
    }

    private var loadingGrid: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SkeletonBlock(height: 130, radius: AppRadius.md)
                    SkeletonBlock(height: 14)
                    SkeletonBlock(height: 14, radius: AppRadius.sm)
                        .frame(width: 70)
                }
                .cardStyle(padding: AppSpacing.md)
            }
        }
    }

    // MARK: - Derived state

    private var visibleProducts: [Product] {
        guard !searchText.isEmpty else { return products }
        let query = searchText.lowercased()
        return products.filter {
            $0.name.lowercased().contains(query)
            || $0.category.displayName.lowercased().contains(query)
        }
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var sectionTitle: String {
        selectedSpecies.map { "For \($0.pluralName)" } ?? "Popular"
    }

    private var sectionSubtitle: String? {
        isLoading ? nil : "\(visibleProducts.count) items"
    }

    /// Neutral until a species is chosen; after that the page carries that
    /// animal's colour.
    private var ambientTint: Color {
        selectedSpecies?.tint ?? AppColor.accent
    }

    private var promoHeadline: String {
        guard let first = pets.pets.first else { return "20% off your first order" }
        return "Restock \(first.name)'s favourites"
    }

    // MARK: - Loading

    private func loadProducts(showingSkeleton: Bool = true) async {
        if showingSkeleton { isLoading = true }

        let loaded: [Product]
        if let selectedSpecies {
            loaded = (try? await dataStore.products(species: selectedSpecies, category: nil)) ?? []
        } else {
            loaded = (try? await dataStore.featuredProducts()) ?? []
        }
        products = loaded
        withAnimation(.smooth(duration: 0.3)) { isLoading = false }
    }

    /// Pull to refresh. The paw is the progress indicator here, so the skeleton
    /// stays out of the way — swapping the grid for placeholders behind an
    /// indicator that is already saying "working" just makes the screen flash.
    private func refresh() async {
        await loadProducts(showingSkeleton: false)
        // A refresh that returns instantly reads as a no-op. The mock store is
        // fast; hold the paw long enough for the animation to be legible.
        try? await Task.sleep(for: .milliseconds(500))
    }
}

/// Reads the shared namespace out of the environment and applies the zoom.
/// A wrapper because `navigationTransition` has to be attached inside the
/// destination builder, where the environment is available.
private struct ProductDetailZoomWrapper: View {

    let product: Product

    @Environment(\.productZoomNamespace) private var zoomNamespace

    var body: some View {
        ProductDetailView(product: product)
            .productZoomDestination(product, in: zoomNamespace)
    }
}

/// Navigation payload for "this species, this category".
struct CategorySelection: Hashable {
    let species: PetSpecies
    let category: ProductCategory
}

extension View {
    /// The shop's three navigation destinations. Applied once per stack, at
    /// the root, so any depth can push by value.
    func shopNavigationDestinations() -> some View {
        self
            .navigationDestination(for: Product.self) { product in
                ProductDetailZoomWrapper(product: product)
            }
            .navigationDestination(for: PetSpecies.self) { species in
                CategoryDetailView(species: species)
            }
            .navigationDestination(for: CategorySelection.self) { selection in
                ProductListView(species: selection.species, category: selection.category)
            }
    }
}
