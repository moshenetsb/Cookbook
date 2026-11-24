import SwiftUI
import AVKit
import AVFoundation
import Combine

struct MediaPlayerView: View {
    @Environment(\.dismiss) private var dismiss
    let kind: MediaKind
    let attachment: MediaAttachment?
    @State private var videoPlayer: AVPlayer?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    ContentUnavailableView("Nie można odtworzyć pliku", systemImage: "exclamationmark.triangle", description: Text(errorMessage))
                } else if let attachment {
                    if kind == .video {
                        VideoPlayer(player: videoPlayer).frame(minHeight: 240).padding()
                    } else {
                        AudioPlayerView(attachment: attachment)
                    }
                } else {
                    ContentUnavailableView(
                        kind == .video ? "Brak filmu" : "Brak nagrania",
                        systemImage: kind.symbol,
                        description: Text("Ten przepis nie ma jeszcze załącznika. Możesz dodać własny plik podczas edycji przepisu.")
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.background)
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Gotowe") { dismiss() } } }
            .task {
                guard kind == .video, let attachment else { return }
                guard FileManager.default.fileExists(atPath: attachment.url.path) else {
                    errorMessage = "Plik nie jest już dostępny. Dodaj go ponownie."
                    return
                }
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
                    try AVAudioSession.sharedInstance().setActive(true)
                    let asset = AVURLAsset(url: attachment.url)
                    guard try await asset.load(.isPlayable) else {
                        errorMessage = "Format lub kodowanie tego filmu nie jest obsługiwane."
                        return
                    }
                    videoPlayer = AVPlayer(playerItem: AVPlayerItem(asset: asset))
                } catch { errorMessage = error.localizedDescription }
            }
            .onDisappear {
                videoPlayer?.pause()
                videoPlayer = nil
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
    }
}

private struct AudioPlayerView: View {
    let attachment: MediaAttachment
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var elapsed = 0.0
    @State private var duration = 0.0
    @State private var errorMessage: String?
    private let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.circle.fill").font(.system(size: 70)).foregroundStyle(AppTheme.green)
            Text(attachment.fileName).font(.headline).multilineTextAlignment(.center)
            if let errorMessage {
                Text(errorMessage).font(.subheadline).foregroundStyle(.red)
            } else {
                Slider(value: Binding(
                    get: { elapsed },
                    set: { elapsed = $0; player?.currentTime = $0 }
                ), in: 0...max(duration, 1))
                .accessibilityLabel("Pozycja nagrania")
                Text("\(timeLabel(elapsed)) / \(timeLabel(duration))").font(.caption.monospacedDigit())
                Button(isPlaying ? "Pauza" : "Odtwórz", systemImage: isPlaying ? "pause.fill" : "play.fill") {
                    guard let player else { return }
                    if player.isPlaying {
                        player.pause()
                    } else {
                        if player.currentTime >= player.duration - 0.1 { player.currentTime = 0 }
                        if !player.play() { errorMessage = "Nie udało się rozpocząć odtwarzania." }
                    }
                    isPlaying = player.isPlaying
                }
                .buttonStyle(PrimaryButtonStyle()).disabled(player == nil)
            }
        }
        .padding(24)
        .task {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: attachment.url)
                player?.prepareToPlay()
                duration = player?.duration ?? 0
            } catch { errorMessage = "Nie udało się odtworzyć nagrania. \(error.localizedDescription)" }
        }
        .onReceive(timer) { _ in
            guard let player else { return }
            elapsed = player.currentTime
            isPlaying = player.isPlaying
        }
        .onDisappear { player?.stop() }
    }

    private func timeLabel(_ seconds: Double) -> String {
        let seconds = max(0, Int(seconds))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
