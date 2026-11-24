import Foundation
import SwiftData

enum RecipeSeeder {
    static let completionKey = "sampleRecipesSeededV1"
    static let wrapVideoKey = "wrapChickenBundledVideoV1"
    static let wrapAudioKey = "wrapChickenBundledAudioV1"

    static func seedIfNeeded(in modelContext: ModelContext, defaults: UserDefaults = .standard) throws {
        guard !defaults.bool(forKey: completionKey) else {
            try attachWrapVideo(in: modelContext, defaults: defaults)
            try attachWrapAudio(in: modelContext, defaults: defaults)
            return
        }
        if try modelContext.fetchCount(FetchDescriptor<Recipe>()) == 0 {
            for recipe in SampleRecipes.make() {
                modelContext.insert(recipe)
            }
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                throw error
            }
        }
        // Także istniejąca baza oznacza zakończoną inicjalizację.
        // Pusta książka po świadomym usunięciu przepisów ma pozostać pusta.
        defaults.set(true, forKey: completionKey)
        try attachWrapVideo(in: modelContext, defaults: defaults)
        try attachWrapAudio(in: modelContext, defaults: defaults)
    }

    // Jednorazowe uzupełnienie również istniejącej bazy. Nie zastępuje własnego filmu
    // i nie przywraca załącznika, który użytkownik później świadomie usunie.
    private static func attachWrapVideo(in context: ModelContext, defaults: UserDefaults) throws {
        guard !defaults.bool(forKey: wrapVideoKey) else { return }
        guard let url = Bundle.main.url(forResource: "wrap_chicken", withExtension: "mp4") else { return }
        let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.imageName == "recipe_chicken_wrap" })
        let recipes = try context.fetch(descriptor)
        for recipe in recipes where recipe.videoPath == nil {
            recipe.video = MediaAttachment(kind: .video, fileName: "Wrap z kurczakiem.mp4", url: url)
        }
        do {
            try context.save()
            defaults.set(true, forKey: wrapVideoKey)
        } catch {
            context.rollback()
            throw error
        }
    }

    // Osobny znacznik: wcześniejsze dodanie filmu nie blokuje aktualizacji audio.
    private static func attachWrapAudio(in context: ModelContext, defaults: UserDefaults) throws {
        guard !defaults.bool(forKey: wrapAudioKey) else { return }
        guard let url = Bundle.main.url(forResource: "wrap_chicken", withExtension: "wav") else { return }
        let descriptor = FetchDescriptor<Recipe>(predicate: #Predicate { $0.imageName == "recipe_chicken_wrap" })
        let recipes = try context.fetch(descriptor)
        for recipe in recipes where recipe.audioPath == nil {
            recipe.audio = MediaAttachment(kind: .audio, fileName: "Instrukcja — wrap z kurczakiem.wav", url: url)
        }
        do {
            try context.save()
            defaults.set(true, forKey: wrapAudioKey)
        } catch {
            context.rollback()
            throw error
        }
    }
}
