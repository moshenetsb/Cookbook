import SwiftUI

struct HomeView: View {
    @Environment(RecipeStore.self) private var store
    let onSearch: (RecipeFilter) -> Void
    let onSettings: () -> Void

    private var featured: Recipe? {
        store.recipes.first { $0.imageName == "recipe_orzo" } ?? store.recipes.first
    }

    private var quickRecipes: [Recipe] {
        Array(store.recipes.filter { $0.id != featured?.id && $0.preparationTime <= 30 }.prefix(2))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    brandHeader
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Co dziś ugotujemy?").font(.title.bold()).foregroundStyle(AppTheme.ink)
                        Text("Sprawdzone przepisy na każdy dzień").font(.subheadline).foregroundStyle(AppTheme.muted)
                    }

                    if let featured {
                        NavigationLink { RecipeDetailView(recipeID: featured.id) } label: {
                            FeaturedRecipeCard(recipe: featured)
                        }
                        .buttonStyle(.plain)
                    } else {
                        ContentUnavailableView("Twoja książka jest pusta", systemImage: "book.closed", description: Text("Dodaj pierwszy przepis w zakładce Dodaj."))
                    }
                    if !quickRecipes.isEmpty {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Szybko i pysznie").font(.title3.bold())
                            Spacer()
                            Button("Zobacz wszystko →") { onSearch(RecipeFilter(time: .thirty)) }
                                .font(.caption.weight(.semibold)).frame(minHeight: 44)
                        }
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(quickRecipes) { recipe in
                                NavigationLink { RecipeDetailView(recipeID: recipe.id) } label: { RecipeCard(recipe: recipe) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.pageInset)
                .padding(.vertical, 14)
            }
            .background(AppTheme.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            Image("cookbook_logo").resizable().scaledToFit().frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 3) {
                Text("CookBook").font(.title.bold()).foregroundStyle(AppTheme.green)
                Text("DOBRE JEDZENIE, PROSTE POMYSŁY")
                    .font(.system(.caption2, design: .default, weight: .semibold))
                    .foregroundStyle(AppTheme.muted)
            }
            Spacer(minLength: 0)
            Button(action: onSettings) {
                Text("M").font(.headline).frame(width: 46, height: 46)
                    .background(AppTheme.mint, in: Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppTheme.green)
            .accessibilityLabel("Otwórz ustawienia")
        }
    }
}

private struct FeaturedRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        RecipePhoto(recipe: recipe)
            .frame(height: 246)
            .overlay {
                LinearGradient(colors: [.clear, Color(red: 0.12, green: 0.16, blue: 0.11).opacity(0.95)], startPoint: .center, endPoint: .bottom)
            }
            .overlay(alignment: .topLeading) {
                Text("PRZEPIS DNIA").font(.caption2.bold()).foregroundStyle(AppTheme.green)
                    .padding(8).background(.white.opacity(0.95), in: Capsule()).padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.title).font(.title2.bold())
                    Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue) · \(recipe.diet.rawValue)")
                        .font(.caption)
                }
                .foregroundStyle(.white).padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
