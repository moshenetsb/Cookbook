import Foundation
import Observation

@MainActor
@Observable
final class RecipeStore {
    private(set) var recipes: [Recipe] = []
    var errorMessage: String?
    @ObservationIgnored private let repository: any RecipeRepository

    init(repository: any RecipeRepository) {
        self.repository = repository
        do {
            recipes = try repository.loadRecipes()
        } catch {
            errorMessage = "Nie udało się wczytać przepisów. \(error.localizedDescription)"
        }
    }

    func recipe(id: UUID) -> Recipe? {
        recipes.first { $0.id == id }
    }

    @discardableResult
    func save(_ recipe: Recipe) -> Bool {
        do {
            try repository.save(recipe)
            recipes = try repository.loadRecipes()
            return true
        } catch {
            errorMessage = "Nie udało się zapisać przepisu. \(error.localizedDescription)"
            return false
        }
    }

    @discardableResult
    func delete(id: UUID) -> Bool {
        do {
            try repository.delete(id: id)
            recipes = try repository.loadRecipes()
            return true
        } catch {
            errorMessage = "Nie udało się usunąć przepisu. \(error.localizedDescription)"
            return false
        }
    }

    func toggleFavorite(id: UUID) {
        guard var recipe = recipe(id: id) else { return }
        recipe.isFavorite.toggle()
        save(recipe)
    }
}
