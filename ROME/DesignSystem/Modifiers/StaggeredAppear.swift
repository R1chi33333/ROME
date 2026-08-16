//
//  StaggeredAppear.swift
//  ROME
//
//  Fades and lifts a view into place, delayed by its position in a list so a
//  group arrives in sequence rather than all at once.
//

import SwiftUI

struct StaggeredAppear: ViewModifier {

    let index: Int
    var offset: CGFloat = 14
    var stagger: Double = 0.06
    /// Delay before the first item starts, for screens that transition in.
    var initialDelay: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            // Reduce Motion keeps the fade but drops the travel, and the
            // cascade collapses to a single simultaneous appearance.
            .offset(y: hasAppeared || reduceMotion ? 0 : offset)
            .onAppear {
                let delay = reduceMotion
                    ? initialDelay
                    : initialDelay + Double(index) * stagger
                withAnimation(
                    (reduceMotion ? AppMotion.fade : .spring(response: 0.5, dampingFraction: 0.85))
                        .delay(delay)
                ) {
                    hasAppeared = true
                }
            }
    }
}

extension View {
    /// Staggered entrance. `index` is the view's position in its group.
    func staggeredAppear(
        index: Int,
        offset: CGFloat = 14,
        stagger: Double = 0.06,
        initialDelay: Double = 0
    ) -> some View {
        modifier(
            StaggeredAppear(
                index: index,
                offset: offset,
                stagger: stagger,
                initialDelay: initialDelay
            )
        )
    }
}
