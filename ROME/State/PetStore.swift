//
//  PetStore.swift
//  ROME
//
//  Holds the user's pets for the UI, reading and writing through `DataStore`.
//  Today that store is in-memory; the store swap is invisible from here.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class PetStore {

    private(set) var pets: [Pet] = []
    private(set) var isLoading = false

    private let dataStore: DataStore

    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }

    func load() async {
        guard pets.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        await fetch()
    }

    /// Re-reads the store even when pets are already loaded. Used by pull to
    /// refresh, which must not be a no-op just because the list is populated.
    func reload() async {
        await fetch()
        // Keeps the pull-to-refresh animation legible against a store that
        // returns almost immediately.
        try? await Task.sleep(for: .milliseconds(500))
    }

    /// Drops everything held for the current account. Called on sign out so
    /// the next session does not inherit the last one's pets.
    func clear() {
        pets = []
    }

    private func fetch() async {
        let loaded = (try? await dataStore.pets()) ?? []
        withAnimation(.smooth(duration: 0.35)) {
            pets = loaded
        }
    }

    func save(_ pet: Pet) async {
        try? await dataStore.savePet(pet)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let index = pets.firstIndex(where: { $0.id == pet.id }) {
                pets[index] = pet
            } else {
                pets.append(pet)
            }
        }
    }

    func delete(_ pet: Pet) async {
        try? await dataStore.deletePet(id: pet.id)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            pets.removeAll { $0.id == pet.id }
        }
    }

    /// Species the user actually owns — used to sort the shop's species row so
    /// their pets come first.
    var ownedSpecies: [PetSpecies] {
        var seen = Set<PetSpecies>()
        return pets.compactMap { seen.insert($0.species).inserted ? $0.species : nil }
    }
}
