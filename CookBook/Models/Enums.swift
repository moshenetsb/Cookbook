import Foundation

enum MediaKind: String, Identifiable, Sendable {
    case video
    case audio

    var id: String { rawValue }
    var title: String { self == .video ? "Film instruktażowy" : "Instrukcja audio" }
    var symbol: String { self == .video ? "play.rectangle" : "waveform" }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable, Sendable {
    case easy = "Łatwy"
    case medium = "Średni"
    case hard = "Trudny"
    
    var id: String { self.rawValue }
}

enum Diet: String, Codable, CaseIterable, Identifiable, Sendable {
    case any = "Dowolna"
    case vegetarian = "Wegetariańska"
    case vegan = "Wegańska"
    case glutenFree = "Bezglutenowa"
    
    var id: String { self.rawValue }

    func includes(_ recipeDiet: Diet) -> Bool {
        self == .any || self == recipeDiet || (self == .vegetarian && recipeDiet == .vegan)
    }
}

enum RecipeCategory: String, Codable, CaseIterable, Identifiable, Sendable {
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
