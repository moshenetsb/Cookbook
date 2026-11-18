import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Query private var recipes: [Recipe]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AppStorage("defaultServings") private var defaultServings = 1
    let recipeID: UUID
    @State private var checkedIngredients: Set<UUID> = []
    @State private var selectedMedia: MediaKind?
    @State private var showsCooking = false
    @State private var favoriteError: String?

    private var displayServings: Int {
        min(max(defaultServings, 1), 12)
    }

    var body: some View {
        Group {
            if let recipe = recipes.first(where: { $0.id == recipeID }) {
                details(recipe)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.55)) {
                                    recipe.isFavorite.toggle()
                                }
                                saveFavorite()
                            } label: {
                                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                    .font(.headline)
                                    .foregroundStyle(recipe.isFavorite ? .white : AppTheme.ink)
                                    .symbolEffect(.bounce, value: recipe.isFavorite)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 44, height: 44)
                            .background(recipe.isFavorite ? .pink : AppTheme.surface, in: Circle())
                            .overlay(Circle().stroke(recipe.isFavorite ? .pink : AppTheme.border, lineWidth: 1))
                            .contentShape(Circle())
                            .accessibilityLabel(recipe.isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
                            .accessibilityValue(recipe.title)
                        }
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
        .alert("Nie udało się zapisać zmian", isPresented: Binding(
            get: { favoriteError != nil },
            set: { if !$0 { favoriteError = nil } }
        )) {
            Button("OK", role: .cancel) { favoriteError = nil }
        } message: {
            Text(favoriteError ?? "Spróbuj ponownie.")
        }
    }

    private func saveFavorite() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            favoriteError = error.localizedDescription
        }
    }

    private func details(_ recipe: Recipe) -> some View {
        List {
            Section {
                RecipePhoto(recipe: recipe)
                    .frame(height: 228)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .listRowInsets(EdgeInsets())
                VStack(alignment: .leading, spacing: 4) {
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
                    metadata("\(displayServings)", caption: "PORCJE", symbol: "person.2")
                }
                .padding(.vertical, 4)
                Stepper("Porcje: \(displayServings)", value: Binding(
                    get: { displayServings },
                    set: { defaultServings = min(max($0, 1), 12) }
                ), in: 1...12)
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
                ForEach(recipe.ingredients.sorted { $0.order < $1.order }) { ingredient in
                    IngredientCheckRow(
                        ingredient: ingredient, servings: displayServings,
                        baseServings: recipe.servings, checked: $checkedIngredients
                    )
                }
            } header: {
                HStack { Text("Składniki"); Spacer(); Text("\(recipe.ingredients.count) składników") }
            }
            Section {
                Button("Rozpocznij gotowanie") { showsCooking = true }
                .buttonStyle(PrimaryButtonStyle())
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }
        }
        .navigationDestination(isPresented: $showsCooking) {
            CookingView(recipeID: recipe.id, servings: displayServings)
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
    }

    private func metadata(_ title: String, caption: String, symbol: String) -> some View {
        VStack(spacing: 8) {
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
