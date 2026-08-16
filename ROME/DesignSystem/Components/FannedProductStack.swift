//
//  FannedProductStack.swift
//  ROME
//
//  The product hero, fanned out to show how many are being bought.
//
//  The whole effect is one `HStack` whose spacing animates between a negative
//  value and a positive one. Negative spacing makes the copies overlap, so at
//  rest they sit stacked behind the front one; animating to positive spacing
//  spreads them apart. There is no per-copy offset maths and nothing to keep
//  in sync — the stack lays itself out, and the spring rides the spacing.
//

import SwiftUI

struct FannedProductStack: View {

    let label: String
    let tint: Color
    let quantity: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Beyond this the fan stops reading as a quantity and starts reading as
    /// clutter, so the rest are represented by a badge instead.
    private let maxVisible = 5

    private var visibleCount: Int { min(quantity, maxVisible) }
    private var overflow: Int { max(0, quantity - maxVisible) }

    /// Overlapped when there is a single item, spread once there are more.
    /// The negative value is what tucks the copies behind the front one.
    private var spacing: CGFloat {
        visibleCount <= 1 ? -36 : -12
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<visibleCount, id: \.self) { index in
                copy(at: index)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .overlay(alignment: .topTrailing) {
            if overflow > 0 {
                Text("+\(overflow)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.onInk)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColor.ink))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(fanAnimation, value: quantity)
        // The fan is one product shown many times; to assistive technology it
        // is a single image, not five.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(quantity == 1 ? label : "\(label), \(quantity) items")
    }

    private func copy(at index: Int) -> some View {
        // Distance from the middle of the fan, so copies fall away
        // symmetrically on both sides.
        let middle = Double(visibleCount - 1) / 2
        let distance = abs(Double(index) - middle)
        let isCentre = distance < 0.5

        return PlaceholderThumbnail(label: label, tint: tint, size: isCentre ? .hero : .card)
            .frame(height: 260)
            .scaleEffect(1 - 0.22 * distance, anchor: .bottom)
            .brightness(-0.10 * distance)
            .saturation(1 - 0.18 * distance)
            // Front-most in the middle, receding outward, so the fan reads as
            // depth rather than as a row.
            .zIndex(-distance)
            .transition(
                reduceMotion
                    ? .opacity
                    : .scale(scale: 0.7, anchor: .bottom).combined(with: .opacity)
            )
    }

    /// Reduce Motion turns the spring into a plain cross-fade. The spread is
    /// decorative, and a large object springing across the screen is exactly
    /// what that setting exists to suppress.
    private var fanAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(response: 0.42, dampingFraction: 0.68)
    }
}

#Preview("Fan") {
    @Previewable @State var quantity = 1

    return VStack(spacing: AppSpacing.xxl) {
        FannedProductStack(
            label: "Feather Wand",
            tint: PetSpecies.cat.tint,
            quantity: quantity
        )

        QuantityStepper(quantity: $quantity, maximum: 8)
    }
    .padding(AppSpacing.screenGutter)
    .frame(maxHeight: .infinity)
    .background(AppColor.background)
}
