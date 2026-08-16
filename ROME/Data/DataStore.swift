//
//  DataStore.swift
//  ROME
//
//  The seam between the UI and persistence.
//
//  Nothing is persisted yet — `MockDataStore` serves static sample data from
//  memory. When a real backend or SwiftData arrives, add a new type conforming
//  to this protocol and swap it in at the app root. No view needs to change.
//

import SwiftUI

protocol DataStore: Sendable {
    /// Products filtered by species and/or category. Passing `nil` for either
    /// means "any".
    func products(species: PetSpecies?, category: ProductCategory?) async throws -> [Product]

    /// The hand-picked set shown on the shop home.
    func featuredProducts() async throws -> [Product]

    func product(id: UUID) async throws -> Product?

    func pets() async throws -> [Pet]
    func savePet(_ pet: Pet) async throws
    func deletePet(id: UUID) async throws
}

// MARK: - Environment

private struct DataStoreKey: EnvironmentKey {
    static let defaultValue: DataStore = MockDataStore()
}

extension EnvironmentValues {
    /// The store screens read from. Swapping the implementation at the app
    /// root is all it takes to move the whole app onto real persistence.
    var dataStore: DataStore {
        get { self[DataStoreKey.self] }
        set { self[DataStoreKey.self] = newValue }
    }
}
