//
//  ZoomTransition.swift
//  ROME
//
//  The card-to-detail zoom.
//
//  Tapping a product should feel like opening the thing that was tapped, not
//  like arriving at a different page that happens to describe it. The system
//  zoom transition does that: the card's thumbnail is the hero, continuously,
//  and the interactive dismiss drags it back to exactly the card it came from.
//
//  Source and destination have to agree on a namespace, and they live in
//  different files — the grid is in the shop screens, the destination is
//  registered once on the stack. Passing it through the environment keeps that
//  agreement in one place instead of threading a `Namespace.ID` through every
//  intermediate view.
//

import SwiftUI

private struct ProductZoomNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    /// Shared by every product card and the detail screen they open.
    var productZoomNamespace: Namespace.ID? {
        get { self[ProductZoomNamespaceKey.self] }
        set { self[ProductZoomNamespaceKey.self] = newValue }
    }
}

extension View {
    /// Marks a card as the origin of the zoom for `product`.
    @ViewBuilder
    func productZoomSource(_ product: Product, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            matchedTransitionSource(id: product.id, in: namespace)
        } else {
            self
        }
    }

    /// Marks the detail screen as the destination.
    @ViewBuilder
    func productZoomDestination(_ product: Product, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            navigationTransition(.zoom(sourceID: product.id, in: namespace))
        } else {
            self
        }
    }
}
