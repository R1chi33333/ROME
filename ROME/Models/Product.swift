//
//  Product.swift
//  ROME
//

import Foundation

struct Product: Identifiable, Hashable, Codable {
    let id: UUID
    /// Doubles as the placeholder thumbnail's text, so it must stay short
    /// enough to read at card size — roughly three words.
    let name: String
    let species: [PetSpecies]
    let category: ProductCategory
    let price: Decimal
    let rating: Double
    let reviewCount: Int
    let summary: String
    /// Size or flavour options. Empty means the product has no variants.
    let variants: [String]

    init(
        id: UUID = UUID(),
        name: String,
        species: [PetSpecies],
        category: ProductCategory,
        price: Decimal,
        rating: Double,
        reviewCount: Int,
        summary: String,
        variants: [String] = []
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.category = category
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.summary = summary
        self.variants = variants
    }

    /// The species whose tint colours this product's placeholder thumbnail.
    var primarySpecies: PetSpecies { species.first ?? .dog }

    var formattedPrice: String {
        price.formattedPrice
    }
}
