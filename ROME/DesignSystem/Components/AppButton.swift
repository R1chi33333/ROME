//
//  AppButton.swift
//  ROME
//
//  Buttons.
//
//  The primary button fills with `ink` (near-black), not the orange accent.
//  White text on orange 500 measures 2.84:1, which fails WCAG AA; on ink it is
//  about 18:1. See the note at the top of `AppColor`.
//

import SwiftUI

/// Idle → loading → success, for buttons that kick off async work.
enum ButtonPhase: Equatable {
    case idle
    case loading
    case success
}

// MARK: - Primary

struct PrimaryButton: View {

    let title: String
    var phase: ButtonPhase = .idle
    var isEnabled: Bool = true
    var fillsWidth: Bool = true
    var icon: String?
    let action: () -> Void

    private var isInteractive: Bool { isEnabled && phase == .idle }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Held in the layout at all times so the button never changes
                // height between phases.
                label
                    .opacity(phase == .idle ? 1 : 0)

                if phase == .loading {
                    LoadingDots(color: AppColor.onInk)
                        .transition(.opacity)
                }

                if phase == .success {
                    AnimatedCheckmark(color: AppColor.onInk)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .frame(height: 54)
            .padding(.horizontal, fillsWidth ? 0 : AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .fill(AppColor.ink)
            )
            .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.pressable)
        .disabled(!isInteractive)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: phase)
    }

    private var label: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
            }
            Text(title)
                .font(AppFont.button)
        }
        .foregroundStyle(AppColor.onInk)
    }
}

// MARK: - Secondary

/// Outlined. For the lesser of two adjacent actions.
struct SecondaryButton: View {

    let title: String
    var isEnabled: Bool = true
    var fillsWidth: Bool = true
    var icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(AppFont.button)
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .frame(height: 54)
            .padding(.horizontal, fillsWidth ? 0 : AppSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .fill(AppColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .strokeBorder(AppColor.border, lineWidth: 1.5)
            )
            .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.pressable)
        .disabled(!isEnabled)
    }
}

// MARK: - Text button

/// Low-emphasis inline action, e.g. "view all" beside a section header.
struct TextButton: View {

    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppFont.subheadline)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .foregroundStyle(AppColor.textSecondary)
        }
        .buttonStyle(.pressable)
    }
}

// MARK: - Icon button

/// Circular icon-only control, e.g. the back chevron or a favourite toggle.
struct IconButton: View {

    let systemName: String
    var tint: Color = AppColor.textPrimary
    var background: Color = AppColor.surface
    var diameter: CGFloat = 42
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.38, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: diameter, height: diameter)
                .background(Circle().fill(background))
        }
        .buttonStyle(.pressable)
    }
}

#Preview("Buttons") {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton(title: "Sign In") {}
        PrimaryButton(title: "Sign In", phase: .loading) {}
        PrimaryButton(title: "Sign In", phase: .success) {}
        PrimaryButton(title: "Add to Cart", icon: "bag.fill") {}
        PrimaryButton(title: "Disabled", isEnabled: false) {}
        SecondaryButton(title: "Create Account") {}
        HStack {
            TextButton(title: "view all", icon: "chevron.right") {}
            Spacer()
            IconButton(systemName: "heart", background: AppColor.surfaceSunken) {}
        }
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
