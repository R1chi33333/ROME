//
//  SignUpView.swift
//  ROME
//
//  UI only. Nothing is registered anywhere — see `AuthState`.
//

import SwiftUI

struct SignUpView: View {

    @Environment(AuthState.self) private var auth

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmation = ""
    @State private var acceptedTerms = false

    private var passwordsMatch: Bool {
        confirmation.isEmpty || password == confirmation
    }

    private var canSubmit: Bool {
        !name.isEmpty
        && !email.isEmpty
        && password.count >= 8
        && password == confirmation
        && acceptedTerms
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
                        title: "Name",
                        text: $name,
                        icon: "person",
                        contentType: .name
                    )
                    .staggeredAppear(index: 1)

                    AppTextField(
                        title: "Email",
                        text: $email,
                        icon: "envelope",
                        keyboard: .emailAddress,
                        contentType: .emailAddress
                    )
                    .staggeredAppear(index: 2)

                    AppTextField(
                        title: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true,
                        contentType: .newPassword
                    )
                    .staggeredAppear(index: 3)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        AppTextField(
                            title: "Confirm password",
                            text: $confirmation,
                            icon: "lock.rotation",
                            isSecure: true,
                            contentType: .newPassword,
                            submitLabel: .go,
                            onSubmit: submit
                        )

                        if !passwordsMatch {
                            Label("Passwords do not match", systemImage: "exclamationmark.circle.fill")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.smooth(duration: 0.25), value: passwordsMatch)
                    .staggeredAppear(index: 4)
                }

                passwordHint
                    .staggeredAppear(index: 5)

                termsToggle
                    .staggeredAppear(index: 6)

                PrimaryButton(
                    title: "Create Account",
                    phase: buttonPhase,
                    isEnabled: canSubmit,
                    action: submit
                )
                .staggeredAppear(index: 7)

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
            Text("Create account")
                .font(AppFont.display)
                .foregroundStyle(AppColor.textPrimary)

            Text("Tell us who you are, then add your pets.")
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    private var passwordHint: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: password.count >= 8 ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13))
                .foregroundStyle(password.count >= 8 ? AppColor.success : AppColor.textTertiary)
                .contentTransition(.symbolEffect(.replace))

            Text("At least 8 characters")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .animation(.smooth(duration: 0.25), value: password.count >= 8)
    }

    private var termsToggle: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                acceptedTerms.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 19))
                    .foregroundStyle(acceptedTerms ? AppColor.accent : AppColor.textTertiary)
                    .contentTransition(.symbolEffect(.replace))

                Text("I agree to the Terms of Service and Privacy Policy.")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.pressable)
    }

    private func submit() {
        guard canSubmit else { return }
        Task { await auth.signUp(name: name, email: email) }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
    .environment(AuthState())
}
