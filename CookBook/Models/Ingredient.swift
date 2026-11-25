import Foundation
import SwiftData

@Model
final class Ingredient {
    var id: UUID
    var name: String
    var amount: Double?
    var unit: String
    var order: Int
    var recipe: Recipe?

    init(id: UUID = UUID(), name: String, amount: Double? = nil, unit: String = "", order: Int = 0) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.order = order
    }

    init(_ name: String, _ amount: Double? = nil, _ unit: String = "") {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.unit = unit
        self.order = 0
    }

    var editableQuantity: String {
        guard let amount else { return unit }
        let number = String(amount).replacingOccurrences(of: ".", with: ",")
        return [number, unit].filter { !$0.isEmpty }.joined(separator: " ")
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
