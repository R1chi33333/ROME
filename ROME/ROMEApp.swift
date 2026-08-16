//
//  ROMEApp.swift
//  ROME
//
//  Created by R1chi3 on 16/08/2026.
//

import SwiftUI

@main
struct ROMEApp: App {

    /// The single place persistence is chosen. Swapping `MockDataStore` for a
    /// real implementation moves the whole app over — no view changes.
    private let dataStore: DataStore

    @State private var auth = AuthState()
    @State private var cart = CartStore()
    @State private var favorites = FavoritesStore()
    @State private var pets: PetStore

    init() {
        let store = MockDataStore()
        self.dataStore = store
        _pets = State(initialValue: PetStore(dataStore: store))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(cart)
                .environment(favorites)
                .environment(pets)
                .environment(\.dataStore, dataStore)
                .tint(AppColor.accent)
        }
    }
}

/// Switches between the signed-out and signed-in worlds.
private struct RootView: View {

    @Environment(AuthState.self) private var auth

    var body: some View {
        ZStack {
            // Guests get the same shell as signed-in users; the difference
            // shows up only where an account is actually required.
            if auth.hasEntered {
                RootTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                WelcomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .background(AppColor.background)
        .animation(.smooth(duration: 0.4), value: auth.hasEntered)
    }
}
