//
//  OnboardingTests.swift
//  ROMEUITests
//
//  The flow after creating an account, and the way past it.
//

import XCTest

final class OnboardingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Skips the sign-up form, whose password fields cannot be driven
        // reliably: iOS's AutoFill overlay swallows typing into a
        // `.newPassword` field. The form itself is covered by the flow tests.
        app.launchArguments += ["-uiTestNewAccount"]
        app.launch()
    }

    func testCompletingOnboardingFiltersTheShop() throws {
        wait(1.5)
        capture("onboard-01-species")

        XCTAssertTrue(
            app.buttons["species-cat"].firstMatch.waitForExistence(timeout: 8),
            "Onboarding should follow account creation"
        )

        tap("species-cat")
        wait(0.6)
        tap("onboarding-continue")
        wait(1.2)
        capture("onboard-02-pet")

        type(into: app.windows.textFields["Name"].firstMatch, "Mochi")
        wait(0.5)
        tap("onboarding-continue")
        wait(2.2)
        capture("onboard-03-done")

        tap("onboarding-continue")
        wait(2.0)
        capture("onboard-04-filtered-shop")

        // The point of asking is that the answer gets used: the shop should
        // open on the species that was picked, not on the default.
        XCTAssertTrue(
            app.staticTexts["For Cats"].waitForExistence(timeout: 8),
            "The shop should open filtered to the species chosen during onboarding"
        )

        // And the pet that was named should be in My Pets.
        tap("My Pets")
        wait(1.6)
        XCTAssertTrue(
            app.buttons["pet-Mochi"].firstMatch.waitForExistence(timeout: 8),
            "The pet added during onboarding should be saved"
        )
    }

    func testSkippingLeavesAWayBack() throws {
        wait(1.5)

        tap("onboarding-skip")
        wait(2.0)

        XCTAssertTrue(
            app.buttons["Shop"].firstMatch.waitForExistence(timeout: 8),
            "Skipping should land in the app"
        )

        // Skipping is a detour, not a dead end — My Pets still offers the way in.
        tap("My Pets")
        wait(1.6)
        XCTAssertTrue(
            app.buttons["add-pet"].firstMatch.waitForExistence(timeout: 8),
            "My Pets should still offer a way to add a pet after skipping"
        )
    }

    // MARK: - Steps

    // MARK: - Helpers

    private func type(into element: XCUIElement, _ text: String) {
        guard element.waitForExistence(timeout: 8) else {
            XCTFail("Expected a field to type \"\(text)\" into")
            return
        }
        element.tap()
        element.typeText(text)
        wait(0.3)
    }

    private func tap(_ identifier: String) {
        let element = app.buttons[identifier].firstMatch
        guard element.waitForExistence(timeout: 10) else {
            XCTFail("Expected \(identifier) to exist")
            return
        }
        element.tap()
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
