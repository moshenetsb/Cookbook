import SwiftData
import Foundation

struct RecipeSeeder {
    
    static func seedIfNeeded(in modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<Recipe>()
            let existingCount = try modelContext.fetchCount(descriptor)
            
            guard existingCount == 0 else { return }
            
            let recipe1Id = UUID()
            let recipe1 = Recipe(
                id: recipe1Id,
                title: "Domowe Spaghetti Bolognese",
                prepTime: 30,
                difficulty: .medium,
                servings: 4,
                category: "Obiad",
                diets: [.standard],
                isFavorite: true,
                isOfTheDay: true,
                createdAt: Date().addingTimeInterval(-86400 * 2)
            )
            
            recipe1.ingredients = [
                Ingredient(recipeId: recipe1Id, name: "Makaron spaghetti", amount: "400g"),
                Ingredient(recipeId: recipe1Id, name: "Mięso mielone wołowe", amount: "500g"),
                Ingredient(recipeId: recipe1Id, name: "Pomidory krojone w puszce", amount: "2 puszki"),
                Ingredient(recipeId: recipe1Id, name: "Czosnek", amount: "2 ząbki"),
                Ingredient(recipeId: recipe1Id, name: "Cebula", amount: "1 szt.")
            ]
            
            recipe1.steps = [
                CookingStep(recipeId: recipe1Id, stepNumber: 1, name: "Gotowanie makaronu", description: "Ugotuj makaron w osolonej wodzie al dente zgodnie z instrukcją na opakowaniu."),
                CookingStep(recipeId: recipe1Id, stepNumber: 2, name: "Smażenie mięsa", description: "Podsmaż posiekaną cebulę i czosnek na oliwie, dodaj mięso mielone i smaż do zbrązowienia."),
                CookingStep(recipeId: recipe1Id, stepNumber: 3, name: "Duszenie sosu", description: "Dodaj pomidory z puszki, dopraw solą i pieprzem. Duś na wolnym ogniu przez 15 minut, a następnie podawaj z makaronem.")
            ]
            
            modelContext.insert(recipe1)
            
            let recipe2Id = UUID()
            let recipe2 = Recipe(
                id: recipe2Id,
                title: "Wegański Toast z Awokado",
                prepTime: 10,
                difficulty: .easy,
                servings: 1,
                category: "Śniadanie",
                diets: [.vegetarian, .vegan, .glutenFree],
                isFavorite: false,
                isOfTheDay: false,
                createdAt: Date().addingTimeInterval(-86400)
            )
            
            recipe2.ingredients = [
                Ingredient(recipeId: recipe2Id, name: "Chleb bezglutenowy", amount: "2 kromki"),
                Ingredient(recipeId: recipe2Id, name: "Dojrzałe awokado", amount: "1 szt."),
                Ingredient(recipeId: recipe2Id, name: "Pomidorki koktajlowe", amount: "5 szt."),
                Ingredient(recipeId: recipe2Id, name: "Sok z cytryny", amount: "1 łyżeczka")
            ]
            
            recipe2.steps = [
                CookingStep(recipeId: recipe2Id, stepNumber: 1, name: "Opiekanie pieczywa", description: "Opiecz kromki chleba w tosterze lub na suchej patelni, aż będą chrupiące."),
                CookingStep(recipeId: recipe2Id, stepNumber: 2, name: "Przygotowanie awokado", description: "Rozgnieć miąższ awokado widelcem w miseczce, skrop sokiem z cytryny, dodaj sól i pieprz do smaku."),
                CookingStep(recipeId: recipe2Id, stepNumber: 3, name: "Składanie dania", description: "Rozsmaruj pastę z awokado na tostach i udekoruj połówkami pomidorków koktajlowych.")
            ]
            
            modelContext.insert(recipe2)
            
            try modelContext.save()
            print("Database seeded successfully!")
            
        } catch {
            print("Failed to seed database: \(error)")
        }
    }
}