import SwiftUI

enum AppTab: Hashable {
    case home, search, favorites, add, settings
}

struct ContentView: View {
    @Environment(RecipeStore.self) private var store
    @State private var selectedTab: AppTab = .home
    @State private var searchFilter = RecipeFilter()
    @State private var searchQuery = ""

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
        .alert("Nie udało się wykonać operacji", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "Spróbuj ponownie.")
        }
    }
}
