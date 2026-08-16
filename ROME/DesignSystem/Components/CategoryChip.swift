//
//  CategoryChip.swift
//  ROME
//
//  Horizontal filter pills. The selected pill's orange wash slides between
//  chips via `matchedGeometryEffect` rather than cross-fading in place.
//

import SwiftUI

struct CategoryChip: View {

    let title: String
    let systemName: String?
    let isSelected: Bool
    /// Shared namespace so the selection background can animate between chips.
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textSecondary)
                }
                Text(title)
                    .font(AppFont.chip)
                    .foregroundStyle(isSelected ? AppColor.accentText : AppColor.textSecondary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .frame(minHeight: 44)
            .background {
                if isSelected {
                    Capsule()
                        .fill(AppColor.accentSoft)
                        .matchedGeometryEffect(id: "chipSelection", in: namespace)
                } else {
                    Capsule()
                        .fill(AppColor.surface)
                        .appShadow(.sm)
                }
            }
            .overlay {
                if isSelected {
                    Capsule().strokeBorder(AppColor.accent.opacity(0.35), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.pressable)
    }
}

// MARK: - Species row

/// The "Shop by Pet" row on the shop home.
struct SpeciesChipRow: View {

    @Binding var selection: PetSpecies?
    /// Species the user owns are floated to the front of the row.
    var preferred: [PetSpecies] = []

    @Namespace private var namespace

    private var ordered: [PetSpecies] {
        let rest = PetSpecies.allCases.filter { !preferred.contains($0) }
        return preferred + rest
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                CategoryChip(
                    title: "All",
                    systemName: "pawprint.fill",
                    isSelected: selection == nil,
                    namespace: namespace
                ) {
                    select(nil)
                }

                ForEach(ordered) { species in
                    CategoryChip(
                        title: species.displayName,
                        systemName: species.symbolName,
                        isSelected: selection == species,
                        namespace: namespace
                    ) {
                        select(species)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenGutter)
            .padding(.vertical, AppSpacing.sm)
        }
        .scrollClipDisabled()
    }

    private func select(_ species: PetSpecies?) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            selection = species
        }
    }
}

#Preview("Chips") {
    @Previewable @State var selection: PetSpecies? = .cat

    return VStack(alignment: .leading, spacing: AppSpacing.xl) {
        SpeciesChipRow(selection: $selection, preferred: [.cat, .dog])
        Text("Selected: \(selection?.displayName ?? "All")")
            .font(AppFont.footnote)
            .foregroundStyle(AppColor.textSecondary)
            .padding(.horizontal, AppSpacing.screenGutter)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding(.top, AppSpacing.xxl)
    .background(AppColor.background)
}
