import Foundation

enum ServingPreferences {
    static let defaultRange = 1...12
    static let recipeRange = 1...100

    static func normalizedDefault(_ value: Int) -> Int {
        min(max(value, defaultRange.lowerBound), defaultRange.upperBound)
    }
}
