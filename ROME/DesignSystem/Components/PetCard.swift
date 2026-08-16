//
//  PetCard.swift
//  ROME
//
//  A pet on the My Pets list: monogram, name, breed and weight, plus the
//  neutered status as a small tag.
//

import SwiftUI

/// The card surface only — no tap handling, so it can sit inside a
/// `NavigationLink` without nesting a button in a link's label.
struct PetCard: View {

    let pet: Pet

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            PetMonogram(pet: pet, diameter: 56)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Text(pet.name)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    Image(systemName: pet.species.symbolName)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.textTertiary)
                }

                Text(pet.subtitle)
                    .font(AppFont.footnote)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)

                if pet.isNeutered {
                    StatusTag(text: "Neutered / Spayed", style: .neutral)
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: AppSpacing.sm)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColor.textTertiary)
        }
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
    }

    /// "Mochi, British Shorthair, 4.6 kg, neutered" — one sentence, in the
    /// order the card reads visually.
    private var spokenLabel: String {
        var parts = [pet.name, pet.species.displayName]
        if !pet.breed.isEmpty { parts.append(pet.breed) }
        if pet.weightKg > 0 { parts.append(pet.formattedWeight) }
        if pet.isNeutered { parts.append("neutered") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Status tag

/// Small pill used for pet attributes and order status.
struct StatusTag: View {

    enum Style {
        case neutral
        case accent
        case success

        var foreground: Color {
            switch self {
            case .neutral: return AppColor.textSecondary
            case .accent: return AppColor.accentText
            case .success: return AppColor.success
            }
        }

        var background: Color {
            switch self {
            case .neutral: return AppColor.surfaceSunken
            case .accent: return AppColor.accentSoft
            case .success: return AppColor.success.opacity(0.12)
            }
        }
    }

    let text: String
    var style: Style = .neutral

    var body: some View {
        Text(text)
            .font(AppFont.caption)
            .foregroundStyle(style.foreground)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 4)
            .background(Capsule().fill(style.background))
    }
}

// MARK: - Detail row

/// Label/value pair used on the pet and order detail screens.
struct DetailRow: View {

    let label: String
    let value: String
    var icon: String?

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textTertiary)
                    .frame(width: 22)
            }

            Text(label)
                .font(AppFont.callout)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: AppSpacing.md)

            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview("Pet card") {
    VStack(spacing: AppSpacing.lg) {
        ForEach(SampleData.pets) { pet in
            PetCard(pet: pet)
        }

        VStack(spacing: 0) {
            DetailRow(label: "Weight", value: "4.6 kg", icon: "scalemass")
            Divider().overlay(AppColor.divider)
            DetailRow(label: "Neutered", value: "Yes", icon: "checkmark.seal")
        }
        .cardStyle()
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
