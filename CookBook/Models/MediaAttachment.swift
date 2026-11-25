import Foundation

struct MediaAttachment: Identifiable, Equatable, Sendable {
    let id: UUID
    let kind: MediaKind
    let fileName: String
    let url: URL

    nonisolated init(id: UUID = UUID(), kind: MediaKind, fileName: String, url: URL) {
        self.id = id
        self.kind = kind
        self.fileName = fileName
        self.url = url
    }
}
