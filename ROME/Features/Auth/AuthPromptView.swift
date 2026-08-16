//
//  AuthPromptView.swift
//  ROME
//
//  The sign-in flow presented as a sheet, for guests who reach something that
//  needs an account.
//
//  It reuses `SignInView` and `SignUpView` rather than duplicating those forms.
//  The only thing this adds is the reason: a guest arriving here was in the
//  middle of doing something, and saying which thing is what makes the
//  interruption feel earned rather than arbitrary.
//

import SwiftUI

struct AuthPromptView: View {

    /// What the guest was trying to do, e.g. "add a pet".
    let reason: String

    @Environment(AuthState.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var route: Route?

    private enum Route: Hashable {
        case signIn
        case signUp
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer(minLength: AppSpacing.xl)

                header

                Spacer(minLength: AppSpacing.xl)

                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(title: "Sign In") {
                        route = .signIn
                    }
                    .accessibilityIdentifier("prompt-sign-in")
                    .staggeredAppear(index: 2)

                    SecondaryButton(title: "Create Account") {
                        route = .signUp
                    }
                    .accessibilityIdentifier("prompt-sign-up")
                    .staggeredAppear(index: 3)

                    Button("Not now") { dismiss() }
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.textTertiary)
                        .padding(.top, AppSpacing.sm)
                        .buttonStyle(.pressable)
                        .staggeredAppear(index: 4)
                }
                .padding(.horizontal, AppSpacing.screenGutter)
                .padding(.bottom, AppSpacing.xxl)
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.background)
            .navigationDestination(item: $route) { route in
                switch route {
                case .signIn: SignInView()
                case .signUp: SignUpView()
                }
            }
            // Signing in swaps the session out from under this sheet; close it
            // so the screen the guest was on is what they land back on.
            .onChange(of: auth.isSignedIn) { _, signedIn in
                if signedIn { dismiss() }
            }
        }
    }

    private var header: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(AppColor.accent)
                .staggeredAppear(index: 0, offset: 18)

            VStack(spacing: AppSpacing.sm) {
                Text("Sign in to \(reason)")
                    .font(AppFont.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Browsing stays open to everyone. An account is only needed to save things that are yours.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .staggeredAppear(index: 1, offset: 14)
        }
        .padding(.horizontal, AppSpacing.xxl)
    }
}

// MARK: - Gate

/// Shown in place of a screen's content when a guest reaches it.
struct GuestGate: View {

    let systemName: String
    let title: String
    let message: String
    /// Reason passed to `AuthPromptView`, e.g. "add a pet".
    let reason: String

    @State private var isPromptingSignIn = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: systemName)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppColor.accentText)
                .frame(width: 84, height: 84)
                .background(Circle().fill(AppColor.accentSoft))

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

            PrimaryButton(title: "Sign In", fillsWidth: false) {
                isPromptingSignIn = true
            }
            .accessibilityIdentifier("gate-sign-in")
            .padding(.top, AppSpacing.sm)
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity)
        .staggeredAppear(index: 0, offset: 16)
        .sheet(isPresented: $isPromptingSignIn) {
            AuthPromptView(reason: reason)
        }
    }
}

#Preview("Prompt") {
    AuthPromptView(reason: "add a pet")
        .environment(AuthState())
}

#Preview("Gate") {
    GuestGate(
        systemName: "pawprint.fill",
        title: "Your pets live here",
        message: "Sign in to add your pets and get the shop tailored to what they actually need.",
        reason: "add a pet"
    )
    .frame(maxHeight: .infinity)
    .background(AppColor.background)
    .environment(AuthState())
}
