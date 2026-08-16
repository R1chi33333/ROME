//
//  AuthState.swift
//  ROME
//
//  TODO: This file is a placeholder for real authentication.
//
//  There is no account system, no password check and no network call. The
//  sign-in and sign-up methods wait briefly so the button's loading animation
//  has something to show, then mark the session as signed in with whatever the
//  form contained. Any credentials are accepted.
//
//  The guest case is not a placeholder, though — it is a real product state
//  that a real backend will still need, so `Session` is worth keeping as is.
//
//  Replacing this with a real implementation should not require changing any
//  view: the screens only read `phase` and call `signIn` / `signUp` / `signOut`.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class AuthState {

    /// Drives the primary button's idle → loading → success animation.
    enum Phase: Equatable {
        case idle
        case working
        case succeeded
    }

    /// Who is using the app. Guest is a real state, not "signed out": it gets
    /// past the welcome screen and into the shop, but owns no account, so
    /// anything that would write to one has to send it to sign in first.
    enum Session: Equatable {
        case signedOut
        case guest
        case signedIn(UserAccount)
    }

    private(set) var session: Session = .signedOut
    private(set) var phase: Phase = .idle

    /// True for guests as well — this is "may see the app", not "has an
    /// account". Use `isSignedIn` to gate anything that needs an account.
    var hasEntered: Bool { session != .signedOut }

    var isGuest: Bool { session == .guest }

    var isSignedIn: Bool { currentUser != nil }

    var currentUser: UserAccount? {
        if case .signedIn(let user) = session { return user }
        return nil
    }

    /// How long the fake request "takes". Long enough to see the loading dots,
    /// short enough not to feel broken.
    private let fakeLatency: Duration = .milliseconds(1200)
    private let successHold: Duration = .milliseconds(450)

    func signIn(email: String) async {
        await runFakeRequest {
            UserAccount(name: Self.nameFromEmail(email), email: email)
        }
    }

    func signUp(name: String, email: String) async {
        await runFakeRequest {
            UserAccount(name: name.isEmpty ? Self.nameFromEmail(email) : name, email: email)
        }
    }

    /// Enters the app without an account. Instant — there is nothing to wait
    /// for, and a fake delay here would only make browsing feel gated.
    func continueAsGuest() {
        withAnimation(.smooth(duration: 0.4)) {
            session = .guest
        }
        phase = .idle
    }

    func signOut() {
        withAnimation(.smooth(duration: 0.35)) {
            session = .signedOut
        }
        phase = .idle
    }

    // MARK: - Private

    /// Runs the shared idle → working → succeeded sequence, then commits the
    /// user. The success state is held briefly so the checkmark is visible
    /// before the screen transitions away.
    private func runFakeRequest(makeUser: @escaping () -> UserAccount) async {
        guard phase == .idle else { return }

        phase = .working
        try? await Task.sleep(for: fakeLatency)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            phase = .succeeded
        }
        try? await Task.sleep(for: successHold)

        withAnimation(.smooth(duration: 0.4)) {
            session = .signedIn(makeUser())
        }
        phase = .idle
    }

    /// Turns "yutong.jin@example.com" into "Yutong Jin" so the profile screen
    /// has something to show. Purely cosmetic.
    private static func nameFromEmail(_ email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? email
        let words = local
            .split(whereSeparator: { $0 == "." || $0 == "_" || $0 == "-" })
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
        return words.isEmpty ? "Pet Parent" : words.joined(separator: " ")
    }
}
