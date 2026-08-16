//
//  MyPetsView.swift
//  ROME
//

import SwiftUI

struct MyPetsView: View {

    @Environment(PetStore.self) private var pets
    @Environment(AuthState.self) private var auth

    /// One sheet, one piece of state. Attaching two `.sheet` modifiers to the
    /// same view is unreliable in SwiftUI — the second can shadow the first,
    /// and the presented content ends up in an inconsistent state.
    @State private var editorTarget: EditorTarget?

    private enum EditorTarget: Identifiable {
        case new
        case existing(Pet)

        var id: String {
            switch self {
            case .new: return "new"
            case .existing(let pet): return pet.id.uuidString
            }
        }

        var pet: Pet? {
            switch self {
            case .new: return nil
            case .existing(let pet): return pet
            }
        }
    }

    var body: some View {
        Group {
            if auth.isGuest {
                GuestGate(
                    systemName: "pawprint.fill",
                    title: "Your pets live here",
                    message: "Sign in to add your pets and keep their weight, birthday and vet notes in one place.",
                    reason: "add a pet"
                )
                .frame(maxHeight: .infinity)
            } else if pets.isLoading && pets.pets.isEmpty {
                loadingList
            } else if pets.pets.isEmpty {
                EmptyState(
                    systemName: "pawprint",
                    title: "No pets yet",
                    message: "Add a pet and we will tailor the shop to what they actually need.",
                    actionTitle: "Add a Pet"
                ) {
                    editorTarget = .new
                }
                .frame(maxHeight: .infinity)
            } else {
                list
            }
        }
        .background(AppColor.background)
        .navigationTitle("My Pets")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbar {
            // No add button for guests: the gate below already offers the one
            // action available to them, and a "+" that only leads to a sign-in
            // wall is a dead end.
            if !auth.isGuest {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editorTarget = .new
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColor.textPrimary)
                    }
                    .accessibilityLabel("Add pet")
                    .accessibilityIdentifier("add-pet")
                }
            }
        }
        .navigationDestination(for: Pet.self) { pet in
            PetDetailView(pet: pet)
        }
        // Pet detail offers "Shop for <name>", which pushes into the shop
        // hierarchy from inside this stack.
        .shopNavigationDestinations()
        .sheet(item: $editorTarget) { target in
            PetFormView(pet: target.pet)
        }
        // Keyed on the session so signing in from the gate loads the pets that
        // the new account owns, rather than leaving the screen empty until the
        // tab is visited again.
        .task(id: auth.isGuest) {
            guard !auth.isGuest else { return }
            await pets.load()
        }
    }

    private var list: some View {
        PawRefreshScrollView {
            await pets.reload()
        } content: {
            VStack(spacing: AppSpacing.md) {
                summaryStrip
                    .padding(.bottom, AppSpacing.sm)

                ForEach(Array(pets.pets.enumerated()), id: \.element.id) { index, pet in
                    NavigationLink(value: pet) {
                        PetCard(pet: pet)
                    }
                    .buttonStyle(.pressableCard)
                    .accessibilityIdentifier("pet-\(pet.name)")
                    .staggeredAppear(index: min(index, 6), stagger: 0.05)
                    .contextMenu {
                        Button {
                            editorTarget = .existing(pet)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            Task { await pets.delete(pet) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }

                addButton
                    .padding(.top, AppSpacing.sm)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, .tabBarClearance)
        }
    }

    /// One tile per species the user owns, as a quick read of the household.
    private var summaryStrip: some View {
        HStack(spacing: AppSpacing.md) {
            statTile(value: "\(pets.pets.count)", label: pets.pets.count == 1 ? "pet" : "pets")
            statTile(value: "\(pets.ownedSpecies.count)", label: "species")
            statTile(
                value: "\(pets.pets.filter(\.isNeutered).count)",
                label: "neutered"
            )
        }
    }

    private func statTile(value: String, label: String) -> some View {
        VStack(spacing: 2) {
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

    private var addButton: some View {
        Button {
            editorTarget = .new
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 17, weight: .medium))
                Text("Add another pet")
                    .font(AppFont.button)
            }
            .foregroundStyle(AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .strokeBorder(
                        AppColor.border,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                    )
            )
        }
        .buttonStyle(.pressable)
    }

    private var loadingList: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: AppSpacing.lg) {
                    Circle()
                        .fill(AppColor.surfaceSunken)
                        .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        SkeletonBlock(height: 16, radius: AppRadius.sm).frame(width: 120)
                        SkeletonBlock(height: 12, radius: AppRadius.sm).frame(width: 180)
                    }
                    Spacer()
                }
                .cardStyle()
            }
            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.top, AppSpacing.sm)
    }
}

#Preview {
    NavigationStack {
        MyPetsView()
    }
    .environment(PetStore(dataStore: MockDataStore()))
}
