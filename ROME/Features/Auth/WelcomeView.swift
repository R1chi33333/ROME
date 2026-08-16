//
//  WelcomeView.swift
//  ROME
//
//  First screen. Wordmark, one line of positioning, two ways in.
//

import SwiftUI

struct WelcomeView: View {

    @Environment(AuthState.self) private var auth

    @State private var route: Route?

    private enum Route: Hashable {
        case signIn
        case signUp
    }

    /// Species glyphs drifting behind the wordmark. Decorative only —
    /// hidden from assistive technology.
    private let driftingSpecies: [PetSpecies] = [.dog, .cat, .bird, .fish, .reptile, .smallPet]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                brandMark
                    .staggeredAppear(index: 0, offset: 20, initialDelay: 0.15)

                Spacer()

                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(title: "Sign In") {
                        route = .signIn
                    }
                    .staggeredAppear(index: 1, initialDelay: 0.15)

                    SecondaryButton(title: "Create Account") {
                        route = .signUp
                    }
                    .staggeredAppear(index: 2, initialDelay: 0.15)

                    Button {
                        auth.continueAsGuest()
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Text("Browse as guest")
                                .font(AppFont.subheadline)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.vertical, AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.pressable)
                    .staggeredAppear(index: 3, initialDelay: 0.15)

                    Text("By continuing you agree to our Terms and Privacy Policy.")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textTertiary)
                        .multilineTextAlignment(.center)
                        .staggeredAppear(index: 4, initialDelay: 0.15)
                }
                .padding(.horizontal, AppSpacing.screenGutter)
                .padding(.bottom, AppSpacing.xxl)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColor.background)
            .navigationDestination(item: $route) { route in
                switch route {
                case .signIn: SignInView()
                case .signUp: SignUpView()
                }
            }
        }
    }

    private var brandMark: some View {
        VStack(spacing: AppSpacing.xl) {
            speciesHalo

            VStack(spacing: AppSpacing.md) {
                // Tracking is wider than it would be for a longer word: at
                // four letters the wordmark needs the extra air to still read
                // as a mark rather than as a heading.
                Text("ROME")
                    .font(.system(size: 44, weight: .bold, design: AppFont.design))
                    .tracking(8)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Everything for dogs, cats, reptiles,\namphibians and the rest of the family.")
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, AppSpacing.xxl)
    }

    private var speciesHalo: some View {
        HStack(spacing: -AppSpacing.md) {
            ForEach(Array(driftingSpecies.enumerated()), id: \.element) { index, species in
                Image(systemName: species.symbolName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(species.tint)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(AppColor.surface)
                            .appShadow(.sm)
                    )
                    .zIndex(Double(driftingSpecies.count - index))
                    .staggeredAppear(index: index, offset: 10, stagger: 0.07, initialDelay: 0.3)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    WelcomeView()
        .environment(AuthState())
}
