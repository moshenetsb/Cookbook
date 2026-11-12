import Foundation

enum PreparationTime: Int, CaseIterable, Identifiable, Sendable {
    case any = 0
    case fifteen = 15
    case thirty = 30
    case sixty = 60

    var id: Int { rawValue }
    var title: String { self == .any ? "Dowolny" : "Do \(rawValue) minut" }
}

enum RecipeSort: String, CaseIterable, Identifiable, Sendable {
    case relevance = "Najlepiej dopasowane"
    case fastest = "Najszybsze"
    case newest = "Najnowsze"
    case alphabetical = "Od A do Z"

    var id: String { rawValue }
}

struct RecipeFilter: Equatable, Sendable {
    var time: PreparationTime = .any
    var difficulty: Difficulty?
    var diet: Diet = .any
    var category: RecipeCategory?
    var sort: RecipeSort = .relevance

    var activeCount: Int {
        [time != .any, difficulty != nil, diet != .any, category != nil]
            .filter { $0 }.count
    }

    func apply(to recipes: [Recipe], query: String = "") -> [Recipe] {
        let words = query.searchKey.split(whereSeparator: \.isWhitespace).map(String.init)
        let matches = recipes.filter { recipe in
            let searchable = ([recipe.title] + recipe.ingredients.map(\.name))
                .joined(separator: " ").searchKey
            return words.allSatisfy { searchable.contains($0) }
                && (time == .any || recipe.preparationTime <= time.rawValue)
                && (difficulty == nil || recipe.difficulty == difficulty)
                && diet.includes(recipe.diet)
                && (category == nil || recipe.category == category)
        }

        // Offset rozstrzyga remisy, więc kolejność nie skacze przy odświeżaniu widoku.
        return matches.enumerated().sorted { left, right in
            let lhs = left.element
            let rhs = right.element
            switch sort {
            case .relevance:
                let leftScore = words.filter { lhs.title.searchKey.contains($0) }.count
                let rightScore = words.filter { rhs.title.searchKey.contains($0) }.count
                if leftScore != rightScore { return leftScore > rightScore }
            case .fastest:
                if lhs.preparationTime != rhs.preparationTime {
                    return lhs.preparationTime < rhs.preparationTime
                }
            case .newest:
                if lhs.createdAt != rhs.createdAt { return lhs.createdAt > rhs.createdAt }
            case .alphabetical:
                let order = lhs.title.compare(rhs.title, options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pl_PL"))
                if order != .orderedSame { return order == .orderedAscending }
            }
            return left.offset < right.offset
        }.map(\.element)
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    var searchKey: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "pl_PL"))
            .replacingOccurrences(of: "ł", with: "l")
    }
}
