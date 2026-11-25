import Foundation

// Wspólne materiały demonstracyjne dla każdego przepisu, także nowego i z dawnej bazy.
// Wybór pliku do odtwarzania nie zależy od migracji ani zapisanych załączników.
enum BundledRecipeMedia {
    nonisolated static func attachment(for kind: MediaKind, bundle: Bundle = .main) -> MediaAttachment? {
        let ext = kind == .video ? "mp4" : "wav"
        let url = bundle.url(forResource: "wrap_chicken", withExtension: ext)
            ?? bundle.url(forResource: "wrap_chicken", withExtension: ext, subdirectory: "Resources")
        guard let url else { return nil }
        return MediaAttachment(kind: kind, fileName: "wrap_chicken.\(ext)", url: url)
    }
}
