//
//  UserAccount.swift
//  ROME
//

import Foundation

/// The signed-in user. Populated by `AuthState` from whatever the sign-in form
/// happened to contain — there is no account system behind it yet.
struct UserAccount: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var email: String

    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }

    /// Initials for the avatar circle, e.g. "Yutong Jin" -> "YJ".
    var initials: String {
        let letters = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}
