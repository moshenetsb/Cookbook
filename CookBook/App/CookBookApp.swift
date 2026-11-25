import SwiftUI
import SwiftData

@main
@MainActor
struct CookBookApp: App {
    @State private var container: ModelContainer?
    @State private var startupError: String?
    private let defaults: UserDefaults
    private let isUITesting: Bool

    init() {
        #if DEBUG
        isUITesting = ProcessInfo.processInfo.environment["COOKBOOK_UI_TESTING"] == "1"
        #else
        isUITesting = false
        #endif
        if isUITesting {
            let suiteName = "CookBook.UITests"
            let isolatedDefaults = UserDefaults(suiteName: suiteName)!
            isolatedDefaults.removePersistentDomain(forName: suiteName)
            defaults = isolatedDefaults
        } else {
            defaults = .standard
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    ContentView()
                        .modelContainer(container)
                        .defaultAppStorage(defaults)
                } else if let startupError {
                    ContentUnavailableView {
                        Label("Nie udało się otworzyć książki", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("Twoje dane nie zostały usunięte. \(startupError)")
                    } actions: {
                        Button("Spróbuj ponownie", action: openStore)
                    }
                } else {
                    ProgressView("Otwieranie książki kucharskiej…")
                }
            }
            .tint(AppTheme.green)
            .preferredColorScheme(.light)
            .task { if container == nil && startupError == nil { openStore() } }
        }
    }

    private func openStore() {
        do {
            let schema = Schema([Ingredient.self, PreparationStep.self, Recipe.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
            let store = try ModelContainer(for: schema, configurations: [configuration])
            try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
            defaults.set(ServingPreferences.normalizedDefault(defaults.object(forKey: "defaultServings") as? Int ?? 1),
                         forKey: "defaultServings")
            container = store
            startupError = nil
        } catch {
            startupError = error.localizedDescription
        }
    }
}
