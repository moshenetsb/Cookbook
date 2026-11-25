import XCTest

final class RecipeFlowUITests: XCTestCase {
    @MainActor
    private func launch() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchEnvironment["COOKBOOK_UI_TESTING"] = "1"
        app.launchArguments = ["-AppleLanguages", "(pl)", "-AppleLocale", "pl_PL"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Szukaj"].waitForExistence(timeout: 10))
        return app
    }

    @MainActor
    private func search(_ text: String, in app: XCUIApplication) {
        app.tabBars.buttons["Szukaj"].tap()
        let field = app.textFields["recipeSearch"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(text)
    }

    @MainActor
    private func firstRecipe(in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "recipe-")).firstMatch
    }

    @MainActor
    private func firstHeart(in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "favorite-")).firstMatch
    }

    @MainActor
    func testFavoriteButtonDoesNotOpenRecipeAndSynchronizesWithFavorites() {
        let app = launch()
        search("Curry warzywne", in: app)
        let heart = firstHeart(in: app)
        XCTAssertTrue(heart.waitForExistence(timeout: 5))
        XCTAssertEqual(heart.value as? String, "Nieulubiony")
        heart.tap()
        XCTAssertEqual(heart.value as? String, "Ulubiony")
        XCTAssertTrue(app.navigationBars["Szukaj przepisów"].exists)
        // Powtórne kliknięcia muszą wracać do poprawnego stanu.
        heart.tap()
        XCTAssertEqual(heart.value as? String, "Nieulubiony")
        heart.tap()
        app.tabBars.buttons["Ulubione"].tap()
        let searchField = app.textFields["recipeSearch"]
        searchField.tap()
        searchField.typeText("Curry warzywne")
        let favorite = firstHeart(in: app)
        XCTAssertTrue(favorite.waitForExistence(timeout: 5))
        favorite.tap()
        XCTAssertTrue(app.staticTexts["Brak pasujących przepisów"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDetailServingsDoNotOverwriteDefaults() {
        let app = launch()
        app.tabBars.buttons["Ustawienia"].tap()
        app.buttons["increaseDefaultServings"].tap()
        app.buttons["increaseDefaultServings"].tap()
        XCTAssertEqual(app.staticTexts["defaultServingsValue"].label, "3")
        search("Tost z awokado", in: app)
        firstRecipe(in: app).tap()
        let stepper = app.steppers["servingsStepper"]
        if !stepper.isHittable { app.swipeUp() }
        XCTAssertEqual(stepper.value as? String, "3")
        stepper.buttons.element(boundBy: 1).tap()
        XCTAssertEqual(stepper.value as? String, "4")
        app.tabBars.buttons["Ustawienia"].tap()
        XCTAssertEqual(app.staticTexts["defaultServingsValue"].label, "3")
        app.tabBars.buttons["Szukaj"].tap()
        XCTAssertEqual(stepper.value as? String, "4")
        app.navigationBars["Przepis"].buttons.element(boundBy: 0).tap()
        firstRecipe(in: app).tap()
        XCTAssertEqual(stepper.value as? String, "3")
    }

    @MainActor
    func testDefaultsDoNotOverwriteAnInProgressDraft() {
        let app = launch()
        app.tabBars.buttons["Ustawienia"].tap()
        app.buttons["increaseDefaultServings"].tap()
        app.buttons["increaseDefaultServings"].tap()
        app.tabBars.buttons["Dodaj"].tap()
        let title = app.textFields["recipeTitle"]
        title.tap()
        title.typeText("Mój szkic")
        app.tabBars.buttons["Ustawienia"].tap()
        app.buttons["increaseDefaultServings"].tap()
        app.tabBars.buttons["Dodaj"].tap()
        XCTAssertEqual(app.textFields["recipeTitle"].value as? String, "Mój szkic")
        XCTAssertEqual(app.textFields["recipeServings"].value as? String, "3")
        app.buttons["Wyczyść"].tap()
        app.buttons["Odrzuć zmiany"].tap()
        XCTAssertEqual(app.textFields["recipeServings"].value as? String, "4")
    }

    @MainActor
    func testMediaOpensForRecipeWithoutStoredAttachmentsAndReopens() {
        let app = launch()
        // Dawna migracja przypinała media wyłącznie do wrapa. Tost ujawnia regresję.
        search("Tost z awokado", in: app)
        firstRecipe(in: app).tap()
        for _ in 0..<2 {
            let video = app.buttons["Obejrzyj film"]
            for _ in 0..<4 {
                if video.isHittable { break }
                app.swipeUp()
            }
            XCTAssertTrue(video.isHittable)
            video.tap()
            XCTAssertTrue(app.descendants(matching: .any)["videoPlayer"].waitForExistence(timeout: 10))
            XCTAssertFalse(app.staticTexts["Brak filmu"].exists)
            app.buttons["Gotowe"].tap()
            app.buttons["Instrukcja audio"].tap()
            XCTAssertTrue(app.staticTexts["wrap_chicken.wav"].waitForExistence(timeout: 5))
            let pause = app.buttons["Pauza"]
            XCTAssertTrue(pause.waitForExistence(timeout: 10))
            pause.tap()
            app.buttons["Odtwórz"].tap()
            XCTAssertTrue(pause.waitForExistence(timeout: 5))
            app.buttons["Gotowe"].tap()
        }
    }

    @MainActor
    func testEmptyRecipeShowsValidationInsteadOfSaving() {
        let app = launch()
        app.tabBars.buttons["Dodaj"].tap()
        let save = app.buttons["saveRecipe"]
        for _ in 0..<8 {
            if save.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(save.isHittable)
        save.tap()
        XCTAssertTrue(app.descendants(matching: .any)["recipeValidationSummary"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Dodaj przepis"].exists)
    }
}
