import SwiftData

enum RecipeSeeder {
    static func seedIfNeeded(in modelContext: ModelContext) throws {
        guard try modelContext.fetchCount(FetchDescriptor<Recipe>()) == 0 else { return }
        for recipe in SampleRecipes.make() {
            modelContext.insert(recipe)
        }
        try modelContext.save()
    }
}
