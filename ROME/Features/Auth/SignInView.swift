//
//  SignInView.swift
//  ROME
//
//  UI only. `AuthState` accepts any credentials — see the note at the top of
//  that file.
//

import SwiftUI

struct SignInView: View {

    @Environment(AuthState.self) private var auth

    @State private var email = ""
    @State private var password = ""

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty
    }

    private var buttonPhase: ButtonPhase {
        switch auth.phase {
        case .idle: return .idle
        case .working: return .loading
        case .succeeded: return .success
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                header
                    .staggeredAppear(index: 0)

                VStack(spacing: AppSpacing.md) {
                    AppTextField(
                        title: "Email",
                        text: $email,
                        icon: "envelope",
                        keyboard: .emailAddress,
                        contentType: .emailAddress
                    )
                    .staggeredAppear(index: 1)

                    AppTextField(
                        title: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        contentType: .password,
                        submitLabel: .go,
                        onSubmit: submit
                    )
                    .staggeredAppear(index: 2)
                }

                HStack {
                    Spacer()
                    TextButton(title: "Forgot password?") {}
                }
                .staggeredAppear(index: 3)

                PrimaryButton(
                    title: "Sign In",
                    phase: buttonPhase,
                    isEnabled: canSubmit,
                    action: submit
                )
                .accessibilityIdentifier("submit-sign-in")
                .staggeredAppear(index: 4)

                divider
                    .staggeredAppear(index: 5)

                socialButtons
                    .staggeredAppear(index: 6)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.lg)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColor.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Welcome back")
                .font(AppFont.display)
                .foregroundStyle(AppColor.textPrimary)

            Text("Sign in to pick up where you left off.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var divider: some View {
        HStack(spacing: AppSpacing.md) {
            Rectangle().fill(AppColor.divider).frame(height: 1)
            Text("or")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textTertiary)
            Rectangle().fill(AppColor.divider).frame(height: 1)
        }
    }

    private var socialButtons: some View {
        HStack(spacing: AppSpacing.md) {
            SecondaryButton(title: "Apple", icon: "apple.logo") {}
            SecondaryButton(title: "Google", icon: "g.circle.fill") {}
        }
    }

    private func submit() {
        guard canSubmit else { return }
        Task { await auth.signIn(email: email) }
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
    .environment(AuthState())
}
