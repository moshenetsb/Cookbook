import XCTest
#if canImport(CookBookCore)
@testable import CookBookCore
#else
@testable import CookBook
#endif

final class CookBookCoreTests: XCTestCase {
    func testDemoCatalogHasFifteenDistinctPhotosAndNoMedia() {
        let recipes = SampleRecipes.make()
        XCTAssertEqual(recipes.count, 15)
        XCTAssertEqual(Set(recipes.map(\.imageName)).count, 15)
        XCTAssertTrue(recipes.allSatisfy { !$0.imageName.isEmpty && $0.video == nil && $0.audio == nil })
    }

    func testEveryDemoRecipePassesFormValidation() {
        for recipe in SampleRecipes.make() {
            XCTAssertTrue(RecipeDraft(recipe: recipe).validationMessages.isEmpty, recipe.title)
        }
    }

    func testSearchFindsPolishNamesWithoutDiacritics() {
        let results = RecipeFilter().apply(to: SampleRecipes.make(), query: "  LOSOS  ")
        XCTAssertEqual(results.map(\.title), ["Łosoś z cytryną"])
    }

    func testSearchFindsIngredientsAndRequiresEveryWord() {
        let recipes = SampleRecipes.make()
        let results = RecipeFilter().apply(to: recipes, query: "orzo szpinak")
        XCTAssertEqual(results.map(\.title), ["Orzo z cytryną i ziołami"])
        XCTAssertTrue(RecipeFilter().apply(to: recipes, query: "orzo czekolada").isEmpty)
    }

    func testCombinedFiltersNarrowResults() {
        let filter = RecipeFilter(time: .thirty, difficulty: .easy, diet: .vegetarian, category: .pasta)
        XCTAssertEqual(filter.activeCount, 4)
        XCTAssertEqual(filter.apply(to: SampleRecipes.make()).map(\.title), ["Orzo z cytryną i ziołami", "Makaron pomidorowy"])
    }

    func testVegetarianFilterIncludesVeganDishes() {
        XCTAssertTrue(Diet.vegetarian.includes(.vegan))
        XCTAssertFalse(Diet.vegan.includes(.vegetarian))
        XCTAssertFalse(Diet.glutenFree.includes(.any))
    }

    func testNoTimeLimitDoesNotHideLongRecipes() {
        let slow = Recipe(title: "Powolne danie", preparationTime: 240)
        XCTAssertEqual(RecipeFilter().apply(to: [slow]).count, 1)
        XCTAssertTrue(RecipeFilter(time: .sixty).apply(to: [slow]).isEmpty)
    }

    func testSortNewestUsesCreationDate() {
        let old = Recipe(title: "Zupa", createdAt: Date(timeIntervalSince1970: 1))
        let recent = Recipe(title: "Awokado", createdAt: Date(timeIntervalSince1970: 100))
        XCTAssertEqual(RecipeFilter(sort: .newest).apply(to: [old, recent]).map(\.title), ["Awokado", "Zupa"])
    }

    func testFastestSortIsStableForEqualTimes() {
        let recipes = [Recipe(title: "A", preparationTime: 30), Recipe(title: "B", preparationTime: 10), Recipe(title: "C", preparationTime: 10)]
        XCTAssertEqual(RecipeFilter(sort: .fastest).apply(to: recipes).map(\.title), ["B", "C", "A"])
    }

    func testPortionsScaleUpAndDownWithoutChangingOriginalIngredient() {
        let ingredient = Ingredient("Orzo", 180, "g")
        XCTAssertEqual(ingredient.quantity(for: 4, baseServings: 2), "360 g")
        XCTAssertEqual(ingredient.quantity(for: 1, baseServings: 2), "90 g")
        XCTAssertEqual(ingredient.amount, 180)
        XCTAssertEqual(Ingredient("Sól", nil, "do smaku").quantity(for: 5, baseServings: 2), "do smaku")
    }

    func testQuantityAcceptsDecimalCommaAndFractions() {
        XCTAssertEqual(IngredientDraft.parseQuantity("1,5 łyżki")?.amount, 1.5)
        XCTAssertEqual(IngredientDraft.parseQuantity("1/2 szt.")?.amount, 0.5)
        XCTAssertEqual(IngredientDraft.parseQuantity("250g")?.unit, "g")
        XCTAssertNil(IngredientDraft.parseQuantity("1/0 szt."))
        XCTAssertNil(IngredientDraft.parseQuantity("0 g"))
        XCTAssertNil(IngredientDraft.parseQuantity("-2 g"))
    }

    func testInvalidFormCannotProduceRecipe() {
        var draft = RecipeDraft()
        draft.title = "  "
        draft.time = "0"
        draft.servings = "abc"
        XCTAssertNil(draft.makeRecipe())
        XCTAssertEqual(draft.validationMessages.count, 5)
    }

    func testIncompleteIngredientIsNotSilentlyDiscarded() {
        var draft = RecipeDraft(recipe: SampleRecipes.make()[0])
        draft.ingredients.append(IngredientDraft(name: "Sól", quantity: ""))
        XCTAssertNil(draft.makeRecipe())
    }

    func testEditPreservesIdentityFavoritePhotoAndCreationDate() throws {
        let original = SampleRecipes.make()[0]
        var draft = RecipeDraft(recipe: original)
        draft.title = "  Nowa nazwa  "
        let edited = try XCTUnwrap(draft.makeRecipe())
        XCTAssertEqual(edited.title, "Nowa nazwa")
        XCTAssertEqual(edited.id, original.id)
        XCTAssertEqual(edited.isFavorite, original.isFavorite)
        XCTAssertEqual(edited.imageName, original.imageName)
        XCTAssertEqual(edited.createdAt, original.createdAt)
        XCTAssertEqual(original.title, "Orzo z cytryną i ziołami")
    }

    @MainActor
    func testRepositorySupportsCreateEditFavoriteAndDelete() async throws {
        let repository = InMemoryRecipeRepository(recipes: [])
        var recipe = SampleRecipes.make()[0]
        repository.save(recipe)
        recipe.title = "Zmieniony przepis"
        recipe.isFavorite = false
        repository.save(recipe)
        XCTAssertEqual(repository.loadRecipes().count, 1)
        XCTAssertEqual(repository.loadRecipes().first?.title, "Zmieniony przepis")
        XCTAssertEqual(repository.loadRecipes().first?.isFavorite, false)
        repository.delete(id: recipe.id)
        XCTAssertTrue(repository.loadRecipes().isEmpty)
    }
}
