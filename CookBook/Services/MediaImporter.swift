import Foundation
import UniformTypeIdentifiers
import ImageIO
import UIKit

enum MediaImportError: LocalizedError {
    case unsupportedType
    case tooLarge
    case invalidPhoto

    var errorDescription: String? {
        switch self {
        case .unsupportedType: return "Wybierz obsługiwany plik wybranego rodzaju."
        case .tooLarge: return "Plik jest zbyt duży. Limit wynosi 250 MB dla filmu i 50 MB dla audio."
        case .invalidPhoto: return "Nie udało się odczytać tego zdjęcia. Wybierz inne."
        }
    }
}

enum MediaImporter {
    // Plik musi przetrwać restart aplikacji razem z rekordem SwiftData.
    nonisolated static func copyToLibrary(_ source: URL, kind: MediaKind) throws -> MediaAttachment {
        let hasAccess = source.startAccessingSecurityScopedResource()
        defer { if hasAccess { source.stopAccessingSecurityScopedResource() } }
        let values = try source.resourceValues(forKeys: [.contentTypeKey, .fileSizeKey, .isRegularFileKey])
        let type = values.contentType ?? UTType(filenameExtension: source.pathExtension)
        let expected: UTType = kind == .video ? .movie : .audio
        guard values.isRegularFile != false, type?.conforms(to: expected) == true else {
            throw MediaImportError.unsupportedType
        }
        let maximumSize = (kind == .video ? 250 : 50) * 1024 * 1024
        guard let size = values.fileSize, size > 0, size <= maximumSize else { throw MediaImportError.tooLarge }
        let directory = try libraryDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let id = UUID()
        let destination = directory.appendingPathComponent(id.uuidString).appendingPathExtension(source.pathExtension)
        try FileManager.default.copyItem(at: source, to: destination)
        return MediaAttachment(id: id, kind: kind, fileName: source.lastPathComponent, url: destination)
    }

    nonisolated static func libraryDirectory() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                    appropriateFor: nil, create: true)
            .appendingPathComponent("CookBookMedia", isDirectory: true)
    }

    // Zapis samej nazwy pozwala odnaleźć plik także po zmianie ścieżki kontenera iOS.
    nonisolated static func storedPath(for url: URL) -> String {
        if let resourceRoot = Bundle.main.resourceURL,
           url.deletingLastPathComponent().standardizedFileURL == resourceRoot.standardizedFileURL {
            return "bundle:" + url.lastPathComponent
        }
        if let library = try? libraryDirectory(),
           url.deletingLastPathComponent().standardizedFileURL == library.standardizedFileURL {
            return url.lastPathComponent
        }
        return url.path
    }

    nonisolated static func resolve(_ path: String) -> URL? {
        if path.hasPrefix("bundle:") {
            let name = String(path.dropFirst("bundle:".count))
            guard !name.isEmpty, !name.contains("/"), name != ".", name != ".." else { return nil }
            return Bundle.main.url(forResource: name, withExtension: nil)
        }
        if path.hasPrefix("/") { return URL(fileURLWithPath: path) } // starsza baza
        guard !path.isEmpty, !path.contains("/"), path != ".", path != ".." else { return nil }
        return try? libraryDirectory().appendingPathComponent(path)
    }

    /// Usuwa wyłącznie własne, nieużywane kopie po zapisie lub zamknięciu formularza.
    nonisolated static func removeUnused(_ urls: [URL], keeping retained: Set<URL>) {
        guard let library = try? libraryDirectory() else { return }
        for url in urls where !retained.contains(url) {
            guard url.deletingLastPathComponent().standardizedFileURL == library.standardizedFileURL else { continue }
            try? FileManager.default.removeItem(at: url)
        }
    }

    static func preparePhoto(_ data: Data) throws -> Data {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 1600
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
              let jpeg = UIImage(cgImage: thumbnail).jpegData(compressionQuality: 0.85) else {
            throw MediaImportError.invalidPhoto
        }
        return jpeg
    }
}
