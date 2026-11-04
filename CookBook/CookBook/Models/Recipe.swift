import SwiftData
import Foundation

enum DifficultyLevel: String, Codable, CaseIterable, Identifiable {
    case easy = "Łatwy"
    case medium = "Średni"
    case hard = "Trudny"
    
    var id: String { self.rawValue }
}

enum DietType: String, Codable, CaseIterable, Identifiable {
    case standard = "Klasyczna"
    case vegetarian = "Wegetariańska"
    case vegan = "Wegańska"
    case glutenFree = "Bezglutenowa"
    
    var id: String { self.rawValue }
}

@Model
final class Recipe {
    var id: UUID
    var title: String
    var prepTimeMinutes: Int
    var difficultyLevel: DifficultyLevel
    var servings: Int
    var category: String     
    var diets: [DietType]        
    var imageData: Data?
    var isFavorite: Bool    
    var isRecipeOfTheDay: Bool
    var videoPath: String?
    var audioPath: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient] = []

    @Relationship(deleteRule: .cascade)
    var steps: [CookingStep] = []

    init(
        id: UUID = UUID(),
        title: String,
        prepTimeMinutes: Int,
        difficultyLevel: DifficultyLevel  = .easy,
        servings: Int,
        category: String,
        diets: [DietType] = [.standard],
        imageData: Data? = nil,
        isFavorite: Bool = false,
        isRecipeOfTheDay: Bool = false,
        videoPath: String? = nil,
        audioPath: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.prepTimeMinutes = prepTimeMinutes
        self.difficultyLevel = difficultyLevel
        self.servings = servings
        self.category = category
        self.diets = diets
        self.imageData = imageData
        self.isFavorite = isFavorite
        self.isRecipeOfTheDay = isRecipeOfTheDay
        self.videoPath = videoPath
        self.audioPath = audioPath
        self.createdAt = createdAt
    }
}