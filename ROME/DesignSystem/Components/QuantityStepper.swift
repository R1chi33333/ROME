//
//  QuantityStepper.swift
//  ROME
//
//  Minus / count / plus. The number slides up or down to match the direction
//  of the change.
//

import SwiftUI

struct QuantityStepper: View {

    @Binding var quantity: Int
    var minimum: Int = 1
    var maximum: Int = 99
    var compact: Bool = false

    private var buttonSize: CGFloat { compact ? 28 : 34 }
    private var iconSize: CGFloat { compact ? 11 : 13 }

    var body: some View {
        HStack(spacing: compact ? AppSpacing.sm : AppSpacing.md) {
            stepButton(icon: "minus", enabled: quantity > minimum) {
                quantity -= 1
            }
            .accessibilityIdentifier("decrement-quantity")

            Text("\(quantity)")
                .font(compact ? AppFont.subheadline : AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .monospacedDigit()
                .frame(minWidth: compact ? 18 : 24)
                .contentTransition(.numericText(value: Double(quantity)))

            stepButton(icon: "plus", enabled: quantity < maximum) {
                quantity += 1
            }
            .accessibilityIdentifier("increment-quantity")
        }
        .padding(.horizontal, compact ? AppSpacing.sm : AppSpacing.md)
        .padding(.vertical, compact ? AppSpacing.xs : AppSpacing.sm)
        .background(
            Capsule().fill(AppColor.surfaceSunken)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quantity")
        .accessibilityValue("\(quantity)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment where quantity < maximum: quantity += 1
            case .decrement where quantity > minimum: quantity -= 1
            default: break
            }
        }
    }

    private func stepButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(enabled ? AppColor.textPrimary : AppColor.textTertiary)
                .frame(width: buttonSize, height: buttonSize)
                .background(Circle().fill(AppColor.surface))
        }
        .buttonStyle(.pressable)
        .disabled(!enabled)
    }
}

#Preview("Stepper") {
    @Previewable @State var quantity = 1
    @Previewable @State var compactQuantity = 3

    return VStack(spacing: AppSpacing.xl) {
        QuantityStepper(quantity: $quantity)
        QuantityStepper(quantity: $compactQuantity, compact: true)
    }
    .padding(AppSpacing.screenGutter)
    .background(AppColor.background)
}
