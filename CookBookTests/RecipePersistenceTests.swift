import Foundation
import SwiftData
import XCTest
@testable import CookBook

final class RecipePersistenceTests: XCTestCase {
    @MainActor
    private func container(url: URL? = nil, allowsSave: Bool = true) throws -> ModelContainer {
        let schema = Schema([Recipe.self, Ingredient.self, PreparationStep.self])
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration(schema: schema, url: url, allowsSave: allowsSave)
        } else {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    @MainActor
    func testBundledWrapVideoIsAddedToExistingDatabaseOnlyOnce() throws {
        let suite = "CookBook.MediaTest.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = try container()
        let wrap = try XCTUnwrap(SampleRecipes.make().first { $0.imageName == "recipe_chicken_wrap" })
        store.mainContext.insert(wrap)
        try store.mainContext.save()
        defaults.set(true, forKey: RecipeSeeder.completionKey)
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(wrap.videoPath, "bundle:wrap_chicken.mp4")
        let video = try XCTUnwrap(wrap.video)
        XCTAssertTrue(FileManager.default.fileExists(atPath: video.url.path))
        XCTAssertEqual(wrap.audioPath, "bundle:wrap_chicken.wav")
        wrap.video = nil
        try store.mainContext.save()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertNil(wrap.video)
    }

    @MainActor
    func testBundledWrapVideoDoesNotReplaceCustomVideo() throws {
        let suite = "CookBook.MediaTest.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = try container()
        let wrap = try XCTUnwrap(SampleRecipes.make().first { $0.imageName == "recipe_chicken_wrap" })
        let customURL = FileManager.default.temporaryDirectory.appendingPathComponent("custom.mp4")
        wrap.video = MediaAttachment(kind: .video, fileName: "Własny film.mp4", url: customURL)
        let customAudioURL = customURL.deletingLastPathComponent().appendingPathComponent("custom.wav")
        wrap.audio = MediaAttachment(kind: .audio, fileName: "Własne audio.wav", url: customAudioURL)
        store.mainContext.insert(wrap)
        try store.mainContext.save()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(wrap.video?.url, customURL)
        XCTAssertEqual(wrap.audio?.url, customAudioURL)
        XCTAssertTrue(defaults.bool(forKey: RecipeSeeder.wrapVideoKey))
    }

    @MainActor
    func testWrapAudioIsAddedAfterEarlierVideoMigrationOnlyOnce() throws {
        let suite = "CookBook.AudioTest.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = try container()
        let wrap = try XCTUnwrap(SampleRecipes.make().first { $0.imageName == "recipe_chicken_wrap" })
        store.mainContext.insert(wrap)
        try store.mainContext.save()
        defaults.set(true, forKey: RecipeSeeder.completionKey)
        defaults.set(true, forKey: RecipeSeeder.wrapVideoKey)
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(wrap.audioPath, "bundle:wrap_chicken.wav")
        let audio = try XCTUnwrap(wrap.audio)
        XCTAssertTrue(FileManager.default.fileExists(atPath: audio.url.path))
        XCTAssertTrue(defaults.bool(forKey: RecipeSeeder.wrapAudioKey))
        wrap.audio = nil
        try store.mainContext.save()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertNil(wrap.audio)
    }

    @MainActor
    func testFavoriteTogglesArePersistedAndReversible() throws {
        let store = try container()
        let context = store.mainContext
        let recipe = Recipe(title: "Próba")
        context.insert(recipe)
        try context.save()
        for _ in 0..<10 { try RecipePersistence.toggleFavorite(recipe, in: context) }
        XCTAssertFalse(recipe.isFavorite)
        try RecipePersistence.toggleFavorite(recipe, in: context)
        let freshContext = ModelContext(store)
        XCTAssertTrue(try XCTUnwrap(freshContext.fetch(FetchDescriptor<Recipe>()).first).isFavorite)
    }

    @MainActor
    func testEditPreservesObjectIdentityFavoriteAndCreationDate() throws {
        let store = try container()
        let recipe = SampleRecipes.make()[0]
        store.mainContext.insert(recipe)
        try store.mainContext.save()
        let persistentID = recipe.persistentModelID
        let date = recipe.createdAt
        let ingredientID = recipe.ingredients.sorted { $0.order < $1.order }[0].persistentModelID
        var draft = RecipeDraft(recipe: recipe)
        draft.title = "Zmieniony tytuł"
        let saved = try RecipePersistence.save(draft, in: store.mainContext)
        XCTAssertTrue(saved === recipe)
        XCTAssertEqual(saved.persistentModelID, persistentID)
        XCTAssertTrue(saved.isFavorite)
        XCTAssertEqual(saved.createdAt, date)
        XCTAssertEqual(saved.ingredients.sorted { $0.order < $1.order }[0].persistentModelID, ingredientID)
        XCTAssertEqual(try store.mainContext.fetchCount(FetchDescriptor<Recipe>()), 1)
    }

    @MainActor
    func testReplacingChildrenDoesNotLeaveOrphans() throws {
        let store = try container()
        let recipe = SampleRecipes.make()[0]
        store.mainContext.insert(recipe)
        try store.mainContext.save()
        var draft = RecipeDraft(recipe: recipe)
        draft.ingredients = [IngredientDraft(name: "Ryż", quantity: "250 g")]
        draft.steps = [StepDraft(instruction: "Ugotuj ryż")]
        _ = try RecipePersistence.save(draft, in: store.mainContext)
        let fresh = ModelContext(store)
        XCTAssertEqual(try fresh.fetchCount(FetchDescriptor<Ingredient>()), 1)
        XCTAssertEqual(try fresh.fetchCount(FetchDescriptor<PreparationStep>()), 1)
        let saved = try XCTUnwrap(fresh.fetch(FetchDescriptor<Recipe>()).first)
        XCTAssertEqual(saved.ingredients.first?.name, "Ryż")
        XCTAssertEqual(saved.ingredients.first?.recipe?.id, saved.id)
        XCTAssertEqual(saved.steps.first?.title, "Krok 1")
    }

    @MainActor
    func testDeleteCascadesToIngredientsAndSteps() throws {
        let store = try container()
        let recipe = SampleRecipes.make()[0]
        store.mainContext.insert(recipe)
        try store.mainContext.save()
        try RecipePersistence.delete(recipe, in: store.mainContext)
        let fresh = ModelContext(store)
        XCTAssertEqual(try fresh.fetchCount(FetchDescriptor<Recipe>()), 0)
        XCTAssertEqual(try fresh.fetchCount(FetchDescriptor<Ingredient>()), 0)
        XCTAssertEqual(try fresh.fetchCount(FetchDescriptor<PreparationStep>()), 0)
    }

    @MainActor
    func testInvalidEditLeavesStoredRecipeUnchanged() throws {
        let store = try container()
        let recipe = SampleRecipes.make()[0]
        store.mainContext.insert(recipe)
        try store.mainContext.save()
        let title = recipe.title
        var draft = RecipeDraft(recipe: recipe)
        draft.title = ""
        XCTAssertThrowsError(try RecipePersistence.save(draft, in: store.mainContext))
        XCTAssertEqual(recipe.title, title)
        XCTAssertFalse(store.mainContext.hasChanges)
    }

    @MainActor
    func testSeedRunsOnceEvenAfterDeletingEveryRecipe() throws {
        let suite = "CookBook.SeedTest.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = try container()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(try store.mainContext.fetchCount(FetchDescriptor<Recipe>()), 15)
        for recipe in try store.mainContext.fetch(FetchDescriptor<Recipe>()) {
            store.mainContext.delete(recipe)
        }
        try store.mainContext.save()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(try store.mainContext.fetchCount(FetchDescriptor<Recipe>()), 0)
    }

    @MainActor
    func testExistingDatabaseIsNotSeededAgain() throws {
        let suite = "CookBook.SeedTest.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = try container()
        store.mainContext.insert(Recipe(title: "Mój przepis"))
        try store.mainContext.save()
        try RecipeSeeder.seedIfNeeded(in: store.mainContext, defaults: defaults)
        XCTAssertEqual(try store.mainContext.fetchCount(FetchDescriptor<Recipe>()), 1)
        XCTAssertTrue(defaults.bool(forKey: RecipeSeeder.completionKey))
    }

    @MainActor
    func testDiskStoreSurvivesReopeningWithOrderAndFavorite() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("test.store")
        var expectedID: UUID?
        do {
            let store = try container(url: url)
            let recipe = SampleRecipes.make()[0]
            expectedID = recipe.id
            store.mainContext.insert(recipe)
            try store.mainContext.save()
            try RecipePersistence.toggleFavorite(recipe, in: store.mainContext)
        }
        let reopened = try container(url: url)
        let recipe = try XCTUnwrap(reopened.mainContext.fetch(FetchDescriptor<Recipe>()).first)
        XCTAssertEqual(recipe.id, expectedID)
        XCTAssertFalse(recipe.isFavorite)
        XCTAssertEqual(recipe.servings, 2)
        XCTAssertEqual(recipe.ingredients.sorted { $0.order < $1.order }.first?.name, "Orzo")
        XCTAssertEqual(recipe.steps.sorted { $0.order < $1.order }.first?.title, "Ugotuj orzo")
    }

    @MainActor
    func testFailedFavoriteSaveRollsBackTheDisplayedState() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("readonly.store")
        do {
            let store = try container(url: url)
            store.mainContext.insert(Recipe(title: "Tylko do odczytu"))
            try store.mainContext.save()
        }
        let store = try container(url: url, allowsSave: false)
        store.mainContext.autosaveEnabled = false
        let recipe = try XCTUnwrap(store.mainContext.fetch(FetchDescriptor<Recipe>()).first)
        XCTAssertThrowsError(try RecipePersistence.toggleFavorite(recipe, in: store.mainContext))
        XCTAssertFalse(recipe.isFavorite)
        XCTAssertFalse(store.mainContext.hasChanges)
    }

    @MainActor
    func testAttachmentIdentityAndRelativePathAreStable() throws {
        let url = try MediaImporter.libraryDirectory().appendingPathComponent("test.mp4")
        let recipe = Recipe(title: "Przepis", video: MediaAttachment(kind: .video, fileName: "Film.mp4", url: url))
        XCTAssertEqual(recipe.videoPath, "test.mp4")
        XCTAssertEqual(recipe.video?.url, url)
        XCTAssertEqual(recipe.video, recipe.video)
        XCTAssertNil(MediaImporter.resolve("../other.mp4"))
    }
}
