import SwiftUI
import SwiftData

private enum FavoritesFilter: String, CaseIterable, Identifiable {
    case all = "Wszystkie"
    case quick = "Do 30 min"
    case plantBased = "Roślinne"

    var id: String { rawValue }
}

struct FavoritesView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @State private var query = ""
    @State private var selection: FavoritesFilter = .all

    private var favorites: [Recipe] { recipes.filter(\.isFavorite) }
    private var countLabel: String {
        let count = favorites.count
        if count == 1 { return "zapisany przepis" }
        if (2...4).contains(count % 10) && !(12...14).contains(count % 100) {
            return "zapisane przepisy"
        }
        return "zapisanych przepisów"
    }
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
                            Text(countLabel)
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
                            description: Text(favorites.isEmpty ? "Dotknij serca przy wybranym przepisie" : "Zmień wyszukiwanie lub wybrany filtr")
                        )
                        .listRowSeparator(.hidden)
                    }
                }
            }
            .listStyle(.plain)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: results.map(\.id))
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Twoje ulubione")
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
