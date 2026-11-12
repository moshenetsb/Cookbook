import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerSection: View {
    let videoName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Film instruktażowy").font(.headline)
            if let url = Bundle.main.url(forResource: videoName.isEmpty ? "cooking_video" : videoName, withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ContentUnavailableView("Brak pliku wideo", systemImage: "video", description: Text("Dodaj cooking_video.mp4 do zasobów projektu w Xcode."))
                    .frame(height: 150)
            }
        }
    }
}

struct AudioPlayerSection: View {
    let audioName: String
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nagranie audio").font(.headline)
            HStack {
                Button {
                    togglePlayback()
                } label: {
                    Label(isPlaying ? "Zatrzymaj" : "Odtwórz audio", systemImage: isPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.green)
                if !errorMessage.isEmpty {
                    Text(errorMessage).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            player?.pause()
            isPlaying = false
            return
        }
        if let player, player.duration > 0 {
            player.play()
            isPlaying = true
            return
        }
        let name = audioName.isEmpty ? "cooking_audio" : audioName
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            errorMessage = "Dodaj cooking_audio.mp3 do zasobów projektu."
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true
            errorMessage = ""
        } catch {
            errorMessage = "Nie udało się odtworzyć audio."
        }
    }
}
