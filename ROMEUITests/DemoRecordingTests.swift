//
//  DemoRecordingTests.swift
//  ROMEUITests
//
//  Drives the app through a paced walkthrough while the host records the
//  screen. This is a presentation script, not a test: it asserts almost
//  nothing and pauses deliberately so each screen is readable at playback
//  speed.
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
        beat(1.8)

        // 1 — Sign in. Checkout needs an account, and the order is what starts
        // the Live Activity this demo finishes on.
        tap("Sign In")
        beat(1.0)
        signIn()
        beat(2.4)

        // 2 — Pull to refresh: the paw grips the top, holds, then lets go.
        pullToRefresh()
        beat(2.4)

        // 3 — Switching species morphs the ambient background colour.
        tap("Cat")
        beat(1.8)
        tap("Dog")
        beat(1.8)
        tap("Cat")
        beat(1.6)

        // 4 — Down into a product.
        tap("categories")
        beat(1.6)
        tap("category-toys")
        beat(1.8)
        tap("product-Feather Wand")
        beat(2.2)

        // 5 — The fan: each tap on plus spreads another copy out from behind
        // the front one.
        for _ in 0..<3 {
            tap("increment-quantity")
            beat(1.0)
        }
        beat(1.4)

        tap("Add to Cart")
        beat(2.0)

        // 6 — Cart and checkout.
        popToRoot()
        tap("Cart")
        beat(2.0)
        tap("checkout")
        beat(1.6)
        fillCheckout()
        beat(1.2)
        tap("Place Order")
        beat(3.4)

        // 7 — Leave the app so the Live Activity takes over the Dynamic Island.
        XCUIDevice.shared.press(.home)
        beat(5.0)
    }

    // MARK: - Steps

    private func signIn() {
        let email = app.windows.textFields.firstMatch
        guard email.waitForExistence(timeout: 10) else { return }
        email.tap()
        email.typeText("yutong.jin@example.com")
        beat(0.5)

        let password = app.windows.secureTextFields.firstMatch
        password.tap()
        password.typeText("hunter2pass")
        beat(0.5)

        tap("submit-sign-in")
    }

    private func pullToRefresh() {
        // Starts on the promo banner: the species row above it is a horizontal
        // scroll view and would swallow the drag.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.46))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.86))
        start.press(
            forDuration: 0.25,
            thenDragTo: end,
            withVelocity: .slow,
            thenHoldForDuration: 1.4
        )
    }

    private func fillCheckout() {
        type(into: field("Street address"), "12 Cavendish Road")
        type(into: field("City"), "Manchester")
        type(into: field("Postcode"), "M20 4TR")
        app.staticTexts["Delivery speed"].firstMatch.tap()
        beat(0.6)
        app.swipeUp()
    }

    // MARK: - Helpers

    /// Window-scoped: a sheet is presented in its own window, and the
    /// application-rooted query does not descend into it.
    private func field(_ label: String) -> XCUIElement {
        app.windows.textFields[label].firstMatch
    }

    private func type(into element: XCUIElement, _ text: String) {
        guard element.waitForExistence(timeout: 8) else { return }
        element.tap()
        element.typeText(text)
        beat(0.3)
    }

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
