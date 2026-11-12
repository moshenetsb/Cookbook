import SwiftUI

@main
@MainActor
struct CookBookApp: App {
    @State private var store = RecipeStore(repository: InMemoryRecipeRepository())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .tint(AppTheme.green)
                .preferredColorScheme(.light)
        }
    }
}
