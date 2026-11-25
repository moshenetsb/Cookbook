import Foundation
import SwiftData

@Model
final class PreparationStep {
    var id: UUID
    var title: String
    var instruction: String
    var order: Int
    var recipe: Recipe?

    init(id: UUID = UUID(), title: String, instruction: String, order: Int = 0) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.order = order
    }

    init(_ title: String, _ instruction: String) {
        self.id = UUID()
        self.title = title
        self.instruction = instruction
        self.order = 0
    }
}
