import SwiftUI
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
    @Environment(RecipeStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let recipe: Recipe
    
    var body: some View {
        Button {
            store.toggleFavorite(id: recipe.id)
        } label: {
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundStyle(recipe.isFavorite ? .white : AppTheme.green)
                .frame(width: 32, height: 30)
                .background(recipe.isFavorite ? AppTheme.green : AppTheme.mint, in: RoundedRectangle(cornerRadius: 9))
                .scaleEffect(recipe.isFavorite ? 1.07 : 1)
                .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.5), value: recipe.isFavorite)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(recipe.isFavorite ? "Usuń z ulubionych" : "Dodaj do ulubionych")
        .accessibilityValue(recipe.title)
    }
}
//
//struct RecipeRow: View {
//    @Environment(RecipeStore.self) private var store
//    let recipe: Recipe
//    @State private var isEditing = false
//    @State private var confirmsDelete = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//            NavigationLink {
//                RecipeDetailView(recipeID: recipe.id)
//            } label: {
//                HStack(spacing: 14) {
//                    RecipePhoto(recipe: recipe)
//                        .frame(width: 104, height: 104)
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text(recipe.category.rawValue.uppercased())
//                            .font(.caption2.weight(.bold)).foregroundStyle(AppTheme.green)
//                        Text(recipe.title).font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.ink)
//                        Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue)")
//                            .font(.caption).foregroundStyle(AppTheme.muted)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                }
//            }
//            .buttonStyle(.plain)
//            HStack(spacing: 4) {
//                Spacer()
//                Button("Usuń", role: .destructive) { confirmsDelete = true }
//                    .font(.caption).frame(minWidth: 48, minHeight: 44)
//                Button("Edytuj") { isEditing = true }
//                    .font(.caption).frame(minWidth: 52, minHeight: 44)
//                FavoriteButton(recipe: recipe)
//            }
//            .buttonStyle(.borderless)
//        }
//        .padding(.vertical, 8)
//        .sheet(isPresented: $isEditing) { RecipeFormView(recipe: recipe) }
//        .confirmationDialog("Usunąć „\(recipe.title)” ?", isPresented: $confirmsDelete, titleVisibility: .visible) {
//            Button("Usuń przepis", role: .destructive) { store.delete(id: recipe.id) }
//            Button("Anuluj", role: .cancel) { }
//        } message: {
//            Text("Przepis zniknie również z ulubionych.")
//        }
//    }
//}


struct RecipeRow: View {
    @Environment(RecipeStore.self) private var store
    
    let recipe: Recipe
    
    @State private var isEditing = false
    @State private var confirmsDelete = false
    
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
                    
                    Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue)")
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
                confirmsDelete = true
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
                store.toggleFavorite(id: recipe.id)
            } label: {
                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
            }
            .tint(.pink)
        }
        
        .sheet(isPresented: $isEditing) {
            RecipeFormView(recipe: recipe)
        }
        
        .confirmationDialog(
            "Usunąć „\(recipe.title)”?",
            isPresented: $confirmsDelete,
            titleVisibility: .visible
        ) {
            Button("Usuń przepis", role: .destructive) {
                store.delete(id: recipe.id)
            }
            
            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Przepis zniknie również z ulubionych.")
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
