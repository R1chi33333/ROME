//
//  GuestModeTests.swift
//  ROMEUITests
//
//  Walks the guest path: browse without an account, hit the wall at My Pets,
//  sign in from there, and land back with the pet list available.
//

import XCTest

final class GuestModeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testGuestCanBrowseButMustSignInForPets() throws {
        tap(app.buttons["Browse as guest"].firstMatch, describedAs: "guest entry")
        wait(1.5)
        capture("guest-01-home")

        // Browsing is open: the shop hierarchy works with no account.
        tap(app.buttons["Cat"].firstMatch, describedAs: "Cat chip")
        wait(1.2)
        tap(app.buttons["categories"].firstMatch, describedAs: "categories link")
        wait(1.0)
        tap(app.buttons["category-toys"].firstMatch, describedAs: "Toys category")
        wait(1.2)
        capture("guest-02-product-list")

        XCTAssertTrue(
            app.buttons["product-Feather Wand"].firstMatch.waitForExistence(timeout: 5),
            "A guest should be able to browse products"
        )

        popToRoot()

        // My Pets is gated.
        tap(app.buttons["My Pets"].firstMatch, describedAs: "My Pets tab")
        wait(1.2)
        capture("guest-03-pets-gated")

        XCTAssertTrue(
            app.staticTexts["Your pets live here"].waitForExistence(timeout: 5),
            "A guest should be stopped at My Pets"
        )
        XCTAssertFalse(
            app.buttons["add-pet"].firstMatch.exists,
            "The add button should not be offered to a guest"
        )

        // Sign in from the gate. Identifiers rather than titles here: the gate
        // stays mounted behind the sheet, so several "Sign In" buttons are in
        // the tree at once and `firstMatch` picks the wrong one.
        tap(app.buttons["gate-sign-in"].firstMatch, describedAs: "gate sign-in button")
        wait(2.0)
        capture("guest-04-prompt")

        XCTAssertTrue(
            app.staticTexts["Sign in to add a pet"].waitForExistence(timeout: 5),
            "The prompt should say what the sign-in is for"
        )

        tap(app.buttons["prompt-sign-in"].firstMatch, describedAs: "prompt sign-in")
        wait(1.5)
        signInForm()

        // Back on My Pets, now with an account.
        wait(2.5)
        capture("guest-05-pets-unlocked")

        XCTAssertTrue(
            app.buttons["add-pet"].firstMatch.waitForExistence(timeout: 8),
            "The add button should appear once signed in"
        )
    }

    // MARK: - Steps

    private func signInForm() {
        let email = app.windows.textFields.firstMatch
        XCTAssertTrue(email.waitForExistence(timeout: 8), "Expected the email field")
        email.tap()
        email.typeText("yutong.jin@example.com")

        let password = app.windows.secureTextFields.firstMatch
        password.tap()
        password.typeText("hunter2pass")

        tap(app.buttons["submit-sign-in"].firstMatch, describedAs: "submit")
        wait(3.0)
    }

    // MARK: - Helpers

    private func tap(_ element: XCUIElement, describedAs description: String) {
        XCTAssertTrue(
            element.waitForExistence(timeout: 8),
            "Expected \(description) to exist"
        )
        element.tap()
    }

    private func wait(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func popToRoot(limit: Int = 5) {
        for _ in 0..<limit {
            if app.buttons["Shop"].firstMatch.exists { return }
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists else { return }
            back.tap()
            wait(0.6)
        }
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
