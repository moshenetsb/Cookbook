import Foundation

struct IngredientDraft: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var quantity: String

    init(id: UUID = UUID(), name: String = "", quantity: String = "") {
        self.id = id
        self.name = name
        self.quantity = quantity
    }

    var isEmpty: Bool { name.trimmed.isEmpty && quantity.trimmed.isEmpty }

    @MainActor
    func makeIngredient() -> Ingredient? {
        guard !name.trimmed.isEmpty, let parsed = Self.parseQuantity(quantity) else { return nil }
        return Ingredient(id: id, name: name.trimmed, amount: parsed.amount, unit: parsed.unit)
    }

    // Obsługuje np. „250 g”, „1,5 łyżki”, „1/2 szt.” oraz „do smaku”.
    static func parseQuantity(_ text: String) -> (amount: Double?, unit: String)? {
        let text = text.trimmed
        guard !text.isEmpty else { return nil }
        guard let first = text.first else { return nil }
        if first.isLetter { return (nil, text) }
        let pattern = #"^(\d+(?:[.,]\d+)?(?:[eE][+-]?\d+)?(?:/\d+(?:[.,]\d+)?(?:[eE][+-]?\d+)?)?)\s*([^\d].*)?$"#
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
        // Odrzuć m.in. „1/2/3”, „1..5”, „1-2 g” i „1 1/2 szklanki”.
        if let first = unit.first, !first.isLetter { return nil }
        return (amount, unit)
    }
}

struct StepDraft: Identifiable, Equatable, Sendable {
    var id = UUID()
    var title = ""
    var instruction = ""

    var isEmpty: Bool { title.trimmed.isEmpty && instruction.trimmed.isEmpty }
}

enum RecipeValidationIssue: Equatable, Sendable {
    case titleRequired
    case invalidPreparationTime
    case invalidServings
    case ingredientsRequired
    case ingredientNameRequired
    case invalidIngredientQuantity
    case stepsRequired
    case stepInstructionRequired

    var message: String {
        switch self {
        case .titleRequired:
            return "Podaj nazwę przepisu"
        case .invalidPreparationTime:
            return "Czas musi być liczbą od 1 do 1440 minut"
        case .invalidServings:
            return "Liczba porcji musi wynosić od 1 do 100"
        case .ingredientsRequired:
            return "Dodaj przynajmniej jeden składnik."
        case .ingredientNameRequired:
            return "Podaj nazwę składnika."
        case .invalidIngredientQuantity:
            return "Podaj poprawną ilość, np. 250 g lub do smaku"
        case .stepsRequired:
            return "Dodaj przynajmniej jeden krok przygotowania"
        case .stepInstructionRequired:
            return "Opisz ten krok przygotowania"
        }
    }
}

struct IngredientFieldValidation: Equatable, Sendable {
    var name: RecipeValidationIssue? = nil
    var quantity: RecipeValidationIssue? = nil

    var isValid: Bool { name == nil && quantity == nil }
}

struct RecipeValidation: Error, Equatable, Sendable {
    var title: RecipeValidationIssue? = nil
    var preparationTime: Int? = nil
    var preparationTimeIssue: RecipeValidationIssue? = nil
    var servingCount: Int? = nil
    var servingCountIssue: RecipeValidationIssue? = nil
    var ingredientsIssue: RecipeValidationIssue? = nil
    var ingredientFields: [UUID: IngredientFieldValidation] = [:]
    var stepsIssue: RecipeValidationIssue? = nil
    var stepFields: [UUID: RecipeValidationIssue] = [:]

    var isValid: Bool {
        title == nil
            && preparationTime != nil
            && preparationTimeIssue == nil
            && servingCount != nil
            && servingCountIssue == nil
            && ingredientsIssue == nil
            && ingredientFields.values.allSatisfy(\.isValid)
            && stepsIssue == nil
            && stepFields.isEmpty
    }
}

struct RecipeDraft: Equatable {
    var original: Recipe?
    var title = ""
    var summary = ""
    var time = "30"
    var servings = "1"
    var category: RecipeCategory = .main
    var difficulty: Difficulty = .easy
    var diet: Diet = .any
    var ingredients = [IngredientDraft()]
    var steps = [StepDraft()]
    var imageName = ""
    var imageData: Data?
    var video: MediaAttachment?
    var audio: MediaAttachment?

    static func == (lhs: RecipeDraft, rhs: RecipeDraft) -> Bool {
        lhs.original?.id == rhs.original?.id
            && lhs.title == rhs.title
            && lhs.summary == rhs.summary
            && lhs.time == rhs.time
            && lhs.servings == rhs.servings
            && lhs.category == rhs.category
            && lhs.difficulty == rhs.difficulty
            && lhs.diet == rhs.diet
            && lhs.ingredients == rhs.ingredients
            && lhs.steps == rhs.steps
            && lhs.imageName == rhs.imageName
            && lhs.imageData == rhs.imageData
            && lhs.video == rhs.video
            && lhs.audio == rhs.audio
    }

    init(recipe: Recipe? = nil, defaultServings: Int = 1) {
        original = recipe
        servings = String(ServingPreferences.normalizedDefault(defaultServings))
        guard let recipe else { return }
        title = recipe.title
        summary = recipe.summary
        time = String(recipe.preparationTime)
        servings = String(recipe.servings)
        category = recipe.category
        difficulty = recipe.difficulty
        diet = recipe.diet
        ingredients = recipe.ingredients.sorted { $0.order < $1.order }.map {
            // Format widoku zaokrągla do 2 miejsc; edytor musi zachować pełną ilość.
            IngredientDraft(id: $0.id, name: $0.name, quantity: $0.editableQuantity)
        }
        steps = recipe.steps.sorted { $0.order < $1.order }.map { StepDraft(id: $0.id, title: $0.title, instruction: $0.instruction) }
        imageName = recipe.imageName
        imageData = recipe.imageData
        video = recipe.video
        audio = recipe.audio
    }

    func validate() -> RecipeValidation {
        var validation = RecipeValidation()
        if title.trimmed.isEmpty {
            validation.title = .titleRequired
        }

        if let minutes = Int(time.trimmed), (1...1440).contains(minutes) {
            validation.preparationTime = minutes
        } else {
            validation.preparationTimeIssue = .invalidPreparationTime
        }

        if let portions = Int(servings.trimmed), (1...100).contains(portions) {
            validation.servingCount = portions
        } else {
            validation.servingCountIssue = .invalidServings
        }

        let enteredIngredients = ingredients.filter { !$0.isEmpty }
        if enteredIngredients.isEmpty {
            validation.ingredientsIssue = .ingredientsRequired
        } else {
            for ingredient in enteredIngredients {
                var fields = IngredientFieldValidation()
                if ingredient.name.trimmed.isEmpty {
                    fields.name = .ingredientNameRequired
                }
                if IngredientDraft.parseQuantity(ingredient.quantity) == nil {
                    fields.quantity = .invalidIngredientQuantity
                }
                if !fields.isValid {
                    validation.ingredientFields[ingredient.id] = fields
                }
            }
        }

        let enteredSteps = steps.filter { !$0.isEmpty }
        if enteredSteps.isEmpty {
            validation.stepsIssue = .stepsRequired
        } else {
            for step in enteredSteps where step.instruction.trimmed.isEmpty {
                validation.stepFields[step.id] = .stepInstructionRequired
            }
        }

        return validation
    }

    func makeRecipe() -> Result<Recipe, RecipeValidation> {
        let validation = validate()
        guard validation.isValid,
              let minutes = validation.preparationTime,
              let portions = validation.servingCount else {
            return .failure(validation)
        }

        let preparation = steps.filter { !$0.isEmpty }.enumerated().map { index, step in
            PreparationStep(id: step.id, title: step.title.trimmed.isEmpty ? "Krok \(index + 1)" : step.title.trimmed, instruction: step.instruction.trimmed)
        }
        let recipe = Recipe(
            id: original?.id ?? UUID(),
            title: title.trimmed,
            summary: summary.trimmed,
            category: category,
            diet: diet,
            preparationTime: minutes,
            difficulty: difficulty,
            servings: portions,
            ingredients: ingredients.compactMap { $0.makeIngredient() },
            steps: preparation,
            imageName: imageName,
            imageData: imageData,
            isFavorite: original?.isFavorite ?? false,
            createdAt: original?.createdAt ?? .now,
            video: video,
            audio: audio
        )
        return .success(recipe)
    }
}
