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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed && dims ? 0.85 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableStyle {
    /// The app's default press feedback.
    static var pressable: PressableStyle { PressableStyle() }

    /// Gentler press for large surfaces like cards, where a 4% shrink reads as
    /// a glitch rather than a press.
    static var pressableCard: PressableStyle { PressableStyle(scale: 0.98, dims: false) }
}
