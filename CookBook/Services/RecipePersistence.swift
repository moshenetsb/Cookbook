import Foundation
import SwiftData

/// Każda operacja kończy się jawnym zapisem; błąd przywraca ostatni zapisany stan.
@MainActor
enum RecipePersistence {
    static func toggleFavorite(_ recipe: Recipe, in context: ModelContext) throws {
        recipe.isFavorite.toggle()
        try saveOrRollback(context)
    }

    static func delete(_ recipe: Recipe, in context: ModelContext) throws {
        let oldMedia = [recipe.video?.url, recipe.audio?.url].compactMap { $0 }
        context.delete(recipe)
        try saveOrRollback(context)
        removeUnreferencedMedia(oldMedia, in: context)
    }

    static func save(_ draft: RecipeDraft, in context: ModelContext) throws -> Recipe {
        let validated = try draft.makeRecipe().get()
        guard let recipe = draft.original else {
            context.insert(validated)
            try saveOrRollback(context)
            return validated
        }

        let oldMedia = [recipe.video?.url, recipe.audio?.url].compactMap { $0 }
        // Aktualizujemy istniejący obiekt, aby otwarte widoki zachowały jego tożsamość.
        recipe.title = validated.title
        recipe.summary = validated.summary
        recipe.category = validated.category
        recipe.diet = validated.diet
        recipe.preparationTime = validated.preparationTime
        recipe.difficulty = validated.difficulty
        recipe.servings = validated.servings
        recipe.imageName = validated.imageName
        recipe.imageData = validated.imageData
        recipe.video = validated.video
        recipe.audio = validated.audio

        let oldIngredients = recipe.ingredients
        let newIngredients = validated.ingredients.sorted { $0.order < $1.order }.map { value in
            let ingredient = oldIngredients.first { $0.id == value.id }
                ?? Ingredient(id: value.id, name: value.name)
            ingredient.name = value.name
            ingredient.amount = value.amount
            ingredient.unit = value.unit
            ingredient.order = value.order
            return ingredient
        }
        recipe.ingredients = newIngredients
        for ingredient in oldIngredients where !newIngredients.contains(where: { $0.id == ingredient.id }) {
            context.delete(ingredient)
        }

        let oldSteps = recipe.steps
        let newSteps = validated.steps.sorted { $0.order < $1.order }.map { value in
            let step = oldSteps.first { $0.id == value.id }
                ?? PreparationStep(id: value.id, title: value.title, instruction: value.instruction)
            step.title = value.title
            step.instruction = value.instruction
            step.order = value.order
            return step
        }
        recipe.steps = newSteps
        for step in oldSteps where !newSteps.contains(where: { $0.id == step.id }) {
            context.delete(step)
        }
        try saveOrRollback(context)
        removeUnreferencedMedia(oldMedia, in: context)
        return recipe
    }

    private static func removeUnreferencedMedia(_ urls: [URL], in context: ModelContext) {
        guard let recipes = try? context.fetch(FetchDescriptor<Recipe>()) else { return }
        let retained = Set(recipes.flatMap { [$0.video?.url, $0.audio?.url].compactMap { $0 } })
        MediaImporter.removeUnused(urls, keeping: retained)
    }

    private static func saveOrRollback(_ context: ModelContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
