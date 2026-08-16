//
//  FlowWalkthroughTests.swift
//  ROMEUITests
//
//  Walks the app's main journeys end to end and captures a screenshot at each
//  step. Written to verify the flows hold together and to make visual review
//  possible without driving the simulator by hand.
//

import XCTest

final class FlowWalkthroughTests: XCTestCase {

    private var app: XCUIApplication!

    /// Screenshots land here so they can be reviewed outside the result bundle.
    private static let outputDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("forpets-shots", isDirectory: true)

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            at: Self.outputDirectory,
            withIntermediateDirectories: true
        )
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Journeys

    func testSignInThenShopThenCheckout() throws {
        capture("01-welcome")

        signIn()
        capture("02-home")

        // Species filter -> category grid -> product list -> detail
        tap(app.buttons["Cat"].firstMatch, describedAs: "Cat species chip")
        wait(0.8)
        capture("03-home-cat-filtered")

        tap(app.buttons["categories"].firstMatch, describedAs: "categories link")
        wait(0.8)
        capture("04-categories")

        tap(app.buttons["category-toys"].firstMatch, describedAs: "Toys category")
        wait(1.2)
        capture("05-product-list")

        tap(app.buttons["product-Feather Wand"].firstMatch, describedAs: "Feather Wand card")
        wait(0.8)
        capture("06-product-detail")

        tap(app.buttons["Add to Cart"].firstMatch, describedAs: "Add to Cart")
        wait(1.2)
        capture("07-added-toast")

        // The tab bar is hidden on pushed screens, so the cart tab is only
        // reachable once the stack is back at its root.
        popToRoot()
        tap(app.buttons["Cart"].firstMatch, describedAs: "Cart tab")
        wait(0.8)
        capture("08-cart")

        tap(app.buttons["checkout"].firstMatch, describedAs: "Checkout")
        wait(0.8)
        fillCheckout()
        capture("09-checkout")

        tap(app.buttons["Place Order"].firstMatch, describedAs: "Place Order")
        wait(2.6)
        capture("10-order-placed")
    }

    func testPetsAndProfile() throws {
        signIn()

        tap(app.buttons["My Pets"].firstMatch, describedAs: "My Pets tab")
        wait(1.2)
        capture("11-my-pets")

        tap(app.buttons["add-pet"].firstMatch, describedAs: "add pet button")
        // Sheets need longer than a push: the accessibility snapshot cannot be
        // taken while the presentation is still animating, and that failure
        // raises rather than letting `waitForExistence` retry.
        wait(2.5)
        capture("13-add-pet-empty")

        fillPetForm()
        capture("14-add-pet-filled")

        tap(app.buttons["Add Pet"].firstMatch, describedAs: "Add Pet submit")
        wait(1.5)
        capture("15-my-pets-after-add")

        tap(app.buttons["pet-Mochi"].firstMatch, describedAs: "Mochi pet card")
        wait(0.8)
        capture("12-pet-detail")

        popToRoot()

        tap(app.buttons["Profile"].firstMatch, describedAs: "Profile tab")
        wait(0.8)
        capture("16-profile")
    }

    // MARK: - Steps

    private func signIn() {
        tap(app.buttons["Sign In"].firstMatch, describedAs: "Sign In")
        wait(0.8)

        let email = app.textFields.firstMatch
        email.tap()
        email.typeText("yutong.jin@example.com")

        let password = app.secureTextFields.firstMatch
        password.tap()
        password.typeText("hunter2pass")

        // Dismiss the keyboard so the button is hittable.
        tap(app.buttons["Sign In"].firstMatch, describedAs: "Sign In")
        wait(2.6)
    }

    private func fillCheckout() {
        // Full name is pre-filled from the account, so start at street address.
        type(into: app.textFields["Street address"], "12 Cavendish Road")
        type(into: app.textFields["City"], "Manchester")
        type(into: app.textFields["Postcode"], "M20 4TR")
        app.swipeUp()
        wait(0.5)
    }

    private func fillPetForm() {
        XCTAssertTrue(
            app.staticTexts["Basics"].waitForExistence(timeout: 10),
            "Expected the Add Pet form to be on screen"
        )

        // Window-scoped: a sheet is presented in its own window, and the
        // application-rooted `app.textFields` query does not descend into it —
        // it raises "no matches" even though a tree dump at the same instant
        // lists the fields. Going through `app.windows` reaches both.
        type(into: field("Name"), "Pepper")
        type(into: field("Breed"), "Corn Snake")

        tap(app.buttons["Reptile"].firstMatch, describedAs: "Reptile species option")
        wait(0.4)

        // Put the keyboard away first: it covers the lower half of the form,
        // and a covered field is not in the hittable tree.
        app.staticTexts["Details"].tap()
        wait(0.8)

        let weight = field("Weight (kg)")
        if !weight.waitForExistence(timeout: 3) {
            app.swipeUp()
            wait(0.8)
        }
        type(into: weight, "0.9")

        app.swipeUp()
        wait(0.6)

        let neutered = app.switches.firstMatch
        if neutered.waitForExistence(timeout: 3) {
            neutered.tap()
        }
        wait(0.5)
    }

    // MARK: - Helpers

    /// Waits for the field rather than querying once. A bare `exists` check
    /// resolves the query immediately and throws if the view is still
    /// animating in — which a sheet always is for the first moment.
    private func type(into field: XCUIElement, _ text: String) {
        XCTAssertTrue(
            field.waitForExistence(timeout: 8),
            "Expected a text field to type \"\(text)\" into"
        )
        field.tap()
        field.typeText(text)
    }

    /// A text field found across every window, including sheets.
    private func field(_ label: String) -> XCUIElement {
        app.windows.textFields[label].firstMatch
    }

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

    /// Taps the navigation bar's back button until the stack is at its root,
    /// which is when the custom tab bar comes back.
    private func popToRoot(limit: Int = 5) {
        for _ in 0..<limit {
            if app.buttons["Shop"].firstMatch.exists { return }
            let back = app.navigationBars.buttons.element(boundBy: 0)
            guard back.exists else { return }
            back.tap()
            wait(0.6)
        }
    }

    /// Captures the app rather than the whole screen. `XCUIScreen.main`
    /// screenshots were observed to leave the app's accessibility snapshot
    /// unresolvable for the query that followed, which shows up as a spurious
    /// "no matches found" on a control that is plainly on screen.
    private func capture(_ name: String) {
        let screenshot = app.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let url = Self.outputDirectory.appendingPathComponent("\(name).png")
        try? screenshot.pngRepresentation.write(to: url)
    }
}
