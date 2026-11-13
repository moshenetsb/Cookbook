import SwiftUI

struct SearchView: View {
    @Environment(RecipeStore.self) private var store
    @Binding var filter: RecipeFilter
    @Binding var query: String
    @State private var showsFilters = false

    private var results: [Recipe] { filter.apply(to: store.recipes, query: query) }

    var body: some View {
        NavigationStack {
            List {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Wpisz składnik, nazwę potrawy lub danie")
                        .font(.subheadline).foregroundStyle(AppTheme.muted)
                    SearchField(text: $query)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Filtry · \(filter.activeCount)") { showsFilters = true }
                            FilterChip(title: "Do 30 min", isSelected: filter.time == .thirty, prominent: true) {
                                filter.time = filter.time == .thirty ? .any : .thirty
                            }
                            FilterChip(title: "Łatwe", isSelected: filter.difficulty == .easy) {
                                filter.difficulty = filter.difficulty == .easy ? nil : .easy
                            }
                        }
                    }
                    HStack {
                        Text("Znaleziono przepisów: \(results.count)").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Menu {
                            Picker("Sortowanie", selection: $filter.sort) {
                                ForEach(RecipeSort.allCases) { Text($0.rawValue).tag($0) }
                            }
                        } label: {
                            Label(filter.sort.rawValue, systemImage: "arrow.up.arrow.down").font(.caption)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(AppTheme.background)

                if results.isEmpty {
                    ContentUnavailableView {
                        Label("Brak wyników", systemImage: "magnifyingglass")
                    } description: {
                        Text("Zmień zapytanie lub wyczyść filtry.")
                    } actions: {
                        Button("Wyczyść wyszukiwanie i filtry") { query = ""; filter = RecipeFilter() }
                    }
                    .listRowSeparator(.hidden)
                }
                ForEach(results) { RecipeRow(recipe: $0) }
                    .listRowBackground(AppTheme.background)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Szukaj przepisów")
            .sheet(isPresented: $showsFilters) { FilterSheet(filter: $filter, query: query) }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

struct FilterSheet: View {
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: RecipeFilter
    @State private var draft: RecipeFilter
    let query: String

    init(filter: Binding<RecipeFilter>, query: String) {
        _filter = filter
        _draft = State(initialValue: filter.wrappedValue)
        self.query = query
    }

    var body: some View {
        NavigationStack {
            Form {
                Text("Zawęź wyniki do swoich potrzeb").font(.subheadline).foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                Section("Czas przygotowania") {
                    ForEach(PreparationTime.allCases) { time in
                        Button {
                            draft.time = time
                        } label: {
                            HStack {
                                Text(time.title).foregroundStyle(draft.time == time ? AppTheme.green : AppTheme.ink)
                                Spacer()
                                if draft.time == time { Image(systemName: "checkmark").foregroundStyle(AppTheme.green) }
                            }
                        }
                        .accessibilityAddTraits(draft.time == time ? [.isSelected] : [])
                    }
                }
                Section("Poziom trudności") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            FilterChip(title: "Dowolny", isSelected: draft.difficulty == nil) { draft.difficulty = nil }
                            ForEach(Difficulty.allCases) { difficulty in
                                FilterChip(title: difficulty.rawValue, isSelected: draft.difficulty == difficulty) {
                                    draft.difficulty = difficulty
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section("Dieta") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], alignment: .leading, spacing: 2) {
                        ForEach(Diet.allCases) { diet in
                            FilterChip(title: diet.rawValue, isSelected: draft.diet == diet) { draft.diet = diet }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section("Kategoria") {
                    Picker("Kategoria", selection: $draft.category) {
                        Text("Wszystkie kategorie").tag(Optional<RecipeCategory>.none)
                        ForEach(RecipeCategory.allCases) { Text($0.rawValue).tag(Optional($0)) }
                    }
                    .labelsHidden()
                }
                Section("Sortowanie") {
                    Picker("Kolejność", selection: $draft.sort) {
                        ForEach(RecipeSort.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .labelsHidden()
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Filtry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Anuluj") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Wyczyść") { draft = RecipeFilter() } }
            }
            .safeAreaInset(edge: .bottom) {
                Button("Pokaż wyniki (\(draft.apply(to: store.recipes, query: query).count))") {
                    filter = draft
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding().background(AppTheme.background)
            }
        }
    }
}
