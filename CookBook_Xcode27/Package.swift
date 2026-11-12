// swift-tools-version: 6.0
import PackageDescription

// Pakiet służy wyłącznie do testowania logiki, bez symulatora i SwiftUI.
// Samą aplikację uruchamiamy z CookBook.xcodeproj.
let package = Package(
    name: "CookBookCore",
    platforms: [.macOS(.v14)],
    products: [.library(name: "CookBookCore", targets: ["CookBookCore"])],
    targets: [
        .target(name: "CookBookCore", path: "CookBook/Core"),
        .testTarget(name: "CookBookCoreTests", dependencies: ["CookBookCore"], path: "Tests")
    ]
)
