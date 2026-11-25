import XCTest
@testable import CookBook

final class RecipeLogicTests: XCTestCase {
    @MainActor
    func testQuantityParsesPolishDecimalFractionAndText() throws {
        let decimal = try XCTUnwrap(IngredientDraft.parseQuantity(" 1,5 łyżki "))
        XCTAssertEqual(decimal.amount, 1.5)
        XCTAssertEqual(decimal.unit, "łyżki")
        XCTAssertEqual(IngredientDraft.parseQuantity("1/2 szt.")?.amount, 0.5)
        XCTAssertEqual(IngredientDraft.parseQuantity("250g")?.amount, 250)
        let text = try XCTUnwrap(IngredientDraft.parseQuantity("do smaku"))
        XCTAssertNil(text.amount)
        XCTAssertEqual(text.unit, "do smaku")
    }

    @MainActor
    func testInvalidQuantitiesAreRejected() {
        for input in ["", "0 g", "-2 g", "1/0 szt.", "1/2/3", "1..5 g", "1-2 g", "1 1/2 szklanki", "1e999 g"] {
            XCTAssertNil(IngredientDraft.parseQuantity(input), input)
        }
    }

    @MainActor
    func testScalingUsesBaseServingsWithoutMutatingIngredient() {
        let ingredient = Ingredient("Mąka", 200, "g")
        XCTAssertEqual(ingredient.quantity(for: 3, baseServings: 2), "300 g")
        XCTAssertEqual(ingredient.quantity(for: 1, baseServings: 2), "100 g")
        XCTAssertEqual(ingredient.amount, 200)
        XCTAssertEqual(Ingredient("Sól", nil, "do smaku").quantity(for: 8, baseServings: 2), "do smaku")
    }

    @MainActor
    func testScalingHandlesInvalidLegacyServingsWithoutDividingByZero() {
        XCTAssertEqual(Ingredient("Ryż", 100, "g").quantity(for: 0, baseServings: 0), "100 g")
    }

    @MainActor
    func testNewDraftUsesDefaultButEditUsesRecipeBaseServings() {
        XCTAssertEqual(RecipeDraft(defaultServings: 4).servings, "4")
        let recipe = Recipe(title: "Zupa", servings: 2)
        XCTAssertEqual(RecipeDraft(recipe: recipe, defaultServings: 4).servings, "2")
        XCTAssertEqual(recipe.servings, 2)
    }

    @MainActor
    func testInvalidDefaultsAreClamped() {
        XCTAssertEqual(RecipeDraft(defaultServings: -5).servings, "1")
        XCTAssertEqual(RecipeDraft(defaultServings: 200).servings, "12")
    }

    @MainActor
    func testUnchangedEditPreservesIngredientPrecisionAndIDs() throws {
        for amount in [1.0 / 3.0, 0.000001, 1234567.123456] {
            let original = Recipe(title: "Przepis", ingredients: [Ingredient("Sól", amount, "g")],
                                  steps: [PreparationStep("Krok", "Wymieszaj")])
            let edited = try RecipeDraft(recipe: original).makeRecipe().get()
            XCTAssertEqual(edited.ingredients.first?.amount, amount)
            XCTAssertEqual(edited.ingredients.first?.id, original.ingredients.first?.id)
            XCTAssertEqual(edited.steps.first?.id, original.steps.first?.id)
        }
    }

    @MainActor
    func testDraftDoesNotMutateOriginalBeforeSave() {
        let original = SampleRecipes.make()[0]
        let title = original.title
        let name = original.ingredients.sorted { $0.order < $1.order }[0].name
        var draft = RecipeDraft(recipe: original)
        draft.title = "Inny tytuł"
        draft.ingredients[0].name = "Inny składnik"
        XCTAssertEqual(original.title, title)
        XCTAssertEqual(original.ingredients.sorted { $0.order < $1.order }[0].name, name)
    }

    @MainActor
    func testEmptyDraftReportsRequiredFields() {
        let validation = RecipeDraft().validate()
        XCTAssertFalse(validation.isValid)
        XCTAssertEqual(validation.title, .titleRequired)
        XCTAssertEqual(validation.ingredientsIssue, .ingredientsRequired)
        XCTAssertEqual(validation.stepsIssue, .stepsRequired)
    }

    @MainActor
    func testPartialRowsAreNotSilentlyDropped() {
        var draft = RecipeDraft(recipe: SampleRecipes.make()[0])
        let ingredient = IngredientDraft(quantity: "100 g")
        let step = StepDraft(title: "Tytuł bez opisu")
        draft.ingredients.append(ingredient)
        draft.steps.append(step)
        let validation = draft.validate()
        XCTAssertEqual(validation.ingredientFields[ingredient.id]?.name, .ingredientNameRequired)
        XCTAssertEqual(validation.stepFields[step.id], .stepInstructionRequired)
    }

    @MainActor
    func testBlankExtraRowsAreIgnored() throws {
        var draft = RecipeDraft(recipe: SampleRecipes.make()[0])
        let count = draft.ingredients.count
        draft.ingredients.append(IngredientDraft())
        draft.steps.append(StepDraft())
        XCTAssertEqual(try draft.makeRecipe().get().ingredients.count, count)
    }

    @MainActor
    func testTimeAndServingValidationBoundaries() {
        var draft = RecipeDraft(recipe: SampleRecipes.make()[0])
        for value in ["0", "101", "1,5", "abc"] {
            draft.servings = value
            XCTAssertEqual(draft.validate().servingCountIssue, .invalidServings)
        }
        for value in ["1", "100"] {
            draft.servings = value
            XCTAssertTrue(draft.validate().isValid)
        }
        for value in ["0", "1441", "3.5"] {
            draft.time = value
            XCTAssertEqual(draft.validate().preparationTimeIssue, .invalidPreparationTime)
        }
        for value in ["1", "1440"] {
            draft.time = value
            XCTAssertTrue(draft.validate().isValid)
        }
    }

    @MainActor
    func testSearchMatchesPolishCharactersAndMultipleIngredients() {
        let recipes = SampleRecipes.make()
        XCTAssertEqual(RecipeFilter().apply(to: recipes, query: " LOSOS cytryna ").map(\.title), ["Łosoś z cytryną"])
        XCTAssertTrue(RecipeFilter().apply(to: recipes, query: "nieistniejącyskładnik").isEmpty)
    }

    @MainActor
    func testFiltersIntersectAndVegetarianIncludesVegan() {
        let recipes = SampleRecipes.make()
        let filter = RecipeFilter(time: .fifteen, diet: .vegetarian, category: .breakfast)
        XCTAssertEqual(Set(filter.apply(to: recipes).map(\.title)), Set(["Tost z awokado", "Owsianka jagodowa"]))
        XCTAssertEqual(filter.activeCount, 3)
        XCTAssertFalse(Diet.vegan.includes(.vegetarian))
    }

    @MainActor
    func testSortingAndTiesAreStable() {
        let first = Recipe(title: "B", preparationTime: 20)
        let second = Recipe(title: "A", preparationTime: 20)
        let fast = Recipe(title: "C", preparationTime: 10)
        XCTAssertEqual(RecipeFilter(sort: .fastest).apply(to: [first, second, fast]).map(\.id), [fast.id, first.id, second.id])
        XCTAssertEqual(RecipeFilter(sort: .alphabetical).apply(to: [first, second, fast]).map(\.title), ["A", "B", "C"])
    }

    @MainActor
    func testAllFifteenSampleRecipesAreValidAndUseDifferentPhotos() {
        let recipes = SampleRecipes.make()
        XCTAssertEqual(recipes.count, 15)
        XCTAssertEqual(Set(recipes.map(\.imageName)).count, 15)
        for recipe in recipes {
            XCTAssertTrue(RecipeDraft(recipe: recipe).validate().isValid, recipe.title)
            XCTAssertEqual(recipe.ingredients.sorted { $0.order < $1.order }.map(\.order), Array(0..<recipe.ingredients.count))
        }
    }
}
