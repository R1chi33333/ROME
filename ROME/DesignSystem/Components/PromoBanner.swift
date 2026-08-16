//
//  PromoBanner.swift
//  ROME
//
//  The one dark surface in an otherwise white app.
//
//  Filling this with `ink` rather than the orange accent is deliberate: white
//  text on orange 500 fails WCAG AA at 2.84:1. The accent still appears here,
//  as a small tag and a soft glow, where it carries no text.
//

import SwiftUI

struct PromoBanner: View {

    let headline: String
    let subheadline: String
    var tag: String?
    var action: () -> Void

    @State private var hasAppeared = false

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    if let tag {
                        Text(tag.uppercased())
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(AppColor.accent400)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(AppColor.accent.opacity(0.16))
                            )
                    }

                    Text(headline)
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.onInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subheadline)
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.onInk.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.onInk)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(AppColor.onInk.opacity(0.12)))
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColor.ink)
                    .overlay(alignment: .bottomTrailing) {
                        // Warm bloom in the corner — the accent used as light
                        // rather than as a fill, so no contrast rule applies.
                        Circle()
                            .fill(AppColor.accent.opacity(0.28))
                            .frame(width: 180, height: 180)
                            .blur(radius: 70)
                            .offset(x: 50, y: 60)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            }
            .scaleEffect(hasAppeared ? 1 : 0.96)
            .opacity(hasAppeared ? 1 : 0)
        }
        .buttonStyle(.pressableCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel([tag, headline, subheadline].compactMap { $0 }.joined(separator: ". "))
        .accessibilityAddTraits(.isButton)
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.1)) {
                hasAppeared = true
            }
        }
    }
}

#Preview("Banner") {
    PromoBanner(
        headline: "20% off first order",
        subheadline: "Applied automatically at checkout",
        tag: "New here"
    ) {}
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
