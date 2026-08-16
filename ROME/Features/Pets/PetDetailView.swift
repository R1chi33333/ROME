//
//  PetDetailView.swift
//  ROME
//

import SwiftUI

struct PetDetailView: View {

    let pet: Pet

    @Environment(PetStore.self) private var pets
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    /// Reads back from the store so edits made in the sheet show up here
    /// without the caller having to re-push the screen.
    private var current: Pet {
        pets.pets.first { $0.id == pet.id } ?? pet
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                headerCard
                    .staggeredAppear(index: 0)

                detailsCard
                    .staggeredAppear(index: 1)

                if !current.notes.isEmpty {
                    notesCard
                        .staggeredAppear(index: 2)
                }

                shopLink
                    .staggeredAppear(index: 3)

                deleteButton
                    .staggeredAppear(index: 4)
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.xxl)
        }
        .background(AppColor.background)
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { isEditing = true }
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .sheet(isPresented: $isEditing) {
            PetFormView(pet: current)
        }
        .confirmationDialog(
            "Remove \(current.name)?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                Task {
                    await pets.delete(current)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the profile from your account.")
        }
    }

    private var headerCard: some View {
        VStack(spacing: AppSpacing.lg) {
            PetMonogram(pet: current, diameter: 92)

            VStack(spacing: AppSpacing.xs) {
                Text(current.name)
                    .font(AppFont.display)
                    .foregroundStyle(AppColor.textPrimary)

                Text(current.breed.isEmpty ? current.species.displayName : current.breed)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
            }

            HStack(spacing: AppSpacing.sm) {
                StatusTag(text: current.species.displayName, style: .accent)
                StatusTag(
                    text: current.neuteredLabel,
                    style: current.isNeutered ? .success : .neutral
                )
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: AppSpacing.xl)
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(label: "Weight", value: current.formattedWeight, icon: "scalemass")
            Divider().overlay(AppColor.divider)
            DetailRow(label: "Age", value: current.formattedAge, icon: "birthday.cake")
            Divider().overlay(AppColor.divider)
            DetailRow(
                label: "Birthday",
                value: current.birthday?.formatted(date: .abbreviated, time: .omitted) ?? "Not set",
                icon: "calendar"
            )
            Divider().overlay(AppColor.divider)
            DetailRow(
                label: "Neutered / Spayed",
                value: current.isNeutered ? "Yes" : "No",
                icon: "checkmark.seal"
            )
        }
        .cardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Notes")
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)

            Text(current.notes)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var shopLink: some View {
        NavigationLink(value: current.species) {
            HStack(spacing: AppSpacing.lg) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.accentText)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppColor.accentSoft))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Shop for \(current.name)")
                        .font(AppFont.cardTitle)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Browse \(current.species.pluralName.lowercased()) categories")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textTertiary)
            }
            .cardStyle()
        }
        .buttonStyle(.pressableCard)
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            isConfirmingDelete = true
        } label: {
            Text("Remove Pet")
                .font(AppFont.button)
                .foregroundStyle(AppColor.error)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                        .fill(AppColor.error.opacity(0.08))
                )
        }
        .buttonStyle(.pressable)
    }
}

#Preview {
    NavigationStack {
        PetDetailView(pet: SampleData.pets[0])
            .shopNavigationDestinations()
    }
    .environment(PetStore(dataStore: MockDataStore()))
    .environment(FavoritesStore())
    .environment(CartStore())
}
