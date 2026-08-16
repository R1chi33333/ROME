//
//  CheckoutView.swift
//  ROME
//
//  Address and payment form, then a simulated order confirmation.
//
//  Nothing is charged and no order is stored. Placing an order waits briefly,
//  shows the success state and empties the cart.
//

import SwiftUI

struct CheckoutView: View {

    @Environment(CartStore.self) private var cart
    @Environment(AuthState.self) private var auth
    @Environment(\.switchToTab) private var switchToTab
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var address = ""
    @State private var city = ""
    @State private var postcode = ""
    @State private var deliveryOption: DeliveryOption = .standard
    @State private var phase: ButtonPhase = .idle
    @State private var didPlaceOrder = false

    private enum DeliveryOption: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case express = "Express"

        var id: String { rawValue }

        var detail: String {
            switch self {
            case .standard: return "3–5 working days"
            case .express: return "Next working day"
            }
        }

        var surcharge: Decimal {
            switch self {
            case .standard: return 0
            case .express: return 6.99
            }
        }
    }

    private var canPlaceOrder: Bool {
        !fullName.isEmpty && !address.isEmpty && !city.isEmpty && !postcode.isEmpty
    }

    private var orderTotal: Decimal {
        cart.total + deliveryOption.surcharge
    }

    var body: some View {
        Group {
            // Browsing and filling a basket stay open to guests; an order has
            // to belong to someone, so this is where the account is needed.
            if auth.isGuest {
                GuestGate(
                    systemName: "bag.fill",
                    title: "Sign in to check out",
                    message: "Your basket is saved. Sign in to place the order and follow it to the door.",
                    reason: "place your order"
                )
                .frame(maxHeight: .infinity)
            } else if didPlaceOrder {
                OrderConfirmationView {
                    // Pop first so the cart stack is left empty; switching tab
                    // first would strand this screen on the cart's path and
                    // show a confirmation for an order already finished.
                    dismiss()
                    switchToTab(.shop)
                }
            } else {
                form
            }
        }
        .background(AppColor.background)
        .navigationTitle(didPlaceOrder ? "" : "Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .navigationBarBackButtonHidden(didPlaceOrder)
        .onAppear {
            if fullName.isEmpty { fullName = auth.currentUser?.name ?? "" }
        }
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                section("Delivery address") {
                    VStack(spacing: AppSpacing.md) {
                        AppTextField(title: "Full name", text: $fullName, icon: "person", contentType: .name)
                        AppTextField(title: "Street address", text: $address, icon: "house", contentType: .fullStreetAddress)
                        HStack(spacing: AppSpacing.md) {
                            AppTextField(title: "City", text: $city, contentType: .addressCity)
                            AppTextField(title: "Postcode", text: $postcode, contentType: .postalCode)
                        }
                    }
                }
                .staggeredAppear(index: 0)

                section("Delivery speed") {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(DeliveryOption.allCases) { option in
                            deliveryRow(option)
                        }
                    }
                }
                .staggeredAppear(index: 1)

                section("Order summary") {
                    VStack(spacing: 0) {
                        ForEach(cart.items) { item in
                            DetailRow(
                                label: "\(item.quantity) × \(item.product.name)",
                                value: item.formattedLineTotal
                            )
                            Divider().overlay(AppColor.divider)
                        }

                        DetailRow(label: "Delivery", value: cart.formattedShipping)
                        Divider().overlay(AppColor.divider)

                        if deliveryOption.surcharge > 0 {
                            DetailRow(
                                label: "Express surcharge",
                                value: deliveryOption.surcharge.formattedPrice
                            )
                            Divider().overlay(AppColor.divider)
                        }

                        HStack {
                            Text("Total")
                                .font(AppFont.headline)
                                .foregroundStyle(AppColor.textPrimary)
                            Spacer()
                            Text(orderTotal.formattedPrice)
                                .font(AppFont.headline)
                                .foregroundStyle(AppColor.accentText)
                                .contentTransition(.numericText())
                        }
                        .padding(.top, AppSpacing.md)
                    }
                    .cardStyle()
                }
                .staggeredAppear(index: 2)

                noteBanner
                    .staggeredAppear(index: 3)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, 120)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: "Place Order",
                phase: phase,
                isEnabled: canPlaceOrder,
                action: placeOrder
            )
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
            .background {
                Rectangle()
                    .fill(AppColor.background)
                    .ignoresSafeArea()
                    .appShadow(.bar)
            }
        }
        .animation(.smooth(duration: 0.3), value: deliveryOption)
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)
            content()
        }
    }

    private func deliveryRow(_ option: DeliveryOption) -> some View {
        let isSelected = deliveryOption == option

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                deliveryOption = option
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 19))
                    .foregroundStyle(isSelected ? AppColor.accent : AppColor.textTertiary)
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 1) {
                    Text(option.rawValue)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(option.detail)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)

                Text(option.surcharge == 0 ? "Included" : "+\(option.surcharge.formattedPrice)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .fill(isSelected ? AppColor.accentSoft : AppColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .strokeBorder(
                        isSelected ? AppColor.accent.opacity(0.35) : AppColor.border,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.pressable)
    }

    private var noteBanner: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColor.textTertiary)

            Text("This is a demo checkout. No payment is taken and no order is stored.")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .fill(AppColor.surfaceSunken)
        )
    }

    private func placeOrder() {
        guard canPlaceOrder, phase == .idle else { return }

        Task {
            phase = .loading
            try? await Task.sleep(for: .milliseconds(1400))

            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                phase = .success
            }
            try? await Task.sleep(for: .milliseconds(500))

            cart.clear()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                didPlaceOrder = true
            }
            phase = .idle
        }
    }
}

// MARK: - Confirmation

private struct OrderConfirmationView: View {

    let onDone: () -> Void

    @State private var hasAppeared = false
    /// Generated once. A computed property here would draw a new number on
    /// every redraw.
    @State private var orderNumber = "FP-" + String(Int.random(in: 100000...999999))

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColor.success.opacity(0.12))
                    .frame(width: 110, height: 110)
                    .scaleEffect(hasAppeared ? 1 : 0.5)

                AnimatedCheckmark(color: AppColor.success, lineWidth: 4)
                    .scaleEffect(2)
            }

            VStack(spacing: AppSpacing.sm) {
                Text("Order placed")
                    .font(AppFont.display)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Order \(orderNumber) is on its way.\nYou will get a notification when it ships.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 10)

            Spacer()

            PrimaryButton(title: "Back to Shop", action: onDone)
                .padding(.horizontal, AppSpacing.screenGutter)
                .padding(.bottom, AppSpacing.xxl)
                .opacity(hasAppeared ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                hasAppeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
    .environment(CartStore())
    .environment(AuthState())
}
