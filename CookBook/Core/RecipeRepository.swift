import Foundation

// Punkt integracji dla osoby odpowiedzialnej za bazę danych.
// Widoki korzystają z RecipeStore, a nie z konkretnej implementacji repozytorium.
@MainActor
protocol RecipeRepository {
    func loadRecipes() throws -> [Recipe]
    func save(_ recipe: Recipe) throws
    func delete(id: UUID) throws
}

@MainActor
final class InMemoryRecipeRepository: RecipeRepository {
    private var recipes: [Recipe]

    init(recipes: [Recipe] = SampleRecipes.make()) {
        self.recipes = recipes
    }

    func loadRecipes() -> [Recipe] { recipes }

    func save(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.insert(recipe, at: 0)
        }
    }

    func delete(id: UUID) {
        recipes.removeAll { $0.id == id }
    }
}
