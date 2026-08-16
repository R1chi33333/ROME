//
//  EmptyState.swift
//  ROME
//

import SwiftUI

struct EmptyState: View {

    let systemName: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: systemName)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(AppColor.textTertiary)
                .frame(width: 84, height: 84)
                .background(Circle().fill(AppColor.surfaceSunken))
                .scaleEffect(hasAppeared ? 1 : 0.8)
                .opacity(hasAppeared ? 1 : 0)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Text(message)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 8)

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, fillsWidth: false, action: action)
                    .padding(.top, AppSpacing.sm)
                    .opacity(hasAppeared ? 1 : 0)
            }
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                hasAppeared = true
            }
        }
    }
}

#Preview("Empty") {
    EmptyState(
        systemName: "bag",
        title: "Your cart is empty",
        message: "Browse the shop and add something your pet will actually use.",
        actionTitle: "Start Shopping"
    ) {}
    .frame(maxHeight: .infinity)
    .background(AppColor.background)
}
