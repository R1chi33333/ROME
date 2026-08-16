//
//  MockDataStore.swift
//  ROME
//
//  In-memory `DataStore` backed by `SampleData`.
//
//  Everything here is lost when the app quits — that is expected for now.
//  Replace this type, not the views, when real persistence lands.
//

import Foundation

actor MockDataStore: DataStore {

    private var storedPets: [Pet] = SampleData.pets

    /// Small artificial delay so loading states and skeleton shimmers are
    /// actually exercised. A real store will have latency too.
    private let latency: Duration = .milliseconds(300)

    func products(species: PetSpecies?, category: ProductCategory?) async throws -> [Product] {
        try await Task.sleep(for: latency)
        return SampleData.products.filter { product in
            let speciesMatches = species.map { product.species.contains($0) } ?? true
            let categoryMatches = category.map { product.category == $0 } ?? true
            return speciesMatches && categoryMatches
        }
    }

    func featuredProducts() async throws -> [Product] {
        try await Task.sleep(for: latency)
        return SampleData.featured
    }

    func product(id: UUID) async throws -> Product? {
        SampleData.products.first { $0.id == id }
    }

    func pets() async throws -> [Pet] {
        try await Task.sleep(for: latency)
        return storedPets
    }

    func savePet(_ pet: Pet) async throws {
        if let index = storedPets.firstIndex(where: { $0.id == pet.id }) {
            storedPets[index] = pet
        } else {
            storedPets.append(pet)
        }
    }

    func deletePet(id: UUID) async throws {
        storedPets.removeAll { $0.id == id }
    }
}
