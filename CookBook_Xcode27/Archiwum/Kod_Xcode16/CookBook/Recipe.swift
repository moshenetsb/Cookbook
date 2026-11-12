import Foundation
import SwiftData

@Model
final class Recipe {
    @Attribute(.unique) var id: UUID
    var title: String
    var recipeDescription: String
    var category: String
    var diet: String
    var preparationTime: Int
    var difficulty: String
    var servings: Int
    var ingredientsJSON: String
    var stepsJSON: String
    var imageName: String
    var imageData: Data?
    var isFavorite: Bool
    var isUserCreated: Bool
    var notes: String
    var rating: Int
    var videoName: String
    var audioName: String

    init(
        id: UUID = UUID(),
        title: String,
        recipeDescription: String = "",
        category: String = "Inne",
        diet: String = "Dowolna",
        preparationTime: Int = 30,
        difficulty: String = "Łatwy",
        servings: Int = 2,
        ingredients: [String] = [],
        steps: [String] = [],
        imageName: String = "",
        imageData: Data? = nil,
        isFavorite: Bool = false,
        isUserCreated: Bool = false,
        notes: String = "",
        rating: Int = 0,
        videoName: String = "",
        audioName: String = ""
    ) {
        self.id = id
        self.title = title
        self.recipeDescription = recipeDescription
        self.category = category
        self.diet = diet
        self.preparationTime = preparationTime
        self.difficulty = difficulty
        self.servings = servings
        self.ingredientsJSON = (try? String(data: JSONEncoder().encode(ingredients), encoding: .utf8)) ?? "[]"
        self.stepsJSON = (try? String(data: JSONEncoder().encode(steps), encoding: .utf8)) ?? "[]"
        self.imageName = imageName
        self.imageData = imageData
        self.isFavorite = isFavorite
        self.isUserCreated = isUserCreated
        self.notes = notes
        self.rating = rating
        self.videoName = videoName
        self.audioName = audioName
    }

    var ingredients: [String] {
        get { (try? JSONDecoder().decode([String].self, from: Data(ingredientsJSON.utf8))) ?? [] }
        set { ingredientsJSON = (try? String(data: JSONEncoder().encode(newValue), encoding: .utf8)) ?? "[]" }
    }

    var steps: [String] {
        get { (try? JSONDecoder().decode([String].self, from: Data(stepsJSON.utf8))) ?? [] }
        set { stepsJSON = (try? String(data: JSONEncoder().encode(newValue), encoding: .utf8)) ?? "[]" }
    }
}
