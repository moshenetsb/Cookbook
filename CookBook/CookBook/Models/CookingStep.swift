import SwiftData
import Foundation

@Model
final class CookingStep {
    var id: UUID
    var stepNumber: Int
    var name: String
    var stepDescription: String
    var createdAt: Date
    
    @Relationship(inverse: \Recipe.steps)
    var recipe: Recipe?

    init(id: UUID = UUID(), stepNumber: Int, name: String, stepDescription: String, createdAt: Date = Date()) {
        self.id = id
        self.stepNumber = stepNumber
        self.name = name
        self.stepDescription = stepDescription
        self.createdAt = createdAt
    }
}