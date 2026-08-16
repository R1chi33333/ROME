//
//  ProductCategory.swift
//  ROME
//

import Foundation

/// The second level of the shop hierarchy, sitting under a `PetSpecies`.
enum ProductCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case food
    case treats
    case toys
    case habitat
    case grooming
    case health
    case accessories

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .food: return "Food"
        case .treats: return "Treats"
        case .toys: return "Toys"
        case .habitat: return "Habitat"
        case .grooming: return "Grooming"
        case .health: return "Health"
        case .accessories: return "Accessories"
        }
    }

    var symbolName: String {
        switch self {
        case .food: return "fork.knife"
        case .treats: return "carrot.fill"
        case .toys: return "teddybear.fill"
        case .habitat: return "house.fill"
        case .grooming: return "comb.fill"
        case .health: return "cross.case.fill"
        case .accessories: return "bag.fill"
        }
    }

    /// Shown under the category name on the category grid.
    var blurb: String {
        switch self {
        case .food: return "Everyday nutrition"
        case .treats: return "Rewards and chews"
        case .toys: return "Play and enrichment"
        case .habitat: return "Homes and bedding"
        case .grooming: return "Coat, claws and clean"
        case .health: return "Care and supplements"
        case .accessories: return "Bowls, leads and more"
        }
    }
}
