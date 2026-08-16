//
//  PressableStyle.swift
//  ROME
//
//  Press feedback shared by every tappable surface.
//

import SwiftUI

/// Shrinks and dims slightly while held, springing back on release.
struct PressableStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    var dims: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Under Reduce Motion the press still has to acknowledge itself,
            // so the dim stays and only the scale is dropped.
            .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .opacity(configuration.isPressed && dims ? 0.85 : 1)
            .animation(AppMotion.snappy(reduceMotion), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableStyle {
    /// The app's default press feedback.
    static var pressable: PressableStyle { PressableStyle() }

    /// Gentler press for large surfaces like cards, where a 4% shrink reads as
    /// a glitch rather than a press.
    static var pressableCard: PressableStyle { PressableStyle(scale: 0.98, dims: false) }
}
