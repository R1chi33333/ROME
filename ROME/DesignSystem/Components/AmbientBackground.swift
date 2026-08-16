//
//  AmbientBackground.swift
//  ROME
//
//  A page background that takes its colour from whatever is on screen, and
//  interpolates when that changes.
//
//  The gradient is anchored to the top, behind the hero, and falls away to the
//  page colour before it reaches the content. Two reasons: text further down
//  keeps a known contrast ratio, and the colour reads as light coming off the
//  product rather than as a themed screen.
//

import SwiftUI

struct AmbientBackground: View {

    /// Usually a species tint. Changing it animates the whole field.
    let tint: Color
    /// How far down the screen the colour reaches, 0–1.
    var extent: CGFloat = 0.55
    /// Strength at the very top.
    var intensity: Double = 0.30

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppColor.background

            // Broad wash from the top.
            LinearGradient(
                stops: [
                    .init(color: tint.opacity(intensity * schemeScale), location: 0),
                    .init(color: tint.opacity(intensity * schemeScale * 0.35), location: extent * 0.55),
                    .init(color: .clear, location: extent)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // A soft bloom behind where the hero sits, so the colour has a
            // source rather than being a flat band.
            RadialGradient(
                colors: [tint.opacity(intensity * schemeScale * 0.9), .clear],
                center: .init(x: 0.5, y: 0.16),
                startRadius: 0,
                endRadius: 340
            )
            .blur(radius: 40)
        }
        .ignoresSafeArea()
        // Colour interpolation is not motion, so Reduce Motion only shortens
        // it rather than removing it — an instant colour swap would be a
        // harsher change than the fade it replaces.
        .animation(
            reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.55),
            value: tint
        )
    }

    /// Dark mode needs less of the tint: the same opacity over a near-black
    /// page reads as a much stronger colour cast.
    private var schemeScale: Double {
        colorScheme == .dark ? 0.55 : 1
    }
}

#Preview("Ambient") {
    @Previewable @State var species: PetSpecies = .cat

    return ZStack {
        AmbientBackground(tint: species.tint)

        VStack(spacing: AppSpacing.xl) {
            PlaceholderThumbnail(label: "Feather Wand", tint: species.tint, size: .hero)
                .frame(height: 220)
                .padding(.horizontal, AppSpacing.xxl)

            Picker("", selection: $species) {
                ForEach(PetSpecies.allCases) { Text($0.displayName).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(height: 130)

            Spacer()
        }
        .padding(.top, AppSpacing.xxl)
    }
}
