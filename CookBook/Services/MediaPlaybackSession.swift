import AVFoundation
import Foundation

// Własny actor wykonuje blokujące operacje AVAudioSession poza MainActor.
// Każde otwarcie odtwarzacza ma własny token: spóźnione zamknięcie starego
// widoku nie wyłącza sesji używanej już przez kolejny odtwarzacz.
actor MediaPlaybackSession {
    nonisolated static let shared = MediaPlaybackSession()
    private var owners: Set<UUID> = []

    private init() {}

    func activate(for owner: UUID) throws {
        guard !owners.contains(owner) else { return }
        if owners.isEmpty {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        }
        owners.insert(owner)
    }

    func release(_ owner: UUID) {
        guard owners.remove(owner) != nil, owners.isEmpty else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            NSLog("CookBook: nie udało się dezaktywować sesji audio: %@", error.localizedDescription)
        }
    }
}
