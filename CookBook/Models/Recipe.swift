import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var summary: String
    var category: RecipeCategory
    var diet: Diet
    var preparationTime: Int
    var difficulty: Difficulty
    var servings: Int
    var imageName: String
    @Attribute(.externalStorage) var imageData: Data?
    var isFavorite: Bool
    var createdAt: Date
    var videoPath: String?
    var videoFileName: String?
    var audioPath: String?
    var audioFileName: String?

    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient]

    @Relationship(deleteRule: .cascade, inverse: \PreparationStep.recipe)
    var steps: [PreparationStep]

    var video: MediaAttachment? {
        get {
            guard let videoPath, let videoFileName else { return nil }
            return MediaAttachment(kind: .video, fileName: videoFileName, url: URL(fileURLWithPath: videoPath))
        }
        set {
            videoPath = newValue?.url.path
            videoFileName = newValue?.fileName
        }
    }

    var audio: MediaAttachment? {
        get {
            guard let audioPath, let audioFileName else { return nil }
            return MediaAttachment(kind: .audio, fileName: audioFileName, url: URL(fileURLWithPath: audioPath))
        }
        set {
            audioPath = newValue?.url.path
            audioFileName = newValue?.fileName
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        summary: String = "",
        category: RecipeCategory = .main,
        diet: Diet = .any,
        preparationTime: Int = 30,
        difficulty: Difficulty = .easy,
        servings: Int = 2,
        ingredients: [Ingredient] = [],
        steps: [PreparationStep] = [],
        imageName: String = "",
        imageData: Data? = nil,
        isFavorite: Bool = false,
        createdAt: Date = .now,
        video: MediaAttachment? = nil,
        audio: MediaAttachment? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.diet = diet
        self.preparationTime = preparationTime
        self.difficulty = difficulty
        self.servings = servings
        ingredients.enumerated().forEach { index, ingredient in
            ingredient.order = index
        }
        self.ingredients = ingredients
        steps.enumerated().forEach { index, step in
            step.order = index
        }
        self.steps = steps
        self.imageName = imageName
        self.imageData = imageData
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.videoPath = video?.url.path
        self.videoFileName = video?.fileName
        self.audioPath = audio?.url.path
        self.audioFileName = audio?.fileName
    }
}
