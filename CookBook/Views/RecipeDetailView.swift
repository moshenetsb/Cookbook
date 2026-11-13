import SwiftUI

struct RecipeDetailView: View {
    @Environment(RecipeStore.self) private var store
    let recipeID: UUID
    @State private var servings = 0
    @State private var checkedIngredients: Set<UUID> = []
    @State private var selectedMedia: MediaKind?

    var body: some View {
        Group {
            if let recipe = store.recipe(id: recipeID) {
                details(recipe)
                    .onAppear { if servings == 0 { servings = recipe.servings } }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) { FavoriteButton(recipe: recipe) }
                    }
                    .sheet(item: $selectedMedia) { kind in
                        MediaPlayerView(kind: kind, attachment: kind == .video ? recipe.video : recipe.audio)
                    }
            } else {
                ContentUnavailableView("Przepis został usunięty", systemImage: "book.closed")
            }
        }
        .navigationTitle("Przepis")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }

    private func details(_ recipe: Recipe) -> some View {
        List {
            Section {
                RecipePhoto(recipe: recipe)
                    .frame(height: 228)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .listRowInsets(EdgeInsets())
                VStack(alignment: .leading, spacing: 8) {
                    Text([recipe.category.rawValue, recipe.diet.rawValue].joined(separator: " · ").uppercased())
                        .font(.caption2.bold()).foregroundStyle(AppTheme.green)
                    Text(recipe.title).font(.title2.bold())
                    if !recipe.summary.isEmpty { Text(recipe.summary).font(.subheadline).foregroundStyle(.secondary) }
                }
                .padding(.vertical, 6)
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 6, trailing: 0))
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                HStack {
                    metadata("\(recipe.preparationTime) min", caption: "CZAS", symbol: "clock")
                    Divider()
                    metadata(recipe.difficulty.rawValue, caption: "POZIOM", symbol: "diamond")
                    Divider()
                    metadata("\(servings == 0 ? recipe.servings : servings) os.", caption: "PORCJE", symbol: "person.2")
                }
                .padding(.vertical, 4)
                Stepper("Porcje: \(servings == 0 ? recipe.servings : servings)", value: Binding(
                    get: { servings == 0 ? recipe.servings : servings },
                    set: { servings = $0 }
                ), in: 1...100)
                    .font(.subheadline)
                    .accessibilityIdentifier("servingsStepper")
            }
            Section {
                HStack(spacing: 10) {
                    Button { selectedMedia = .video } label: {
                        Label("Obejrzyj film", systemImage: "play").font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .foregroundStyle(.white).background(AppTheme.green, in: RoundedRectangle(cornerRadius: 12))
                    }
                    Button { selectedMedia = .audio } label: {
                        Label("Instrukcja audio", systemImage: "waveform").font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .foregroundStyle(AppTheme.green).background(AppTheme.mint, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets())
            }
            .listRowBackground(Color.clear)
            Section {
                ForEach(recipe.ingredients) { ingredient in
                    IngredientCheckRow(
                        ingredient: ingredient, servings: servings == 0 ? recipe.servings : servings,
                        baseServings: recipe.servings, checked: $checkedIngredients
                    )
                }
            } header: {
                HStack { Text("Składniki"); Spacer(); Text("\(recipe.ingredients.count) składników") }
            }
            Section {
                NavigationLink {
                    CookingView(recipeID: recipe.id, servings: servings == 0 ? recipe.servings : servings)
                } label: {
                    Text("Rozpocznij gotowanie").frame(maxWidth: .infinity, minHeight: 46)
                        .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                }
                .listRowBackground(AppTheme.green)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
    }

    private func metadata(_ title: String, caption: String, symbol: String) -> some View {
        VStack(spacing: 5) {
            Label(title, systemImage: symbol).font(.caption.weight(.medium))
            Text(caption).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IngredientCheckRow: View {
    let ingredient: Ingredient
    let servings: Int
    let baseServings: Int
    @Binding var checked: Set<UUID>

    private var isChecked: Bool { checked.contains(ingredient.id) }

    var body: some View {
        Button {
            if isChecked { checked.remove(ingredient.id) } else { checked.insert(ingredient.id) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle").foregroundStyle(AppTheme.green)
                Text(ingredient.name).strikethrough(isChecked).foregroundStyle(AppTheme.ink)
                Spacer(minLength: 4)
                Text(ingredient.quantity(for: servings, baseServings: baseServings)).foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .frame(minHeight: 32)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(ingredient.name), \(ingredient.quantity(for: servings, baseServings: baseServings))")
        .accessibilityValue(isChecked ? "Zaznaczony" : "Niezaznaczony")
    }
}
