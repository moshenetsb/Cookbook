import SwiftUI
import SwiftData
import UIKit

struct RecipePhoto: View {
    var imageName = ""
    var imageData: Data?

    init(recipe: Recipe) {
        imageName = recipe.imageName
        imageData = recipe.imageData
    }

    init(imageName: String = "", imageData: Data? = nil) {
        self.imageName = imageName
        self.imageData = imageData
    }

    private var uiImage: UIImage? {
        if let imageData, let image = UIImage(data: imageData) { return image }
        return imageName.isEmpty ? nil : UIImage(named: imageName)
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let uiImage {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    ZStack {
                        AppTheme.mint
                        Image(systemName: "fork.knife")
                            .font(.title)
                            .foregroundStyle(AppTheme.green)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .accessibilityHidden(true)
    }
}

struct FavoriteButton: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let recipe: Recipe
    @State private var errorMessage: String?
    @State private var animationTrigger = 0

    var body: some View {
        Button {
            do {
                try RecipePersistence.toggleFavorite(recipe, in: modelContext)
                animationTrigger += 1
            } catch {
                errorMessage = error.localizedDescription
            }
        } label: {
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .symbolEffectsRemoved(reduceMotion)
                .font(.headline)
                .foregroundStyle(recipe.isFavorite ? .white : AppTheme.green)
                .frame(width: 32, height: 30)
                .background(recipe.isFavorite ? AppTheme.green : AppTheme.mint, in: RoundedRectangle(cornerRadius: 9))
                .symbolEffect(.bounce, value: animationTrigger)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(recipe.isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
        .accessibilityValue(recipe.isFavorite ? "Ulubiony" : "Nieulubiony")
        .accessibilityHint(recipe.title)
        .accessibilityIdentifier("favorite-\(recipe.id.uuidString)")
        .alert("Nie udało się zapisać zmian", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Spróbuj ponownie.")
        }
    }

}

struct RecipeRow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let recipe: Recipe

    @State private var isEditing = false
    @State private var confirmsDelete = false
    @State private var errorMessage: String?

    var body: some View {
        HStack(spacing: 6) {
            NavigationLink {
                RecipeDetailView(recipeID: recipe.id)
            } label: {
                HStack(spacing: 14) {
                    RecipePhoto(recipe: recipe)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.category.rawValue.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.green)

                        Text(recipe.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)

                        Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("recipe-\(recipe.id.uuidString)")
        }

        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(role: .destructive) {
                confirmsDelete = true
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            .accessibilityLabel("Usuń przepis")
            
            Button {
                isEditing = true
            } label: {
                Image(systemName: "pencil")
            }
            .tint(AppTheme.green)
            .accessibilityLabel("Edytuj przepis")
            
            Button {
                 do {
                    try withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        try RecipePersistence.toggleFavorite(recipe, in: modelContext)
                    }
                } catch { errorMessage = error.localizedDescription }
            } label: {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(recipe.isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
            .tint(recipe.isFavorite ? .pink : .gray)
        }

        .sheet(isPresented: $isEditing) {
            RecipeFormView(recipe: recipe)
        }

        .confirmationDialog(
            "Usunąć \"\(recipe.title)\"?",
            isPresented: $confirmsDelete,
            titleVisibility: .visible
        ) {
            Button("Usuń przepis", role: .destructive) {
                do {
                    try RecipePersistence.delete(recipe, in: modelContext)
                } catch { errorMessage = error.localizedDescription }
            }

            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Przepis zniknie również z ulubionych.")
        }
        .alert("Nie udało się zapisać zmian", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Spróbuj ponownie.")
        }
    }

}


struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            RecipePhoto(recipe: recipe)
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(recipe.title).font(.caption.weight(.semibold)).foregroundStyle(AppTheme.ink)
            Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue)")
                .font(.caption2).foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
