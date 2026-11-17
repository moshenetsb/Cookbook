import SwiftUI
import SwiftData

@main
@MainActor
struct CookBookApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Ingredient.self,
            PreparationStep.self,
            Recipe.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(AppTheme.green)
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
