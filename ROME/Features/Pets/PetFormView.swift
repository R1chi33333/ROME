//
//  PetFormView.swift
//  ROME
//
//  Add or edit a pet: name, species, breed, weight, birthday, neutered, notes.
//

import SwiftUI

struct PetFormView: View {

    /// `nil` means this is a new pet.
    let pet: Pet?

    @Environment(PetStore.self) private var pets
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species: PetSpecies = .dog
    @State private var breed = ""
    @State private var weightText = ""
    @State private var birthday = Date.now
    @State private var hasBirthday = false
    @State private var isNeutered = false
    @State private var notes = ""

    private var isEditing: Bool { pet != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var weightValue: Double {
        Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    monogramPreview
                        .staggeredAppear(index: 0)

                    section("Basics") {
                        VStack(spacing: AppSpacing.md) {
                            AppTextField(title: "Name", text: $name, icon: "textformat")
                            AppTextField(title: "Breed", text: $breed, icon: "list.bullet")
                        }
                    }
                    .staggeredAppear(index: 1)

                    section("Species") {
                        speciesGrid
                    }
                    .staggeredAppear(index: 2)

                    section("Details") {
                        VStack(spacing: AppSpacing.md) {
                            AppTextField(
                                title: "Weight (kg)",
                                text: $weightText,
                                icon: "scalemass",
                                keyboard: .decimalPad
                            )

                            birthdayField

                            neuteredToggle
                        }
                    }
                    .staggeredAppear(index: 3)

                    section("Notes") {
                        notesField
                    }
                    .staggeredAppear(index: 4)
                }
                .padding(.horizontal, AppSpacing.screenGutter)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, 110)
            }
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .background(AppColor.background)
            .navigationTitle(isEditing ? "Edit Pet" : "Add Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(AppFont.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: isEditing ? "Save Changes" : "Add Pet", isEnabled: canSave) {
                    save()
                }
                .padding(.horizontal, AppSpacing.screenGutter)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
                .background {
                    Rectangle()
                        .fill(AppColor.background)
                        .ignoresSafeArea()
                        .appShadow(.bar)
                }
            }
            .onAppear(perform: populate)
        }
    }

    // MARK: - Sections

    private var monogramPreview: some View {
        HStack(spacing: AppSpacing.lg) {
            Circle()
                .fill(species.tint.opacity(0.14))
                .overlay { Circle().strokeBorder(species.tint.opacity(0.2), lineWidth: 1) }
                .overlay {
                    Text(name.isEmpty ? "?" : String(name.prefix(1)).uppercased())
                        .font(.system(size: 30, weight: .semibold, design: AppFont.design))
                        .foregroundStyle(AppColor.textPrimary)
                        .contentTransition(.identity)
                }
                .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 2) {
                Text(name.isEmpty ? "New pet" : name)
                    .font(AppFont.headline)
                    .foregroundStyle(name.isEmpty ? AppColor.textTertiary : AppColor.textPrimary)

                Text(breed.isEmpty ? species.displayName : breed)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .animation(.smooth(duration: 0.25), value: species)
    }

    private var speciesGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 100), spacing: AppSpacing.sm)],
            spacing: AppSpacing.sm
        ) {
            ForEach(PetSpecies.allCases) { option in
                speciesButton(option)
            }
        }
    }

    private func speciesButton(_ option: PetSpecies) -> some View {
        let isSelected = species == option

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                species = option
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 13, weight: .semibold))
                Text(option.displayName)
                    .font(AppFont.chip)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                Capsule().fill(isSelected ? AppColor.accentSoft : AppColor.surface)
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected ? AppColor.accent.opacity(0.35) : AppColor.border,
                    lineWidth: 1.5
                )
            )
        }
        .buttonStyle(.pressable)
    }

    private var birthdayField: some View {
        VStack(spacing: AppSpacing.md) {
            Toggle(isOn: $hasBirthday.animation(.smooth(duration: 0.25))) {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "birthday.cake")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textTertiary)
                        .frame(width: 20)

                    Text("Birthday known")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
            .tint(AppColor.accent)
            .padding(.horizontal, AppSpacing.lg)
            .frame(height: 62)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .fill(AppColor.surfaceSunken)
            )

            if hasBirthday {
                DatePicker(
                    "Birthday",
                    selection: $birthday,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(AppColor.accent)
                .padding(.horizontal, AppSpacing.lg)
                .frame(height: 62)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                        .fill(AppColor.surfaceSunken)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var neuteredToggle: some View {
        Toggle(isOn: $isNeutered.animation(.spring(response: 0.3, dampingFraction: 0.7))) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "checkmark.seal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isNeutered ? AppColor.accent : AppColor.textTertiary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 1) {
                    Text("Neutered / Spayed")
                        .font(AppFont.body)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(isNeutered ? "Yes" : "No")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .tint(AppColor.accent)
        .padding(.horizontal, AppSpacing.lg)
        .frame(height: 68)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .fill(AppColor.surfaceSunken)
        )
    }

    /// A vertically growing `TextField` rather than a `TextEditor`: it gets a
    /// real placeholder for free, matches the other fields' typography, and
    /// keeps the whole form made of one control type — a `TextEditor` here was
    /// enough to make the form's text fields unreachable to the accessibility
    /// tree walker used by UI tests.
    private var notesField: some View {
        TextField(
            "Allergies, vet notes, feeding routine…",
            text: $notes,
            axis: .vertical
        )
        .lineLimit(4...8)
        .font(AppFont.body)
        .foregroundStyle(AppColor.textPrimary)
        .padding(AppSpacing.lg)
        .frame(minHeight: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                .fill(AppColor.surfaceSunken)
        )
        .accessibilityLabel("Notes")
    }

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundStyle(AppColor.textPrimary)
            content()
        }
    }

    // MARK: - Actions

    private func populate() {
        guard let pet else { return }
        name = pet.name
        species = pet.species
        breed = pet.breed
        weightText = pet.weightKg > 0 ? String(format: "%.1f", pet.weightKg) : ""
        isNeutered = pet.isNeutered
        notes = pet.notes
        if let date = pet.birthday {
            birthday = date
            hasBirthday = true
        }
    }

    private func save() {
        let updated = Pet(
            id: pet?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            species: species,
            breed: breed.trimmingCharacters(in: .whitespaces),
            weightKg: weightValue,
            birthday: hasBirthday ? birthday : nil,
            isNeutered: isNeutered,
            notes: notes
        )

        Task {
            await pets.save(updated)
            dismiss()
        }
    }
}

#Preview("Add") {
    PetFormView(pet: nil)
        .environment(PetStore(dataStore: MockDataStore()))
}

#Preview("Edit") {
    PetFormView(pet: SampleData.pets[0])
        .environment(PetStore(dataStore: MockDataStore()))
}
