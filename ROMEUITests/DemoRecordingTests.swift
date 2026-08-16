//
//  DemoRecordingTests.swift
//  ROMEUITests
//
//  Drives the app through a paced walkthrough while the host records the
//  screen. This is a presentation script, not a test: it asserts nothing and
//  pauses deliberately so each screen is readable at playback speed.
//
//  Run it under `xcrun simctl io <device> recordVideo`; see docs/record-demo.sh.
//

import XCTest

final class DemoRecordingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testRecordDemo() throws {
        beat(2.0)

        // 1 — Guest entry. Browsing is open to everyone.
        tap("Browse as guest")
        beat(2.2)

        // 2 — Pull to refresh. Starts on the promo banner rather than the
        // species row, which is a horizontal scroll view and would swallow
        // the drag.
        pullToRefresh()
        beat(2.6)

        // 3 — Filter by species.
        tap("Cat")
        beat(1.8)

        // 4 — Into the category grid, then a product list.
        tap("categories")
        beat(1.8)
        tap("category-toys")
        beat(2.0)

        // 5 — Product detail, then add to the cart.
        tap("product-Feather Wand")
        beat(2.4)
        tap("Add to Cart")
        beat(2.2)

        // 6 — The cart, reached from the tab bar once back at the root.
        popToRoot()
        tap("Cart")
        beat(2.4)

        // 7 — My Pets, where a guest meets the account gate.
        tap("My Pets")
        beat(2.4)

        // 8 — Sign in from the gate and land back on an unlocked tab.
        tap("gate-sign-in")
        beat(2.0)
        tap("prompt-sign-in")
        beat(1.4)
        signIn()
        beat(3.0)

        // 9 — Finish on the profile.
        tap("Profile")
        beat(2.4)
    }

    // MARK: - Steps

    private func pullToRefresh() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.46))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.86))
        start.press(
            forDuration: 0.25,
            thenDragTo: end,
            withVelocity: .slow,
            thenHoldForDuration: 1.4
        )
    }

    private func signIn() {
        let email = app.windows.textFields.firstMatch
        guard email.waitForExistence(timeout: 8) else { return }
        email.tap()
        email.typeText("yutong.jin@example.com")
        beat(0.6)

        let password = app.windows.secureTextFields.firstMatch
        password.tap()
        password.typeText("hunter2pass")
        beat(0.6)

        tap("submit-sign-in")
    }

    // MARK: - Helpers

    private func tap(_ identifier: String) {
        let element = app.buttons[identifier].firstMatch
        guard element.waitForExistence(timeout: 10) else {
            XCTFail("Demo script expected \(identifier)")
            return
        }
        element.tap()
    }

    private func popToRoot(limit: Int = 5) {
        for _ in 0..<limit {
            if app.buttons["Shop"].firstMatch.exists { return }
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists else { return }
            back.tap()
            beat(0.7)
        }
    }

    /// A deliberate pause. Named for what it is — pacing, not synchronisation.
    private func beat(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }
}
