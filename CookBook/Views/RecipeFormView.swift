import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("defaultServings") private var defaultServings = 1
    let recipe: Recipe?
    var onSaved: ((Recipe) -> Void)?

    @State private var draft: RecipeDraft
    @State private var initialDraft: RecipeDraft
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var importKind: MediaKind = .video
    @State private var showsFileImporter = false
    @State private var isImporting = false
    @State private var isLoadingPhoto = false
    @State private var errorMessage: String?
    @State private var validation: RecipeValidation?
    @State private var confirmsDiscard = false
    @State private var hasAppeared = false

    init(recipe: Recipe? = nil, onSaved: ((Recipe) -> Void)? = nil) {
        self.recipe = recipe
        self.onSaved = onSaved
        let draft = RecipeDraft(recipe: recipe)
        _draft = State(initialValue: draft)
        _initialDraft = State(initialValue: draft)
    }

    private var isDirty: Bool { draft != initialDraft }
    private var isBusy: Bool { isImporting || isLoadingPhoto }
    private var hasPhoto: Bool { draft.imageData != nil || !draft.imageName.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                Section("Nazwa przepisu") {
                    TextField("Np. Makaron z pieczarkami", text: $draft.title)
                        .accessibilityIdentifier("recipeTitle")
                    if let validation { validationMessage(validation.title?.message) }
                    TextField("Krótki opis (opcjonalnie)", text: $draft.summary, axis: .vertical)
                        .lineLimit(2...4)
                }
                informationSection
                ingredientsSection
                stepsSection
                mediaSection

                Section {
                    Button(recipe == nil ? "Zapisz przepis" : "Zapisz zmiany", action: save)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isBusy)
                        .accessibilityIdentifier("saveRecipe")
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(recipe == nil ? "Dodaj przepis" : "Edytuj przepis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(recipe == nil ? "Wyczyść" : "Anuluj") {
                        if isDirty { confirmsDiscard = true } else { cancel() }
                    }
                    .disabled(isBusy)
                }
            }
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                if recipe == nil { reset() }
            }
            .interactiveDismissDisabled(isDirty || isBusy)
            .onChange(of: defaultServings) { _, _ in
                if recipe == nil && !isDirty { reset() }
            }
            .onChange(of: draft) { _, _ in
                if validation != nil { validation = draft.validate() }
            }
            .task(id: selectedPhoto) { await loadPhoto() }
            .fileImporter(
                isPresented: $showsFileImporter,
                allowedContentTypes: importKind == .video ? [.movie] : [.audio],
                allowsMultipleSelection: false,
                onCompletion: importMedia
            )
            .alert("Nie udało się wykonać operacji", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: { Text(errorMessage ?? "Spróbuj ponownie.") }
            .confirmationDialog("Odrzucić niezapisane zmiany?", isPresented: $confirmsDiscard, titleVisibility: .visible) {
                Button("Odrzuć zmiany", role: .destructive, action: cancel)
                Button("Wróć do edycji", role: .cancel) { }
            }
        }
    }

    private var photoSection: some View {
        Section {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                HStack(spacing: 12) {
                    RecipePhoto(imageName: draft.imageName, imageData: draft.imageData)
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    VStack(alignment: .leading, spacing: 6) {
                        if hasPhoto {
                            Label("Zmień zdjęcie potrawy", systemImage: "photo").font(.subheadline.bold())
                            Text("Dotknij, aby wybrać inne zdjęcie").font(.caption).foregroundStyle(.secondary)
                        } else {
                            Label("Dodaj zdjęcie potrawy", systemImage: "plus").font(.subheadline.bold())
                            Text("Zdjęcie pojawi się na karcie przepisu").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .disabled(isBusy)
            .listRowBackground(hasPhoto ? AppTheme.surface : AppTheme.mint)
            if isLoadingPhoto { ProgressView("Wczytywanie zdjęcia…") }
            if draft.imageData != nil || !draft.imageName.isEmpty {
                Button("Usuń zdjęcie", role: .destructive) {
                    selectedPhoto = nil
                    draft.imageData = nil
                    draft.imageName = ""
                }
                .disabled(isBusy)
            }
        } footer: { Text("Zapisz swój pomysł w książce kucharskiej.") }
    }

    private var informationSection: some View {
        Section("Podstawowe informacje") {
            VStack(alignment: .leading, spacing: 4) {
                LabeledContent("Czas (min)") {
                    TextField("30", text: $draft.time).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        .accessibilityLabel("Czas przygotowania w minutach")
                }
                if let validation { validationMessage(validation.preparationTimeIssue?.message) }
            }
            VStack(alignment: .leading, spacing: 4) {
                LabeledContent("Liczba porcji") {
                    TextField(String(recipe?.servings ?? defaultServings), text: $draft.servings)
                        .keyboardType(.numberPad).multilineTextAlignment(.trailing)
                        .accessibilityLabel("Liczba porcji")
                }
                if let validation { validationMessage(validation.servingCountIssue?.message) }
            }
            Picker("Kategoria", selection: $draft.category) {
                ForEach(RecipeCategory.allCases) { Text($0.rawValue).tag($0) }
            }
            Picker("Poziom trudności", selection: $draft.difficulty) {
                ForEach(Difficulty.allCases) { Text($0.rawValue).tag($0) }
            }
            Picker("Dieta", selection: $draft.diet) {
                ForEach(Diet.allCases) { Text($0.rawValue).tag($0) }
            }
        }
    }

    private var ingredientsSection: some View {
        Section {
            ForEach($draft.ingredients) { $ingredient in
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Nazwa składnika", text: $ingredient.name)
                        if let validation {
                            validationMessage(validation.ingredientFields[ingredient.id]?.name?.message)
                        }
                        TextField("Ilość, np. 250 g, 1/2 szt. lub do smaku", text: $ingredient.quantity)
                            .font(.subheadline)
                        if let validation {
                            validationMessage(validation.ingredientFields[ingredient.id]?.quantity?.message)
                        }
                    }
                    Button("Usuń składnik", systemImage: "minus.circle", role: .destructive) {
                        draft.ingredients.removeAll { $0.id == ingredient.id }
                    }
                    .labelStyle(.iconOnly).buttonStyle(.borderless).frame(minWidth: 44, minHeight: 44)
                }
            }
            Button("Dodaj składnik", systemImage: "plus.circle") { draft.ingredients.append(IngredientDraft()) }
        } header: {
            Text("Składniki")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Ilości są zapisywane dla liczby porcji ustawionej w przepisie. W widokach przepisu będą przeliczane względem porcji z ustawień.")
                if let validation { validationMessage(validation.ingredientsIssue?.message) }
            }
        }
    }

    private var stepsSection: some View {
        Section {
            ForEach($draft.steps) { $step in
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Tytuł kroku (opcjonalnie)", text: $step.title).font(.subheadline.bold())
                        TextField("Opisz kolejny krok", text: $step.instruction, axis: .vertical).lineLimit(1...6)
                        if let validation {
                            validationMessage(validation.stepFields[step.id]?.message)
                        }
                    }
                    Button("Usuń krok", systemImage: "minus.circle", role: .destructive) {
                        draft.steps.removeAll { $0.id == step.id }
                    }
                    .labelStyle(.iconOnly).buttonStyle(.borderless).frame(minWidth: 44, minHeight: 44)
                }
            }
            Button("Dodaj krok", systemImage: "plus.circle") { draft.steps.append(StepDraft()) }
        } header: {
            Text("Przygotowanie")
        } footer: {
            if let validation { validationMessage(validation.stepsIssue?.message) }
        }
    }

    private var mediaSection: some View {
        Section("Multimedia (opcjonalne)") {
            HStack {
                Button("Dodaj film", systemImage: "play.rectangle") { chooseMedia(.video) }
                    .frame(maxWidth: .infinity, minHeight: 44)
                Button("Dodaj audio", systemImage: "waveform") { chooseMedia(.audio) }
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderless).font(.subheadline).disabled(isBusy)
            if isImporting { ProgressView("Wczytywanie pliku…") }
            if let video = draft.video { attachmentRow(video) { draft.video = nil } }
            if let audio = draft.audio { attachmentRow(audio) { draft.audio = nil } }
            if draft.video == nil && draft.audio == nil {
                Text("Nie dodano żadnych plików.").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func attachmentRow(_ attachment: MediaAttachment, remove: @escaping () -> Void) -> some View {
        HStack {
            Label(attachment.fileName, systemImage: attachment.kind.symbol).font(.caption).lineLimit(2)
            Spacer()
            Button("Usuń załącznik", systemImage: "xmark.circle", role: .destructive, action: remove)
                .labelStyle(.iconOnly).buttonStyle(.borderless).frame(minWidth: 44, minHeight: 44)
        }
    }

    private func chooseMedia(_ kind: MediaKind) {
        importKind = kind
        showsFileImporter = true
    }

    private func importMedia(_ result: Result<[URL], Error>) {
        let kind = importKind
        Task { @MainActor in
            isImporting = true
            defer { isImporting = false }
            do {
                guard let url = try result.get().first else { return }
                let attachment = try await Task.detached(priority: .userInitiated) {
                    try MediaImporter.copyToSession(url, kind: kind)
                }.value
                if kind == .video { draft.video = attachment } else { draft.audio = attachment }
            } catch {
                if (error as NSError).code != NSUserCancelledError { errorMessage = error.localizedDescription }
            }
        }
    }

    private func loadPhoto() async {
        guard let selectedPhoto else { return }
        isLoadingPhoto = true
        defer { isLoadingPhoto = false }
        do {
            guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else { throw MediaImportError.invalidPhoto }
            guard !Task.isCancelled else { return }
            draft.imageData = try MediaImporter.preparePhoto(data)
        } catch {
            if !Task.isCancelled { errorMessage = error.localizedDescription }
        }
    }

    @ViewBuilder
    private func validationMessage(_ message: String?) -> some View {
        if let message {
            Label(message, systemImage: "exclamationmark.circle")
                .font(.caption)
                .foregroundStyle(.red)
                .accessibilityLabel(message)
        }
    }

    private func save() {
        let savedRecipe: Recipe
        switch draft.makeRecipe() {
        case .success(let recipe):
            savedRecipe = recipe
            validation = nil
        case .failure(let errors):
            validation = errors
            return
        }

        if let recipe {
            modelContext.delete(recipe)
        }
        modelContext.insert(savedRecipe)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            errorMessage = "Nie udało się zapisać przepisu. \(error.localizedDescription)"
            return
        }
        if recipe == nil { reset() } else { dismiss() }
        onSaved?(savedRecipe)
    }

    private func reset() {
        draft = RecipeDraft(defaultServings: min(max(defaultServings, 1), 12))
        initialDraft = draft
        selectedPhoto = nil
        validation = nil
    }

    private func cancel() {
        if recipe == nil { reset() } else { dismiss() }
    }
}
