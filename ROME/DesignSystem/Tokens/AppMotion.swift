//
//  AppMotion.swift
//  ROME
//
//  Design tokens — motion.
//
//  Every animation in the app resolves through here so that Reduce Motion is
//  handled in one place. The HIG asks that the setting remove or soften motion
//  rather than remove the feedback: a control that confirmed an action by
//  springing still has to confirm it, just without travelling. So the tokens
//  collapse to short cross-fades rather than to nothing.
//

import SwiftUI

enum AppMotion {

    /// Springs used for direct manipulation — a control responding under the
    /// finger. Quick, lightly damped.
    static func snappy(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.3, dampingFraction: 0.7)
    }

    /// The default for state changes that move layout around.
    static func standard(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.8)
    }

    /// Deliberately loose — used where an overshoot is the point, such as the
    /// content rebounding after pull to refresh lets go.
    static func bouncy(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.5, dampingFraction: 0.55)
    }

    /// Cross-fades and opacity work; they carry no motion, so Reduce Motion
    /// leaves them alone.
    static let fade = Animation.smooth(duration: 0.3)

    /// Per-item delay in a staggered entrance. Reduce Motion brings the whole
    /// group in at once — a cascade is motion even when each step is small.
    static func stagger(_ reduceMotion: Bool) -> Double {
        reduceMotion ? 0 : 0.06
    }
}

// MARK: - Convenience

extension View {
    /// Applies a motion token, resolving Reduce Motion from the environment.
    ///
    /// Reading the environment inside a modifier keeps call sites free of the
    /// `@Environment` boilerplate that would otherwise have to be repeated in
    /// every view that animates.
    func appAnimation<V: Equatable>(
        _ token: @escaping (Bool) -> Animation,
        value: V
    ) -> some View {
        modifier(MotionTokenModifier(token: token, value: value))
    }
}

private struct MotionTokenModifier<V: Equatable>: ViewModifier {
    let token: (Bool) -> Animation
    let value: V

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(token(reduceMotion), value: value)
    }
}
