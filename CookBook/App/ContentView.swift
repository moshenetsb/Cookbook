import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, search, favorites, add, settings
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .home
    @State private var searchFilter = RecipeFilter()
    @State private var searchQuery = ""
    @State private var errorMessage: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onSearch: { filter in
                    searchFilter = filter
                    searchQuery = ""
                    selectedTab = .search
                },
                onSettings: { selectedTab = .settings }
            )
            .tabItem { Label("Start", systemImage: "house") }
            .tag(AppTab.home)

            SearchView(filter: $searchFilter, query: $searchQuery)
                .tabItem { Label("Szukaj", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            FavoritesView()
                .tabItem { Label("Ulubione", systemImage: "heart") }
                .tag(AppTab.favorites)

            RecipeFormView(onSaved: { _ in
                searchFilter = RecipeFilter(sort: .newest)
                searchQuery = ""
                selectedTab = .search
            })
                .tabItem { Label("Dodaj", systemImage: "plus") }
                .tag(AppTab.add)

            SettingsView()
                .tabItem { Label("Ustawienia", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .task {
            do {
                try RecipeSeeder.seedIfNeeded(in: modelContext)
            } catch {
                errorMessage = "Nie udało się wczytać przepisów. \(error.localizedDescription)"
            }
        }
        .alert("Nie udało się wykonać operacji", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Spróbuj ponownie.")
        }
    }
}
