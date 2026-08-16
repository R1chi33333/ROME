//
//  FavoritesStore.swift
//  ROME
//
//  Which products the user has hearted. In memory only, like the cart.
//
//  This lives outside `ProductCard` for a structural reason: the card sits
//  inside a `NavigationLink`, and a button nested in a link's label does not
//  reliably receive its own taps. The heart is therefore composed on top of
//  the link rather than inside it, which means its state cannot live in the
//  card.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class FavoritesStore {

    private(set) var favoriteIDs: Set<UUID> = []

    func isFavorite(_ product: Product) -> Bool {
        favoriteIDs.contains(product.id)
    }

    /// Called on sign out — favourites belong to the account, not the device.
    func clear() {
        favoriteIDs = []
    }

    func toggle(_ product: Product) {
        if favoriteIDs.contains(product.id) {
            favoriteIDs.remove(product.id)
        } else {
            favoriteIDs.insert(product.id)
        }
    }

    /// Binding suitable for `FavoriteButton`.
    func binding(for product: Product) -> Binding<Bool> {
        Binding(
            get: { self.favoriteIDs.contains(product.id) },
            set: { newValue in
                if newValue {
                    self.favoriteIDs.insert(product.id)
                } else {
                    self.favoriteIDs.remove(product.id)
                }
            }
        )
    }
}
