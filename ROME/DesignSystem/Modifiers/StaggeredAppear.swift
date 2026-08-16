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

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : offset)
            .onAppear {
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.85)
                    .delay(initialDelay + Double(index) * stagger)
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
