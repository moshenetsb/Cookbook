import SwiftData
import Foundation

@Model
final class Ingredient {
    var id: UUID
    var name: String
    var amount: String
    var createdAt: Date
    
    @Relationship(inverse: \Recipe.steps)
    var recipe: Recipe?

    init(id: UUID = UUID(), name: String, amount: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.createdAt = createdAt
    }
}