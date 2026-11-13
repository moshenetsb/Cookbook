import SwiftUI

private enum FavoritesFilter: String, CaseIterable, Identifiable {
    case all = "Wszystkie"
    case quick = "Do 30 min"
    case plantBased = "Roślinne"
    
    var id: String { rawValue }
}

struct FavoritesView: View {
    @Environment(RecipeStore.self) private var store
    @State private var query = ""
    @State private var selection: FavoritesFilter = .all
    
    private var favorites: [Recipe] { store.recipes.filter(\.isFavorite) }
    private var results: [Recipe] {
        var filter = RecipeFilter()
        if selection == .quick { filter.time = .thirty }
        if selection == .plantBased { filter.diet = .vegetarian }
        return filter.apply(to: favorites, query: query)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Przepisy, do których chcesz wrócić")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.muted)
                        SearchField(text: $query, prompt: "Szukaj w ulubionych")
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FavoritesFilter.allCases) { option in
                                    FilterChip(title: option.rawValue, isSelected: option == selection, prominent: true) { selection = option }
                                }
                            }
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(favorites.count)")
                                .font(.title.bold())
                            Text(favorites.count == 1 ? "zapisany przypis" : favorites.count < 5 ? "zapisane przypisy": "zapisanych przepisów")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.green)
                        }
                        .foregroundStyle(AppTheme.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12).background(AppTheme.mint, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(AppTheme.background)
                }
                
                Section {
                    
                    ForEach(results) { RecipeRow(recipe: $0) }
                        .listRowBackground(AppTheme.background)
                    
                    if results.isEmpty {
                        ContentUnavailableView(
                            favorites.isEmpty ? "Brak ulubionych" : "Brak pasujących przepisów",
                            systemImage: "heart",
                            description: Text(favorites.isEmpty ? "Dotknij serca przy wybranym przepisie." : "Zmień wyszukiwanie lub wybrany filtr.")
                        )
                        .listRowSeparator(.hidden)
                    }
                    Text("Wskazówka: zapisuj przepisy ikoną serca.")
                        .font(.caption).padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Twoje ulubione")
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
