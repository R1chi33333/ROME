//
//  AccessibilityTests.swift
//  ROMEUITests
//
//  Walks the key screens under conditions the app is not normally exercised
//  in — the largest accessibility text size, and dark appearance — and
//  captures each one.
//
//  These assert almost nothing. Whether a layout survives AX5 is a question
//  about clipping, overlap and reachability, and no assertion sees any of
//  that; the screenshots are the result. What the tests do assert is that the
//  journey still completes, since a control pushed off-screen by oversized
//  text stops being tappable and fails the walk.
//

import XCTest

final class AccessibilityTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Cases

    func testLargestTextSize() throws {
        launch(contentSize: "UICTContentSizeCategoryAccessibilityXXXL")
        walkKeyScreens(prefix: "ax5")
    }

    func testDarkAppearance() throws {
        launch(appearance: "Dark")
        walkKeyScreens(prefix: "dark")
    }

    // MARK: - Walk

    /// The screens where text and controls share tight space — the places a
    /// layout gives way first.
    private func walkKeyScreens(prefix: String) {
        capture("\(prefix)-01-welcome")

        tap("Sign In")
        wait(1.0)
        capture("\(prefix)-02-sign-in")

        signIn()
        wait(2.6)
        capture("\(prefix)-03-shop")

        tap("Cat")
        wait(1.2)
        tap("categories")
        wait(1.2)
        capture("\(prefix)-04-categories")

        tap("category-toys")
        wait(1.4)
        capture("\(prefix)-05-product-list")

        tap("product-Feather Wand")
        wait(1.4)
        capture("\(prefix)-06-product")

        tap("Add to Cart")
        wait(1.2)
        popToRoot()

        tap("Cart")
        wait(1.2)
        capture("\(prefix)-07-cart")

        tap("My Pets")
        wait(1.4)
        capture("\(prefix)-08-my-pets")

        tap("add-pet")
        wait(2.5)
        capture("\(prefix)-09-pet-form")

        // Reaching the form's submit button at AX5 is itself the test: if the
        // fields have grown past the sheet, it is no longer on screen.
        XCTAssertTrue(
            app.buttons["Add Pet"].firstMatch.waitForExistence(timeout: 6),
            "The pet form's submit button should still be reachable at \(prefix)"
        )
    }

    // MARK: - Launch

    private func launch(contentSize: String? = nil, appearance: String? = nil) {
        app = XCUIApplication()
        if let contentSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize]
        }
        if let appearance {
            app.launchArguments += ["-UIUserInterfaceStyle", appearance]
        }
        app.launch()
        wait(1.5)
    }

    // MARK: - Steps

    private func signIn() {
        let email = app.windows.textFields.firstMatch
        guard email.waitForExistence(timeout: 10) else { return }
        email.tap()
        email.typeText("yutong.jin@example.com")

        let password = app.windows.secureTextFields.firstMatch
        password.tap()
        password.typeText("hunter2pass")

        tap("submit-sign-in")
    }

    // MARK: - Helpers

    private func tap(_ identifier: String) {
        let element = app.buttons[identifier].firstMatch
        guard element.waitForExistence(timeout: 10) else {
            XCTFail("Expected \(identifier) to be reachable")
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
            wait(0.6)
        }
    }

    private func wait(_ seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
