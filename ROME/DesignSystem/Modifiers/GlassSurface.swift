//
//  GlassSurface.swift
//  ROME
//
//  Liquid Glass, applied where the HIG says it belongs.
//
//  Glass is for the layer that floats above content — navigation and controls
//  — not for content itself. So it goes on the tab bar and the bottom action
//  bars, and deliberately not on product cards, which are content and would
//  turn the screen into glass on glass.
//
//  Grouping matters too: sibling glass elements have to sit inside a
//  `GlassEffectContainer` for their shapes to blend and morph correctly rather
//  than each sampling the background on its own.
//

import SwiftUI

extension View {

    /// The floating navigation layer — tab bar, action bars.
    ///
    /// `interactive` lets the material respond to touch, which is what makes
    /// it feel like a physical control rather than a blurred rectangle.
    func floatingGlass(in shape: some Shape, tinted: Color? = nil) -> some View {
        glassEffect(
            .regular
                .tint(tinted)
                .interactive(),
            in: shape
        )
    }

    /// Small controls that sit over content — the favourite heart on a
    /// product image, the back chevron over a hero.
    func controlGlass(tinted: Color? = nil) -> some View {
        glassEffect(.regular.tint(tinted).interactive(), in: Circle())
    }
}
