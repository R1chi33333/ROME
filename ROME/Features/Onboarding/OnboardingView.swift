//
//  OnboardingView.swift
//  ROME
//
//  Shown once after an account is created.
//
//  Three decisions shape this flow:
//
//  One question per screen. The same fields as a single long form, but a form
//  asks for everything before giving anything back, and this is the first
//  thing a new account sees.
//
//  Skipping is offered plainly, not buried. Someone who wants to look around
//  before committing details should not have to hunt for the way past — and
//  My Pets keeps its own entry point, so skipping is a detour rather than a
//  dead end.
//
//  The last step lands on a shop already filtered to what they own, not on a
//  "You're all set" screen. The reward for answering is the answer being used.
//

import SwiftUI

struct OnboardingView: View {

    /// Species the user picked, handed back so the shop can open filtered.
    let onFinish: (PetSpecies?) -> Void

    @Environment(PetStore.self) private var pets
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var step: Step = .species
    @State private var chosenSpecies: Set<PetSpecies> = []
    @State private var name = ""
    @State private var breed = ""
    @State private var weightText = ""
    @State private var isSaving = false

    private enum Step: Int, CaseIterable {
        case species, pet, done
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Group {
                switch step {
                case .species: speciesStep
                case .pet: petStep
                case .done: doneStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(stepTransition)

            footer
        }
        .background(
            AmbientBackground(
                tint: chosenSpecies.first?.tint ?? AppColor.accent,
                extent: 0.5,
                intensity: 0.24
            )
        )
        .appAnimation(AppMotion.standard, value: step)
    }

    // MARK: - Chrome

    private var header: some View {
        HStack {
            ProgressDots(count: Step.allCases.count, current: step.rawValue)

            Spacer()

            if step != .done {
                Button("Skip") { onFinish(nil) }
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .buttonStyle(.pressable)
                    .accessibilityIdentifier("onboarding-skip")
            }
        }
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xl)
    }

    private var footer: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryButton(
                title: primaryTitle,
                phase: isSaving ? .loading : .idle,
                isEnabled: canAdvance,
                action: advance
            )
            .accessibilityIdentifier("onboarding-continue")

            if step == .pet {
                Button("I'll add this later") { finish() }
                    .font(AppFont.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .buttonStyle(.pressable)
            }
        }
        .padding(.horizontal, AppSpacing.screenGutter)
        .padding(.bottom, AppSpacing.xxl)
    }

    // MARK: - Steps

    private var speciesStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                prompt(
                    "Who do you\nlive with?",
                    detail: "Pick every animal in your household. The shop only ever shows what applies to them."
                )

                FlowingChips(
                    options: PetSpecies.allCases,
                    selection: $chosenSpecies
                )
            }
            .padding(.horizontal, AppSpacing.screenGutter)
        }
    }

    private var petStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                prompt(
                    "Tell us about\nthe first one",
                    detail: "Only a name is needed. The rest can wait until you know it — or never."
                )

                VStack(spacing: AppSpacing.md) {
                    AppTextField(title: "Name", text: $name, icon: "textformat")
                    AppTextField(title: "Breed (optional)", text: $breed, icon: "list.bullet")
                    AppTextField(
                        title: "Weight in kg (optional)",
                        text: $weightText,
                        icon: "scalemass",
                        keyboard: .decimalPad
                    )
                }
            }
            .padding(.horizontal, AppSpacing.screenGutter)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
    }

    private var doneStep: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            if let species = chosenSpecies.first {
                PetMonogram(
                    pet: Pet(name: name.isEmpty ? "?" : name, species: species),
                    diameter: 96
                )
            }

            VStack(spacing: AppSpacing.sm) {
                Text(name.isEmpty ? "All set" : "Nice to meet \(name)")
                    .font(AppFont.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(doneDetail)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.xxl)
    }

    private func prompt(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.display)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Flow

    private var primaryTitle: String {
        switch step {
        case .species: return "Continue"
        case .pet: return "Add \(name.isEmpty ? "pet" : name)"
        case .done: return "Start shopping"
        }
    }

    private var canAdvance: Bool {
        switch step {
        case .species: return !chosenSpecies.isEmpty
        case .pet: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case .done: return true
        }
    }

    private var doneDetail: String {
        guard let species = chosenSpecies.first else {
            return "Your shop is ready."
        }
        return chosenSpecies.count > 1
            ? "The shop opens on \(species.pluralName.lowercased()); the rest are a tap away."
            : "The shop is now showing everything for \(species.pluralName.lowercased())."
    }

    private var stepTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
    }

    private func advance() {
        switch step {
        case .species:
            step = .pet

        case .pet:
            Task {
                isSaving = true
                await pets.save(
                    Pet(
                        name: name.trimmingCharacters(in: .whitespaces),
                        species: chosenSpecies.first ?? .dog,
                        breed: breed.trimmingCharacters(in: .whitespaces),
                        weightKg: Double(weightText.replacingOccurrences(of: ",", with: ".")) ?? 0
                    )
                )
                isSaving = false
                step = .done
            }

        case .done:
            finish()
        }
    }

    private func finish() {
        onFinish(chosenSpecies.first)
    }
}

// MARK: - Progress dots

/// Three steps do not warrant a percentage. Dots say "short, and you are here"
/// without implying precision the flow does not have.
private struct ProgressDots: View {

    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? AppColor.accent : AppColor.border)
                    .frame(width: index == current ? 22 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(current + 1) of \(count)")
    }
}

// MARK: - Multi-select chips

private struct FlowingChips: View {

    let options: [PetSpecies]
    @Binding var selection: Set<PetSpecies>

    @ScaledMetric(relativeTo: .subheadline) private var minWidth: CGFloat = 140

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minWidth), spacing: AppSpacing.sm)],
            spacing: AppSpacing.sm
        ) {
            ForEach(options) { option in
                chip(option)
            }
        }
    }

    private func chip(_ option: PetSpecies) -> some View {
        let isOn = selection.contains(option)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if isOn { selection.remove(option) } else { selection.insert(option) }
            }
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: option.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isOn ? AppColor.accentText : option.tint)

                Text(option.displayName)
                    .font(AppFont.chip)
                    .foregroundStyle(isOn ? AppColor.accentText : AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)

                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15))
                    .foregroundStyle(isOn ? AppColor.accent : AppColor.border)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .fill(isOn ? AppColor.accentSoft : AppColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.base, style: .continuous)
                    .strokeBorder(isOn ? AppColor.accent.opacity(0.4) : AppColor.border, lineWidth: 1.5)
            )
        }
        .buttonStyle(.pressable)
        .accessibilityIdentifier("species-\(option.rawValue)")
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    OnboardingView { _ in }
        .environment(PetStore(dataStore: MockDataStore()))
}
