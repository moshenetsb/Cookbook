import SwiftUI

struct CookingView: View {
    @Environment(RecipeStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let recipeID: UUID
    let servings: Int
    @State private var checkedIngredients: Set<UUID> = []
    @State private var completedSteps: Set<UUID> = []
    @State private var showsCompletion = false

    var body: some View {
        Group {
            if let recipe = store.recipe(id: recipeID) {
                List {
                    Section {
                        HStack(spacing: 12) {
                            RecipePhoto(recipe: recipe).frame(width: 68, height: 68)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 5) {
                                Text("KROK PO KROKU").font(.caption2.bold()).foregroundStyle(AppTheme.green)
                                Text(recipe.title).font(.headline)
                                Text("\(recipe.preparationTime) min · \(recipe.difficulty.rawValue) · \(servings) porc.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    Section("Składniki") {
                        ForEach(recipe.ingredients) { ingredient in
                            IngredientCheckRow(ingredient: ingredient, servings: servings, baseServings: recipe.servings, checked: $checkedIngredients)
                        }
                    }
                    Section {
                        ProgressView(value: Double(completedSteps.count), total: Double(max(recipe.steps.count, 1))) {
                            Text("Ukończone kroki: \(completedSteps.count) z \(recipe.steps.count)").font(.caption)
                        }
                        ForEach(Array(recipe.steps.enumerated()), id: \.element.id) { index, step in
                            stepRow(step, number: index + 1)
                        }
                    } header: { Text("Przygotowanie") }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(AppTheme.background)
                .safeAreaInset(edge: .bottom) {
                    Button("Zakończ gotowanie") { showsCompletion = true }
                        .buttonStyle(PrimaryButtonStyle()).padding().background(AppTheme.background)
                }
            } else {
                ContentUnavailableView("Przepis został usunięty", systemImage: "book.closed")
            }
        }
        .navigationTitle("Gotowanie")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Smacznego!", isPresented: $showsCompletion) {
            Button("Wróć do przepisu") { dismiss() }
        } message: { Text("Gotowanie zakończone. Możesz wrócić do tego przepisu w dowolnej chwili.") }
    }

    private func stepRow(_ step: PreparationStep, number: Int) -> some View {
        let isCompleted = completedSteps.contains(step.id)
        return Button {
            if isCompleted { completedSteps.remove(step.id) } else { completedSteps.insert(step.id) }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Group {
                    if isCompleted { Image(systemName: "checkmark") } else { Text("\(number)") }
                }
                .font(.caption.bold()).foregroundStyle(AppTheme.green)
                .frame(width: 28, height: 28).background(AppTheme.mint, in: Circle())
                VStack(alignment: .leading, spacing: 5) {
                    Text(step.title).font(.subheadline.bold())
                    Text(step.instruction).font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 6).foregroundStyle(AppTheme.ink)
        }
        .buttonStyle(.plain)
        .accessibilityValue(isCompleted ? "Ukończony" : "Do wykonania")
    }
}
