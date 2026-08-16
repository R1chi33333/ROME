//
//  PetSpecies.swift
//  ROME
//

import SwiftUI

/// The top-level way the shop is organised: who the product is for.
enum PetSpecies: String, CaseIterable, Identifiable, Hashable, Codable {
    case dog
    case cat
    case reptile
    case amphibian
    case bird
    case fish
    case smallPet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dog: return "Dog"
        case .cat: return "Cat"
        case .reptile: return "Reptile"
        case .amphibian: return "Amphibian"
        case .bird: return "Bird"
        case .fish: return "Fish"
        case .smallPet: return "Small Pets"
        }
    }

    /// Plural form used in headings, e.g. "Everything for Dogs".
    var pluralName: String {
        switch self {
        case .smallPet: return "Small Pets"
        default: return displayName + "s"
        }
    }

    /// All verified present in the system symbol set — see the note in
    /// `SampleData` about how these were checked.
    var symbolName: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .reptile: return "lizard.fill"
        case .amphibian: return "drop.fill"
        case .bird: return "bird.fill"
        case .fish: return "fish.fill"
        case .smallPet: return "hare.fill"
        }
    }

    /// A soft per-species hue. Used only as a low-opacity wash behind
    /// placeholder thumbnails, so products of one species read as a set.
    /// Never used for text.
    var tint: Color {
        switch self {
        case .dog: return Color(hex: 0xE08B45)
        case .cat: return Color(hex: 0x9B7BD4)
        case .reptile: return Color(hex: 0x4CA37A)
        case .amphibian: return Color(hex: 0x4A9BB5)
        case .bird: return Color(hex: 0xD4694E)
        case .fish: return Color(hex: 0x4A7FC1)
        case .smallPet: return Color(hex: 0xC08A6B)
        }
    }

    /// Categories that make sense for this species. A terrarium is not a thing
    /// you buy for a dog, and dogs are the only species here with a leash.
    var categories: [ProductCategory] {
        switch self {
        case .dog:
            return [.food, .treats, .toys, .grooming, .health, .accessories]
        case .cat:
            return [.food, .treats, .toys, .grooming, .health, .accessories]
        case .reptile:
            return [.food, .habitat, .health, .accessories]
        case .amphibian:
            return [.food, .habitat, .health, .accessories]
        case .bird:
            return [.food, .treats, .toys, .habitat, .health]
        case .fish:
            return [.food, .habitat, .health, .accessories]
        case .smallPet:
            return [.food, .treats, .toys, .habitat, .grooming, .accessories]
        }
    }
}
