import Foundation

struct IngredientDraft: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var quantity: String

    init(name: String = "", quantity: String = "") {
        id = UUID()
        self.name = name
        self.quantity = quantity
    }

    var isEmpty: Bool { name.trimmed.isEmpty && quantity.trimmed.isEmpty }

    func makeIngredient() -> Ingredient? {
        guard !name.trimmed.isEmpty, let parsed = Self.parseQuantity(quantity) else { return nil }
        return Ingredient(name.trimmed, parsed.amount, parsed.unit)
    }

    // Obsługuje np. „250 g”, „1,5 łyżki”, „1/2 szt.” oraz „do smaku”.
    static func parseQuantity(_ text: String) -> (amount: Double?, unit: String)? {
        let text = text.trimmed
        guard !text.isEmpty else { return nil }
        guard let first = text.first else { return nil }
        if first.isLetter { return (nil, text) }
        let pattern = #"^(\d+(?:[.,]\d+)?(?:/\d+(?:[.,]\d+)?)?)\s*([^\d].*)?$"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let numberRange = Range(match.range(at: 1), in: text) else { return nil }
        let numbers = text[numberRange].replacingOccurrences(of: ",", with: ".").split(separator: "/")
        guard let firstNumber = numbers.first, let numerator = Double(firstNumber) else { return nil }
        let denominator = numbers.count == 2 ? (Double(numbers[1]) ?? 0) : 1
        guard denominator > 0 else { return nil }
        let amount = numerator / denominator
        guard amount.isFinite, amount > 0 else { return nil }
        let unitRange = Range(match.range(at: 2), in: text)
        let unit = unitRange.map { String(text[$0]).trimmed } ?? ""
        if unit.first?.isNumber == true { return nil }
        return (amount, unit)
    }
}

struct StepDraft: Identifiable, Equatable, Sendable {
    let id = UUID()
    var title = ""
    var instruction = ""

    var isEmpty: Bool { title.trimmed.isEmpty && instruction.trimmed.isEmpty }
}

struct RecipeDraft: Equatable, Sendable {
    var original: Recipe?
    var title = ""
    var summary = ""
    var time = "30"
    var servings = "2"
    var category: RecipeCategory = .main
    var difficulty: Difficulty = .easy
    var diet: Diet = .any
    var ingredients = [IngredientDraft()]
    var steps = [StepDraft()]
    var imageName = ""
    var imageData: Data?
    var video: MediaAttachment?
    var audio: MediaAttachment?

    init(recipe: Recipe? = nil, defaultServings: Int = 2) {
        original = recipe
        servings = String(defaultServings)
        guard let recipe else { return }
        title = recipe.title
        summary = recipe.summary
        time = String(recipe.preparationTime)
        servings = String(recipe.servings)
        category = recipe.category
        difficulty = recipe.difficulty
        diet = recipe.diet
        ingredients = recipe.ingredients.map {
            IngredientDraft(name: $0.name, quantity: $0.quantity(for: recipe.servings, baseServings: recipe.servings))
        }
        steps = recipe.steps.map { StepDraft(title: $0.title, instruction: $0.instruction) }
        imageName = recipe.imageName
        imageData = recipe.imageData
        video = recipe.video
        audio = recipe.audio
    }

    var validationMessages: [String] {
        var messages: [String] = []
        if title.trimmed.isEmpty { messages.append("Podaj nazwę przepisu.") }
        if !(1...1440).contains(Int(time.trimmed) ?? 0) {
            messages.append("Czas musi być liczbą od 1 do 1440 minut.")
        }
        if !(1...100).contains(Int(servings.trimmed) ?? 0) {
            messages.append("Liczba porcji musi wynosić od 1 do 100.")
        }
        let enteredIngredients = ingredients.filter { !$0.isEmpty }
        if enteredIngredients.isEmpty {
            messages.append("Dodaj przynajmniej jeden składnik i jego ilość.")
        } else if enteredIngredients.contains(where: { $0.makeIngredient() == nil }) {
            messages.append("Uzupełnij nazwę i poprawną ilość każdego składnika, np. 250 g lub do smaku.")
        }
        let enteredSteps = steps.filter { !$0.isEmpty }
        if enteredSteps.isEmpty || enteredSteps.contains(where: { $0.instruction.trimmed.isEmpty }) {
            messages.append("Dodaj opis każdego kroku przygotowania.")
        }
        return messages
    }

    func makeRecipe() -> Recipe? {
        guard validationMessages.isEmpty,
              let minutes = Int(time.trimmed), let portions = Int(servings.trimmed) else { return nil }
        let preparation = steps.filter { !$0.isEmpty }.enumerated().map { index, step in
            PreparationStep(step.title.trimmed.isEmpty ? "Krok \(index + 1)" : step.title.trimmed, step.instruction.trimmed)
        }
        return Recipe(
            id: original?.id ?? UUID(), title: title.trimmed, summary: summary.trimmed,
            category: category, diet: diet, preparationTime: minutes, difficulty: difficulty,
            servings: portions, ingredients: ingredients.compactMap { $0.makeIngredient() },
            steps: preparation, imageName: imageName, imageData: imageData,
            isFavorite: original?.isFavorite ?? false,
            isUserCreated: original?.isUserCreated ?? true,
            createdAt: original?.createdAt ?? .now, video: video, audio: audio
        )
    }
}
