//
//  RootTabView.swift
//  ROME
//
//  Shell for the signed-in app: four tabs behind a custom floating bar.
//
//  The bar is hand-built rather than a system `TabView` bar so the selected
//  item can carry the orange wash and the cart badge can bounce when something
//  is added.
//

import SwiftUI

struct RootTabView: View {

    @Environment(CartStore.self) private var cart

    @State private var selection: Tab = .shop
    @State private var toast: ToastMessage?

    // One path per tab, so each keeps its place when you switch away and back.
    // Tracking them here also tells the bar when it is covering a pushed
    // screen: those screens own the bottom edge with their own action bars
    // ("Add to Cart", "Place Order"), and a floating bar on top of them
    // swallows the taps.
    @State private var shopPath = NavigationPath()
    @State private var cartPath = NavigationPath()
    @State private var petsPath = NavigationPath()
    @State private var profilePath = NavigationPath()

    private var isAtTabRoot: Bool {
        switch selection {
        case .shop: return shopPath.isEmpty
        case .cart: return cartPath.isEmpty
        case .pets: return petsPath.isEmpty
        case .profile: return profilePath.isEmpty
        }
    }

    enum Tab: String, CaseIterable, Identifiable {
        case shop, cart, pets, profile

        var id: String { rawValue }

        var title: String {
            switch self {
            case .shop: return "Shop"
            case .cart: return "Cart"
            case .pets: return "My Pets"
            case .profile: return "Profile"
            }
        }

        var symbolName: String {
            switch self {
            case .shop: return "square.grid.2x2.fill"
            case .cart: return "bag.fill"
            case .pets: return "pawprint.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isAtTabRoot {
                AppTabBar(selection: $selection, cartCount: cart.itemCount)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.28), value: isAtTabRoot)
        .background(AppColor.background)
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .top) {
            if let toast {
                ToastView(message: toast)
                    .padding(.horizontal, AppSpacing.screenGutter)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .environment(\.showToast, ShowToastAction { message in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                toast = message
            }
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.smooth(duration: 0.3)) { toast = nil }
            }
        })
        .environment(\.switchToTab, SwitchToTabAction { tab in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                selection = tab
            }
        })
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .shop:
            NavigationStack(path: $shopPath) { HomeView() }
        case .cart:
            NavigationStack(path: $cartPath) { CartView() }
        case .pets:
            NavigationStack(path: $petsPath) { MyPetsView() }
        case .profile:
            NavigationStack(path: $profilePath) { ProfileView() }
        }
    }
}

// MARK: - Tab bar

private struct AppTabBar: View {

    @Binding var selection: RootTabView.Tab
    let cartCount: Int

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RootTabView.Tab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(AppColor.surface)
                .appShadow(.card)
        )
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.bottom, AppSpacing.sm)
    }

    private func tabButton(_ tab: RootTabView.Tab) -> some View {
        let isSelected = selection == tab

        return Button {
            guard !isSelected else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.symbolName)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textTertiary)

                    if tab == .cart && cartCount > 0 {
                        CartBadge(count: cartCount)
                            .offset(x: 11, y: -8)
                    }
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold, design: AppFont.design))
                    .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.sm)
            .background {
                if isSelected {
                    Capsule()
                        .fill(AppColor.accentSoft)
                        .matchedGeometryEffect(id: "tabSelection", in: namespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

// MARK: - Cart badge

private struct CartBadge: View {

    let count: Int

    @State private var scale: CGFloat = 1

    var body: some View {
        Text("\(min(count, 99))")
            .font(.system(size: 10, weight: .bold, design: AppFont.design))
            .foregroundStyle(AppColor.onInk)
            .monospacedDigit()
            .padding(.horizontal, count > 9 ? 5 : 0)
            .frame(minWidth: 17, minHeight: 17)
            .background(Capsule().fill(AppColor.accent700))
            .scaleEffect(scale)
            .onChange(of: count) { _, _ in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
                    scale = 1.4
                } completion: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        scale = 1
                    }
                }
            }
    }
}

// MARK: - Toast

struct ToastMessage: Equatable {
    let text: String
    var symbolName: String = "checkmark.circle.fill"
}

private struct ToastView: View {

    let message: ToastMessage

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: message.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColor.accent400)

            Text(message.text)
                .font(AppFont.subheadline)
                .foregroundStyle(AppColor.onInk)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(Capsule().fill(AppColor.ink))
        .appShadow(.raised)
    }
}

// MARK: - Environment plumbing

/// Lets any screen raise a toast without owning the presentation.
struct ShowToastAction {
    let handler: (ToastMessage) -> Void
    func callAsFunction(_ message: ToastMessage) { handler(message) }
}

/// Lets a screen jump to another tab, e.g. "Start Shopping" from the empty cart.
struct SwitchToTabAction {
    let handler: (RootTabView.Tab) -> Void
    func callAsFunction(_ tab: RootTabView.Tab) { handler(tab) }
}

private struct ShowToastKey: EnvironmentKey {
    static let defaultValue = ShowToastAction { _ in }
}

private struct SwitchToTabKey: EnvironmentKey {
    static let defaultValue = SwitchToTabAction { _ in }
}

extension EnvironmentValues {
    var showToast: ShowToastAction {
        get { self[ShowToastKey.self] }
        set { self[ShowToastKey.self] = newValue }
    }

    var switchToTab: SwitchToTabAction {
        get { self[SwitchToTabKey.self] }
        set { self[SwitchToTabKey.self] = newValue }
    }
}

/// Bottom inset every scrolling screen adds so content clears the floating bar.
extension CGFloat {
    static let tabBarClearance: CGFloat = 96
}
