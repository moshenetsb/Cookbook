import SwiftUI

enum AppTheme {
    static let green = Color("AccentColor")
    static let mint = Color("Mint")
    static let background = Color("AppBackground")
    static let border = Color("CardBorder")
    static let ink = Color("Ink")
    static let muted = Color("MutedText")
    static let surface = Color(.systemBackground)
    static let pageInset: CGFloat = 24
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 46)
            .foregroundStyle(.white)
            .background(AppTheme.green.opacity(isEnabled ? 1 : 0.45), in: RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct FilterChip: View {
    let title: String
    var isSelected = false
    var prominent = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? (prominent ? .white : AppTheme.green) : AppTheme.ink)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? (prominent ? AppTheme.green : AppTheme.mint) : AppTheme.surface, in: Capsule())
                .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct SearchField: View {
    @Binding var text: String
    var prompt = "Nazwa dania lub składnik"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppTheme.green)
            TextField(prompt, text: $text)
                .font(.subheadline)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityIdentifier("recipeSearch")
            if !text.isEmpty {
                Button("Wyczyść wyszukiwanie", systemImage: "xmark.circle.fill") { text = "" }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.leading, 14)
        .padding(.trailing, text.isEmpty ? 14 : 0)
        .frame(minHeight: 48)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.border))
    }
}

extension View {
    func cookbookCard() -> some View {
        padding(14)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border))
    }
}
