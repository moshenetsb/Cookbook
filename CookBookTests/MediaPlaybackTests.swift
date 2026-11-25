import XCTest
import AVFoundation
@testable import CookBook

final class MediaPlaybackTests: XCTestCase {
    // Testujemy zasoby z rzeczywistego pakietu aplikacji, a nie pliki z katalogu projektu.
    @MainActor
    func testBundledVideoIsPlayableAndPlaybackAdvances() async throws {
        let attachment = try XCTUnwrap(BundledRecipeMedia.attachment(for: .video))
        XCTAssertEqual(attachment.url.lastPathComponent, "wrap_chicken.mp4")
        let asset = AVURLAsset(url: attachment.url)
        let playable = try await asset.load(.isPlayable)
        XCTAssertTrue(playable)
        let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        let token = UUID()
        try await MediaPlaybackSession.shared.activate(for: token)
        do {
            player.play()
            for _ in 0..<80 {
                if player.currentTime().seconds > 0.1 || player.currentItem?.status == .failed { break }
                try await Task.sleep(for: .milliseconds(100))
            }
            XCTAssertNotEqual(player.currentItem?.status, .failed)
            XCTAssertGreaterThan(player.currentTime().seconds, 0.1, "Film nie rozpoczął odtwarzania.")
        } catch {
            player.pause()
            await MediaPlaybackSession.shared.release(token)
            throw error
        }
        player.pause()
        await MediaPlaybackSession.shared.release(token)
    }

    @MainActor
    func testBundledAudioPlaysAndCanRestart() async throws {
        let attachment = try XCTUnwrap(BundledRecipeMedia.attachment(for: .audio))
        XCTAssertEqual(attachment.url.lastPathComponent, "wrap_chicken.wav")
        let player = try AVAudioPlayer(contentsOf: attachment.url)
        XCTAssertEqual(player.duration, 21.92, accuracy: 0.1)
        let token = UUID()
        try await MediaPlaybackSession.shared.activate(for: token)
        do {
            XCTAssertTrue(player.prepareToPlay())
            for _ in 0..<2 {
                player.currentTime = 0
                XCTAssertTrue(player.play())
                try await Task.sleep(for: .milliseconds(500))
                XCTAssertGreaterThan(player.currentTime, 0.1)
                player.pause()
                XCTAssertFalse(player.isPlaying)
            }
        } catch {
            player.stop()
            await MediaPlaybackSession.shared.release(token)
            throw error
        }
        player.stop()
        await MediaPlaybackSession.shared.release(token)
    }
}
