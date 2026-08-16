//
//  Pet.swift
//  ROME
//

import Foundation

struct Pet: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var species: PetSpecies
    var breed: String
    var weightKg: Double
    var birthday: Date?
    var isNeutered: Bool
    var notes: String

    init(
        id: UUID = UUID(),
        name: String,
        species: PetSpecies,
        breed: String = "",
        weightKg: Double = 0,
        birthday: Date? = nil,
        isNeutered: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.breed = breed
        self.weightKg = weightKg
        self.birthday = birthday
        self.isNeutered = isNeutered
        self.notes = notes
    }

    /// Switches to grams below a kilogram: rounding a 60 g gecko to "0.1 kg"
    /// loses most of the number.
    var formattedWeight: String {
        guard weightKg > 0 else { return "—" }
        if weightKg < 1 {
            return "\(Int((weightKg * 1000).rounded())) g"
        }
        return String(format: "%.1f kg", weightKg)
    }

    var neuteredLabel: String {
        isNeutered ? "Neutered / Spayed" : "Not neutered"
    }

    /// Whole years since `birthday`, or `nil` when no birthday is recorded.
    var ageInYears: Int? {
        guard let birthday else { return nil }
        return Calendar.current.dateComponents([.year], from: birthday, to: .now).year
    }

    var formattedAge: String {
        guard let years = ageInYears else { return "Age unknown" }
        return years == 1 ? "1 year old" : "\(years) years old"
    }

    /// The line shown under the pet's name on its card.
    var subtitle: String {
        let parts = [breed.isEmpty ? species.displayName : breed, formattedWeight]
        return parts.joined(separator: " · ")
    }

    /// First letter, for the monogram that stands in for a pet photo.
    var monogram: String {
        String(name.prefix(1)).uppercased()
    }
}
