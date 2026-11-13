import SwiftUI
import SwiftData
import PhotosUI
import UIKit

enum AppTab: Hashable {
    case home, search, favorites, add, settings
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(recipes: recipes, selectedTab: $selectedTab)
                .tabItem { Label("Start", systemImage: "house.fill") }
                .tag(AppTab.home)

            SearchView(recipes: recipes)
                .tabItem { Label("Szukaj", systemImage: "magnifyingglass") }
                .tag(AppTab.search)

            FavoritesView(recipes: recipes)
                .tabItem { Label("Ulubione", systemImage: "heart") }
                .tag(AppTab.favorites)

            RecipeFormView()
                .tabItem { Label("Dodaj", systemImage: "plus.circle") }
                .tag(AppTab.add)

            SettingsView()
                .tabItem { Label("Ustawienia", systemImage: "gearshape") }
                .tag(AppTab.settings)
        }
        .tint(AppTheme.green)
        .task {
            SampleRecipes.insertIfNeeded(into: modelContext, existingCount: recipes.count)
        }
    }
}

enum AppTheme {
    static let green = Color(red: 36/255, green: 107/255, blue: 60/255)
    static let mint = Color(red: 230/255, green: 244/255, blue: 234/255)
    static let background = Color(red: 247/255, green: 251/255, blue: 248/255)
    static let border = Color(red: 220/255, green: 239/255, blue: 227/255)
    static let muted = Color(red: 142/255, green: 142/255, blue: 147/255)
}

struct HomeView: View {
    let recipes: [Recipe]
    @Binding var selectedTab: AppTab

    private var featured: Recipe? { recipes.first(where: { $0.title == "Orzo z cytryną i ziołami" }) ?? recipes.first }
    private var quickRecipes: [Recipe] { Array(recipes.filter { $0.id != featured?.id }.prefix(4)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 25, weight: .semibold))
                            .foregroundStyle(AppTheme.green)
                            .frame(width: 48, height: 48)
                            .background(AppTheme.mint, in: RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 0) {
                            Text("CookBook").font(.system(size: 27, weight: .bold)).foregroundStyle(AppTheme.green)
                            Text("DOBRE JEDZENIE, PROSTE POMYSŁY")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(0.5)
                                .foregroundStyle(AppTheme.muted)
                        }
                        Spacer()
                        Text("M")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.green)
                            .frame(width: 46, height: 46)
                            .background(AppTheme.mint, in: Circle())
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Co dziś ugotujemy?")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color(red: 28/255, green: 28/255, blue: 30/255))
                        Text("Sprawdzone przepisy na każdy dzień")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.muted)
                    }

                    Button { selectedTab = .search } label: {
                        Label("Znajdź swoje następne danie", systemImage: "magnifyingglass")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 15)
                            .frame(height: 48)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border))
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 9) {
                        QuickFilter(title: "Dla Ciebie", active: true) { selectedTab = .search }
                        QuickFilter(title: "Do 30 min") { selectedTab = .search }
                        QuickFilter(title: "Wegetariańskie") { selectedTab = .search }
                    }

                    if let featured {
                        NavigationLink(destination: RecipeDetailView(recipe: featured)) {
                            FeaturedRecipeCard(recipe: featured)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack {
                        Text("Szybko i pysznie").font(.system(size: 19, weight: .bold))
                        Spacer()
                        Button("Zobacz wszystko  →") { selectedTab = .search }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppTheme.green)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(quickRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeCard(recipe: recipe, compact: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct QuickFilter: View {
    let title: String
    var active = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(active ? .white : Color.primary)
                .padding(.horizontal, 13)
                .frame(height: 30)
                .background(active ? AppTheme.green : .white, in: Capsule())
                .overlay(Capsule().stroke(active ? AppTheme.green : AppTheme.border))
        }
        .buttonStyle(.plain)
    }
}

struct FeaturedRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RecipePhoto(recipe: recipe)
            LinearGradient(colors: [.clear, .black.opacity(0.78)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text("PRZEPIS DNIA")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.92), in: Capsule())
                Text(recipe.title).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                Text("\(recipe.preparationTime) min   •   \(recipe.difficulty)   •   \(recipe.diet)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
        .frame(height: 246)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RecipePhoto(recipe: recipe)
                .frame(height: compact ? 100 : 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(recipe.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            Text("\(recipe.preparationTime) min  •  \(recipe.difficulty)")
                .font(.system(size: 10))
                .foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RecipePhoto: View {
    let recipe: Recipe

    var body: some View {
        Group {
            if let data = recipeImageData(recipe), let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else if !recipe.imageName.isEmpty, UIImage(named: recipe.imageName) != nil {
                Image(recipe.imageName).resizable().scaledToFill()
            } else {
                ZStack {
                    AppTheme.mint
                    Image(systemName: symbolForCategory(recipe.category))
                        .font(.system(size: 42))
                        .foregroundStyle(AppTheme.green.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private func recipeImageData(_ recipe: Recipe) -> Data? { recipe.imageData }
    private func symbolForCategory(_ category: String) -> String {
        switch category {
        case "Makaron": return "takeoutbag.and.cup.and.straw"
        case "Ryby": return "fish"
        case "Sałatki": return "leaf"
        case "Śniadania": return "sun.max"
        case "Zupy": return "cup.and.saucer"
        case "Desery": return "birthday.cake"
        default: return "fork.knife"
        }
    }
}

struct SearchView: View {
    let recipes: [Recipe]
    @State private var query = ""
    @State private var maxTime = 120
    @State private var selectedDiet = "Dowolna"
    @State private var selectedDifficulty = "Dowolna"
    @State private var sortNewest = false
    @State private var showFilters = false

    private var results: [Recipe] {
        var items = recipes.filter { recipe in
            let textMatches = query.isEmpty ||
                recipe.title.localizedCaseInsensitiveContains(query) ||
                recipe.ingredients.contains(where: { $0.localizedCaseInsensitiveContains(query) })
            let dietMatches = selectedDiet == "Dowolna" || recipe.diet == selectedDiet
            let difficultyMatches = selectedDifficulty == "Dowolna" || recipe.difficulty == selectedDifficulty
            return textMatches && recipe.preparationTime <= maxTime && dietMatches && difficultyMatches
        }
        if sortNewest { items.reverse() }
        return items
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(results) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            HStack(spacing: 12) {
                                RecipePhoto(recipe: recipe).frame(width: 82, height: 72).clipShape(RoundedRectangle(cornerRadius: 12))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(recipe.title).font(.headline)
                                    Text("\(recipe.preparationTime) min • \(recipe.difficulty) • \(recipe.diet)")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Wyniki: \(results.count)")
                }
            }
            .listStyle(.plain)
            .navigationTitle("Szukaj")
            .searchable(text: $query, prompt: "Nazwa dania lub składnik")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showFilters = true } label: { Image(systemName: "line.3.horizontal.decrease") }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(maxTime: $maxTime, selectedDiet: $selectedDiet, selectedDifficulty: $selectedDifficulty, sortNewest: $sortNewest)
                    .presentationDetents([.medium, .large])
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView("Brak wyników", systemImage: "magnifyingglass", description: Text("Zmień zapytanie lub wyczyść filtry."))
                }
            }
        }
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var maxTime: Int
    @Binding var selectedDiet: String
    @Binding var selectedDifficulty: String
    @Binding var sortNewest: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Maksymalny czas") {
                    Picker("Czas przygotowania", selection: $maxTime) {
                        Text("Do 15 min").tag(15)
                        Text("Do 30 min").tag(30)
                        Text("Do 60 min").tag(60)
                        Text("Bez limitu").tag(120)
                    }
                }
                Section("Dieta") {
                    Picker("Preferencje", selection: $selectedDiet) {
                        ForEach(["Dowolna", "Wegetariańska", "Wegańska", "Mięsna", "Bezglutenowa"], id: \.self) { Text($0) }
                    }
                }
                Section("Trudność") {
                    Picker("Poziom", selection: $selectedDifficulty) {
                        ForEach(["Dowolna", "Łatwy", "Średni", "Trudny"], id: \.self) { Text($0) }
                    }
                }
                Toggle("Odwróć kolejność wyników", isOn: $sortNewest)
            }
            .navigationTitle("Filtry")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Wyczyść") {
                        maxTime = 120; selectedDiet = "Dowolna"; selectedDifficulty = "Dowolna"; sortNewest = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) { Button("Gotowe") { dismiss() } }
            }
        }
    }
}

struct FavoritesView: View {
    let recipes: [Recipe]
    private var favorites: [Recipe] { recipes.filter(\.isFavorite) }

    var body: some View {
        NavigationStack {
            List {
                ForEach(favorites) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        HStack(spacing: 12) {
                            RecipePhoto(recipe: recipe).frame(width: 76, height: 68).clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading) {
                                Text(recipe.title).font(.headline)
                                Text("\(recipe.preparationTime) min • \(recipe.difficulty)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ulubione")
            .overlay {
                if favorites.isEmpty {
                    ContentUnavailableView("Brak ulubionych", systemImage: "heart", description: Text("Dodaj przepis do ulubionych, aby pojawił się tutaj."))
                }
            }
        }
    }
}

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: Recipe
    @State private var selectedSection = "Składniki"
    @State private var checkedIngredients: Set<Int> = []
    @State private var showEditor = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RecipePhoto(recipe: recipe).frame(height: 245).clipShape(RoundedRectangle(cornerRadius: 22))
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(recipe.title).font(.system(size: 25, weight: .bold))
                        Text(recipe.recipeDescription).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    FavoriteButton(isFavorite: recipe.isFavorite) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                            recipe.isFavorite.toggle()
                        }
                    }
                }
                HStack(spacing: 18) {
                    Label("\(recipe.preparationTime) min", systemImage: "clock")
                    Label(recipe.difficulty, systemImage: "chart.bar")
                    Label("\(recipe.servings) porc.", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Picker("Sekcja", selection: $selectedSection) {
                    ForEach(["Składniki", "Przygotowanie", "Notatki", "Opinie"], id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case "Składniki":
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Składniki").font(.title3.bold())
                        ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                            Button {
                                if checkedIngredients.contains(index) { checkedIngredients.remove(index) }
                                else { checkedIngredients.insert(index) }
                            } label: {
                                HStack {
                                    Image(systemName: checkedIngredients.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(checkedIngredients.contains(index) ? AppTheme.green : .secondary)
                                    Text(ingredient).strikethrough(checkedIngredients.contains(index)).foregroundStyle(.primary)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                case "Przygotowanie":
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Przygotowanie").font(.title3.bold())
                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline).foregroundStyle(.white)
                                    .frame(width: 30, height: 30).background(AppTheme.green, in: Circle())
                                Text(step).frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        VideoPlayerSection(videoName: recipe.videoName)
                        AudioPlayerSection(audioName: recipe.audioName)
                    }
                case "Notatki":
                    VStack(alignment: .leading) {
                        Text("Wskazówki i notatki").font(.title3.bold())
                        TextEditor(text: $recipe.notes)
                            .frame(minHeight: 130)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.border))
                        Text("Notatki zapisują się lokalnie wraz z przepisem.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                default:
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Twoja ocena").font(.title3.bold())
                        HStack {
                            ForEach(1...5, id: \.self) { value in
                                Button {
                                    recipe.rating = value
                                } label: {
                                    Image(systemName: value <= recipe.rating ? "star.fill" : "star")
                                        .font(.title2).foregroundStyle(.yellow)
                                }.buttonStyle(.plain)
                            }
                        }
                        Text(recipe.rating == 0 ? "Nie oceniono" : "Twoja ocena: \(recipe.rating)/5")
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text("Ocena jest zapisywana lokalnie. Aplikacja nie korzysta z recenzji online.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Przepis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if recipe.isUserCreated {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Edytuj", systemImage: "pencil") { showEditor = true }
                        Button("Usuń", systemImage: "trash", role: .destructive) { showDeleteConfirmation = true }
                    } label: { Image(systemName: "ellipsis") }
                }
            }
        }
        .sheet(isPresented: $showEditor) { RecipeFormView(recipe: recipe) }
        .confirmationDialog("Usunąć ten przepis?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Usuń przepis", role: .destructive) {
                modelContext.delete(recipe)
            }
            Button("Anuluj", role: .cancel) { }
        } message: {
            Text("Tej operacji nie można cofnąć.")
        }
    }
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isFavorite ? .red : AppTheme.green)
                .scaleEffect(isFavorite ? 1.12 : 1)
                .padding(11)
                .background(AppTheme.mint, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
    }
}

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var recipe: Recipe? = nil

    @State private var title = ""
    @State private var description = ""
    @State private var category = "Dania główne"
    @State private var diet = "Dowolna"
    @State private var time = "30"
    @State private var servings = "2"
    @State private var difficulty = "Łatwy"
    @State private var ingredientsText = ""
    @State private var stepsText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var errorMessage = ""
    @State private var initialized = false

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(time) ?? 0) > 0 && (Int(servings) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Podstawowe informacje") {
                    TextField("Nazwa przepisu *", text: $title)
                    TextField("Krótki opis", text: $description, axis: .vertical)
                    Picker("Kategoria", selection: $category) {
                        ForEach(["Dania główne", "Makaron", "Śniadania", "Zupy", "Sałatki", "Desery", "Dodatki", "Ryby", "Inne"], id: \.self) { Text($0) }
                    }
                    Picker("Dieta", selection: $diet) {
                        ForEach(["Dowolna", "Wegetariańska", "Wegańska", "Mięsna", "Bezglutenowa"], id: \.self) { Text($0) }
                    }
                }
                Section("Parametry") {
                    TextField("Czas przygotowania (min)", text: $time).keyboardType(.numberPad)
                    TextField("Liczba porcji", text: $servings).keyboardType(.numberPad)
                    Picker("Trudność", selection: $difficulty) {
                        ForEach(["Łatwy", "Średni", "Trudny"], id: \.self) { Text($0) }
                    }
                }
                Section("Składniki") {
                    Text("Wpisz każdy składnik w osobnej linii.").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $ingredientsText).frame(minHeight: 110)
                }
                Section("Zdjęcie przepisu") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(selectedImageData == nil ? "Wybierz zdjęcie" : "Zmień zdjęcie", systemImage: "photo")
                    }
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                Section("Kroki przygotowania") {
                    Text("Wpisz każdy krok w osobnej linii.").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $stepsText).frame(minHeight: 130)
                }
                if !errorMessage.isEmpty {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }
            }
            .navigationTitle(recipe == nil ? "Nowy przepis" : "Edytuj przepis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Anuluj") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Zapisz") { saveRecipe() }.disabled(!isValid)
                }
            }
            .onAppear(perform: loadExistingRecipe)
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    selectedImageData = try? await newValue?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    private func loadExistingRecipe() {
        guard !initialized, let recipe else { initialized = true; return }
        title = recipe.title
        description = recipe.recipeDescription
        category = recipe.category
        diet = recipe.diet
        time = String(recipe.preparationTime)
        servings = String(recipe.servings)
        difficulty = recipe.difficulty
        ingredientsText = recipe.ingredients.joined(separator: "\n")
        stepsText = recipe.steps.joined(separator: "\n")
        initialized = true
    }

    private func saveRecipe() {
        guard isValid else {
            errorMessage = "Podaj nazwę przepisu oraz dodatni czas i liczbę porcji."
            return
        }
        let ingredients = ingredientsText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let steps = stepsText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        if let recipe {
            recipe.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            recipe.recipeDescription = description
            recipe.category = category
            recipe.diet = diet
            recipe.preparationTime = Int(time) ?? 30
            recipe.servings = Int(servings) ?? 2
            recipe.difficulty = difficulty
            recipe.ingredients = ingredients
            recipe.steps = steps
            if let selectedImageData { recipe.imageData = selectedImageData }
        } else {
            let newRecipe = Recipe(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                recipeDescription: description,
                category: category,
                diet: diet,
                preparationTime: Int(time) ?? 30,
                difficulty: difficulty,
                servings: Int(servings) ?? 2,
                ingredients: ingredients,
                steps: steps,
                imageData: selectedImageData,
                isUserCreated: true
            )
            modelContext.insert(newRecipe)
        }
        try? modelContext.save()
        dismiss()
    }
}

struct SettingsView: View {
    @AppStorage("preferredUnits") private var preferredUnits = "Metryczne"
    @AppStorage("defaultServings") private var defaultServings = 2

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferencje") {
                    Picker("Jednostki", selection: $preferredUnits) {
                        Text("Metryczne").tag("Metryczne")
                        Text("Imperialne").tag("Imperialne")
                    }
                    Stepper("Domyślna liczba porcji: \(defaultServings)", value: $defaultServings, in: 1...12)
                }
                Section("O aplikacji") {
                    LabeledContent("Nazwa", value: "CookBook")
                    LabeledContent("Wersja", value: "1.0")
                    LabeledContent("Zapis danych", value: "Lokalnie na urządzeniu")
                }
            }
            .navigationTitle("Ustawienia")
        }
    }
}
