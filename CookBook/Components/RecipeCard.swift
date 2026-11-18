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
    @Bindable var recipe: Recipe
    @State private var errorMessage: String?
    
    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.55)) {
                recipe.isFavorite.toggle()
            }
            saveChanges()
        } label: {
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundStyle(recipe.isFavorite ? .white : AppTheme.ink)
                .frame(width: 32, height: 30)
                .background(recipe.isFavorite ? .pink : AppTheme.surface, in: RoundedRectangle(cornerRadius: 9))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(recipe.isFavorite ? .pink : AppTheme.border, lineWidth: 1)
                )
                .scaleEffect(recipe.isFavorite ? 1.07 : 1)
                .symbolEffect(.bounce, value: recipe.isFavorite)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(recipe.isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
        .accessibilityValue(recipe.title)
        .alert("Nie udało się zapisać zmian", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Spróbuj ponownie.")
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}

struct RecipeRow: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("defaultServings") private var defaultServings = 1
    
    @Bindable var recipe: Recipe
    let onDeleteRequested: (Recipe) -> Void
    
    @State private var isEditing = false
    @State private var errorMessage: String?
    
    var body: some View {
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
                    
                    Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue) · \(defaultServings) por.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            
            Button(role: .destructive) {
                onDeleteRequested(recipe)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            
            Button {
                isEditing = true
            } label: {
                Image(systemName: "pencil")
            }
            .tint(AppTheme.green)
            
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.55)) {
                    recipe.isFavorite.toggle()
                }
                saveChanges()
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
        
        .alert("Nie udało się zapisać zmian", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Spróbuj ponownie.")
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = error.localizedDescription
        }
    }
}


struct RecipeCard: View {
    @AppStorage("defaultServings") private var defaultServings = 1
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            RecipePhoto(recipe: recipe)
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(recipe.title).font(.caption.weight(.semibold)).foregroundStyle(AppTheme.ink)
            Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue) · \(defaultServings) por.")
                .font(.caption2).foregroundStyle(AppTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
