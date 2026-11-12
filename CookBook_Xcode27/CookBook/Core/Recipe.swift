import Foundation

enum RecipeCategory: String, CaseIterable, Identifiable, Sendable {
    case main = "Dania główne"
    case pasta = "Makaron"
    case breakfast = "Śniadania"
    case soup = "Zupy"
    case salad = "Sałatki"
    case dessert = "Desery"
    case side = "Dodatki"
    case fish = "Ryby"
    case other = "Inne"

    var id: String { rawValue }
}

enum Diet: String, CaseIterable, Identifiable, Sendable {
    case any = "Dowolna"
    case vegetarian = "Wegetariańska"
    case vegan = "Wegańska"
    case glutenFree = "Bezglutenowa"

    var id: String { rawValue }

    func includes(_ recipeDiet: Diet) -> Bool {
        self == .any || self == recipeDiet || (self == .vegetarian && recipeDiet == .vegan)
    }
}

enum Difficulty: String, CaseIterable, Identifiable, Sendable {
    case easy = "Łatwy"
    case medium = "Średni"
    case hard = "Trudny"

    var id: String { rawValue }
}

struct Ingredient: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var amount: Double?
    var unit: String

    init(_ name: String, _ amount: Double? = nil, _ unit: String = "") {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.unit = unit
    }

    func quantity(for servings: Int, baseServings: Int) -> String {
        guard let amount else { return unit }
        let scaled = amount * Double(max(servings, 1)) / Double(max(baseServings, 1))
        let number = scaled.formatted(
            .number.locale(Locale(identifier: "pl_PL"))
                .grouping(.never).precision(.fractionLength(0...2))
        )
        return [number, unit].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

struct PreparationStep: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var instruction: String

    init(_ title: String, _ instruction: String) {
        self.id = UUID()
        self.title = title
        self.instruction = instruction
    }
}

enum MediaKind: String, Identifiable, Sendable {
    case video
    case audio

    var id: String { rawValue }
    var title: String { self == .video ? "Film instruktażowy" : "Instrukcja audio" }
    var symbol: String { self == .video ? "play.rectangle" : "waveform" }
}

struct MediaAttachment: Identifiable, Equatable, Sendable {
    let id: UUID
    let kind: MediaKind
    let fileName: String
    let url: URL
}

// Zwykła wartość Swift: model nie zależy od SwiftData ani od widoków.
struct Recipe: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var summary: String
    var category: RecipeCategory
    var diet: Diet
    var preparationTime: Int
    var difficulty: Difficulty
    var servings: Int
    var ingredients: [Ingredient]
    var steps: [PreparationStep]
    var imageName: String
    var imageData: Data?
    var isFavorite: Bool
    var isUserCreated: Bool
    var createdAt: Date
    var video: MediaAttachment?
    var audio: MediaAttachment?

    init(
        id: UUID = UUID(), title: String, summary: String = "",
        category: RecipeCategory = .main, diet: Diet = .any,
        preparationTime: Int = 30, difficulty: Difficulty = .easy,
        servings: Int = 2, ingredients: [Ingredient] = [],
        steps: [PreparationStep] = [], imageName: String = "",
        imageData: Data? = nil, isFavorite: Bool = false,
        isUserCreated: Bool = false, createdAt: Date = .now,
        video: MediaAttachment? = nil, audio: MediaAttachment? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.diet = diet
        self.preparationTime = preparationTime
        self.difficulty = difficulty
        self.servings = servings
        self.ingredients = ingredients
        self.steps = steps
        self.imageName = imageName
        self.imageData = imageData
        self.isFavorite = isFavorite
        self.isUserCreated = isUserCreated
        self.createdAt = createdAt
        self.video = video
        self.audio = audio
    }
}
