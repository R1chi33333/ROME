//
//  CartStore.swift
//  ROME
//
//  In-memory cart. Cleared when the app quits — see `DataStore` for the note
//  on persistence.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class CartStore {

    private(set) var items: [CartItem] = []

    /// Bumped every time something is added, so the tab badge can bounce.
    private(set) var lastAddedAt: Date?

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool { items.isEmpty }

    var subtotal: Decimal {
        items.reduce(Decimal.zero) { $0 + $1.lineTotal }
    }

    /// Flat rate, waived over the threshold. Purely for the checkout summary.
    var shipping: Decimal {
        isEmpty || subtotal >= 50 ? 0 : 4.99
    }

    var total: Decimal { subtotal + shipping }

    var formattedSubtotal: String { subtotal.formattedPrice }
    var formattedShipping: String {
        shipping == 0 ? "Free" : shipping.formattedPrice
    }
    var formattedTotal: String { total.formattedPrice }

    // MARK: - Mutations

    func add(_ product: Product, variant: String?, quantity: Int = 1) {
        let newItem = CartItem(product: product, variant: variant, quantity: quantity)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            if let index = items.firstIndex(where: { $0.id == newItem.id }) {
                items[index].quantity += quantity
            } else {
                items.append(newItem)
            }
            lastAddedAt = .now
        }
    }

    func setQuantity(_ quantity: Int, for item: CartItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }

    func remove(_ item: CartItem) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.removeAll { $0.id == item.id }
        }
    }

    func clear() {
        withAnimation(.smooth(duration: 0.3)) {
            items.removeAll()
        }
    }

    /// How many of a given product/variant pair are already in the cart.
    func quantity(of product: Product, variant: String?) -> Int {
        let id = CartItem(product: product, variant: variant, quantity: 0).id
        return items.first { $0.id == id }?.quantity ?? 0
    }
}
