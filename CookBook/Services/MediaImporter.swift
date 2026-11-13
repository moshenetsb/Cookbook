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
    // Kopia w katalogu tymczasowym pozwala odtwarzać plik po zamknięciu selektora.
    // To plik roboczy bieżącej sesji, nie trwały magazyn przepisów.
    static func copyToSession(_ source: URL, kind: MediaKind) throws -> MediaAttachment {
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
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("CookBookMedia", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let id = UUID()
        let destination = directory.appendingPathComponent(id.uuidString).appendingPathExtension(source.pathExtension)
        try FileManager.default.copyItem(at: source, to: destination)
        return MediaAttachment(id: id, kind: kind, fileName: source.lastPathComponent, url: destination)
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
