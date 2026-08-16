//
//  CartView.swift
//  ROME
//

import SwiftUI

struct CartView: View {

    @Environment(CartStore.self) private var cart
    @Environment(\.switchToTab) private var switchToTab

    /// Pushed by value rather than with `navigationDestination(isPresented:)`,
    /// because only value-based pushes land in the stack's `NavigationPath` —
    /// and `RootTabView` reads that path to know when to hide the tab bar.
    struct CheckoutRoute: Hashable {}

    var body: some View {
        Group {
            if cart.isEmpty {
                EmptyState(
                    systemName: "bag",
                    title: "Your cart is empty",
                    message: "Browse the shop and add something your pet will actually use.",
                    actionTitle: "Start Shopping"
                ) {
                    switchToTab(.shop)
                }
                .frame(maxHeight: .infinity)
            } else {
                filledCart
            }
        }
        .background(AppColor.background)
        .navigationTitle("Cart")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbar {
            if !cart.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        cart.clear()
                    }
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.error)
                }
            }
        }
        .navigationDestination(for: CheckoutRoute.self) { _ in
            CheckoutView()
        }
    }

    private var filledCart: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(Array(cart.items.enumerated()), id: \.element.id) { index, item in
                    cartRow(item)
                        .staggeredAppear(index: min(index, 6), stagger: 0.04)
                }

                summaryCard
                    .padding(.top, AppSpacing.md)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xl)
        }
        .safeAreaInset(edge: .bottom) { checkoutBar }
    }

    private func cartRow(_ item: CartItem) -> some View {
        ProductRow(product: item.product, variant: item.variant) {
            QuantityStepper(
                quantity: Binding(
                    get: { item.quantity },
                    set: { cart.setQuantity($0, for: item) }
                ),
                minimum: 0,
                compact: true
            )
        }
        .cardStyle()
        .overlay(alignment: .topTrailing) {
            Text(item.formattedLineTotal)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textTertiary)
                .padding(AppSpacing.md)
        }
        .swipeActionsCompat {
            cart.remove(item)
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)
        ))
    }

    private var summaryCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Subtotal", value: cart.formattedSubtotal)
            Divider().overlay(AppColor.divider)
            DetailRow(label: "Delivery", value: cart.formattedShipping)

            if cart.shipping > 0 {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                    Text("Free delivery over $50")
                        .font(AppFont.caption)
                    Spacer()
                }
                .foregroundStyle(AppColor.textTertiary)
                .padding(.top, AppSpacing.xs)
            }
        }
        .cardStyle()
    }

    private var checkoutBar: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Total")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)

                Spacer()

                Text(cart.formattedTotal)
                    .font(AppFont.priceLarge)
                    .foregroundStyle(AppColor.textPrimary)
                    .contentTransition(.numericText())
            }

            NavigationLink(value: CheckoutRoute()) {
                HStack(spacing: AppSpacing.sm) {
                    Text("Checkout")
                        .font(AppFont.button)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(AppColor.onInk)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                        .fill(AppColor.ink)
                )
            }
            .buttonStyle(.pressable)
            .accessibilityIdentifier("checkout")
        }
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.top, AppSpacing.lg)
        // Clears the floating tab bar, which stays visible on this screen
        // because the cart is a tab root.
        .padding(.bottom, .tabBarClearance)
        // The action bar floats over scrolling content, so it belongs to the
        // control layer — glass rather than an opaque fill.
        .background {
            Color.clear
                .floatingGlass(in: Rectangle())
                .ignoresSafeArea()
        }
        .animation(.smooth(duration: 0.3), value: cart.total)
    }
}

// MARK: - Swipe to delete

private extension View {
    /// The cart is a `ScrollView` rather than a `List`, so it gets a manual
    /// swipe-to-delete instead of `.swipeActions`.
    func swipeActionsCompat(onDelete: @escaping () -> Void) -> some View {
        modifier(SwipeToDelete(onDelete: onDelete))
    }
}

private struct SwipeToDelete: ViewModifier {

    let onDelete: () -> Void

    @State private var offset: CGFloat = 0

    private let threshold: CGFloat = -70

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(AppColor.error))
            }
            .buttonStyle(.pressable)
            .padding(.trailing, AppSpacing.md)
            .opacity(offset < -20 ? 1 : 0)

            content
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 12)
                        .onChanged { value in
                            guard value.translation.width < 0 else { return }
                            offset = max(value.translation.width, threshold * 1.3)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                offset = offset < threshold ? threshold : 0
                            }
                        }
                )
        }
        .animation(.smooth(duration: 0.2), value: offset < -20)
    }
}

#Preview {
    NavigationStack {
        CartView()
    }
    .environment(CartStore())
    .environment(FavoritesStore())
}
