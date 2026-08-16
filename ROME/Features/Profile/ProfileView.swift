//
//  ProfileView.swift
//  ROME
//

import SwiftUI

struct ProfileView: View {

    @Environment(AuthState.self) private var auth
    @Environment(PetStore.self) private var pets
    @Environment(FavoritesStore.self) private var favorites
    @Environment(CartStore.self) private var cart
    @Environment(\.switchToTab) private var switchToTab

    @State private var isConfirmingSignOut = false
    @State private var isPromptingSignIn = false
    @State private var notificationsEnabled = true
    @State private var remindersEnabled = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                if auth.isGuest {
                    guestCard
                        .staggeredAppear(index: 0)
                } else {
                    accountCard
                        .staggeredAppear(index: 0)

                    statsRow
                        .staggeredAppear(index: 1)
                }

                settingsGroup
                    .staggeredAppear(index: 2)

                supportGroup
                    .staggeredAppear(index: 3)

                // Nothing to sign out of as a guest; the card above offers the
                // one account action that applies.
                if !auth.isGuest {
                    signOutButton
                        .staggeredAppear(index: 4)
                }

                versionLabel
                    .staggeredAppear(index: 5)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, .tabBarClearance)
        }
        .background(AppColor.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .sheet(isPresented: $isPromptingSignIn) {
            AuthPromptView(reason: "save your pets and orders")
        }
        .confirmationDialog(
            "Sign out of ROME?",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                // Clear what belonged to the account, or the next session —
                // guest included — inherits the last user's pets and basket.
                pets.clear()
                favorites.clear()
                cart.clear()
                auth.signOut()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    /// For a guest this is the main call to action, not a summary — there is
    /// no account to summarise.
    private var guestCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.lg) {
                Circle()
                    .fill(AppColor.surfaceSunken)
                    .frame(width: 68, height: 68)
                    .overlay {
                        Image(systemName: "person")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(AppColor.textTertiary)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Browsing as guest")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Sign in to save pets, favourites and orders.")
                        .font(AppFont.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            PrimaryButton(title: "Sign In") {
                isPromptingSignIn = true
            }
        }
        .cardStyle()
    }

    private var accountCard: some View {
        HStack(spacing: AppSpacing.lg) {
            Circle()
                .fill(AppColor.accentSoft)
                .frame(width: 68, height: 68)
                .overlay {
                    Text(auth.currentUser?.initials ?? "?")
                        .font(.system(size: 24, weight: .semibold, design: AppFont.design))
                        .foregroundStyle(AppColor.accentText)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(auth.currentUser?.name ?? "Pet Parent")
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)

                Text(auth.currentUser?.email ?? "—")
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColor.textTertiary)
        }
        .cardStyle()
    }

    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            statTile(value: "\(pets.pets.count)", label: "Pets", icon: "pawprint.fill") {
                switchToTab(.pets)
            }
            statTile(value: "\(favorites.favoriteIDs.count)", label: "Saved", icon: "heart.fill") {
                switchToTab(.shop)
            }
            statTile(value: "0", label: "Orders", icon: "shippingbox.fill") {}
        }
    }

    private func statTile(
        value: String,
        label: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColor.accentText)

                Text(value)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .contentTransition(.numericText())

                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColor.surface)
                    .appShadow(.sm)
            )
        }
        .buttonStyle(.pressableCard)
    }

    private var settingsGroup: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Preferences")
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: 0) {
                toggleRow(
                    icon: "bell.fill",
                    title: "Order notifications",
                    subtitle: "Shipping and delivery updates",
                    isOn: $notificationsEnabled
                )
                Divider().overlay(AppColor.divider)
                toggleRow(
                    icon: "clock.fill",
                    title: "Restock reminders",
                    subtitle: "When food is likely running low",
                    isOn: $remindersEnabled
                )
            }
            .cardStyle(padding: AppSpacing.lg)
        }
    }

    private var supportGroup: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Support")
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: 0) {
                linkRow(icon: "questionmark.circle.fill", title: "Help centre")
                Divider().overlay(AppColor.divider)
                linkRow(icon: "envelope.fill", title: "Contact us")
                Divider().overlay(AppColor.divider)
                linkRow(icon: "doc.text.fill", title: "Terms and privacy")
            }
            .cardStyle(padding: AppSpacing.lg)
        }
    }

    private func toggleRow(
        icon: String,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn.animation(.spring(response: 0.3, dampingFraction: 0.7))) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textTertiary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(subtitle)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .tint(AppColor.accent)
        .padding(.vertical, AppSpacing.md)
    }

    private func linkRow(icon: String, title: String) -> some View {
        Button {} label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textTertiary)
                    .frame(width: 24)

                Text(title)
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .padding(.vertical, AppSpacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            isConfirmingSignOut = true
        } label: {
            Text("Sign Out")
                .font(AppFont.button)
                .foregroundStyle(AppColor.error)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                        .fill(AppColor.error.opacity(0.08))
                )
        }
        .buttonStyle(.pressable)
    }

    private var versionLabel: some View {
        Text("ROME 1.0 · Demo build")
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textTertiary)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(AuthState())
    .environment(PetStore(dataStore: MockDataStore()))
    .environment(FavoritesStore())
}
