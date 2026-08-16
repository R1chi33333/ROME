//
//  CartItem.swift
//  ROME
//

import Foundation

struct CartItem: Identifiable, Hashable {
    let product: Product
    /// Which variant was chosen, if the product has any. Part of the identity:
    /// a Small and a Large of the same product are two separate lines.
    let variant: String?
    var quantity: Int

    var id: String {
        "\(product.id.uuidString)-\(variant ?? "default")"
    }

    var lineTotal: Decimal {
        product.price * Decimal(quantity)
    }

    var formattedLineTotal: String {
        lineTotal.formattedPrice
    }
}
