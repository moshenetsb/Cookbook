import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultServings") private var defaultServings = 2

    var body: some View {
        NavigationStack {
            Form {
                Text("Dostosuj CookBook do swoich potrzeb").font(.subheadline).foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                Section {
                    HStack(spacing: 12) {
                        Text("M").font(.headline).foregroundStyle(AppTheme.green)
                            .frame(width: 44, height: 44).background(AppTheme.mint, in: Circle())
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Moja książka kucharska").font(.headline)
                            Text("Twoje pomysły na dobre jedzenie").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                Section {
                    LabeledContent("Bieżąca sesja", value: "Na tym iPhonie")
                    LabeledContent("iCloud", value: "Niedostępne").foregroundStyle(.secondary)
                } header: {
                    Text("Przechowywanie danych")
                } footer: {
                    Text("Zmiany przepisów i ulubionych są dostępne do ponownego uruchomienia aplikacji.")
                }

                Section {
                    Stepper("Domyślne porcje: \(defaultServings)", value: $defaultServings, in: 1...12)
                    LabeledContent("Powiadomienia", value: "Niedostępne").foregroundStyle(.secondary)
                } header: {
                    Text("Preferencje")
                } footer: {
                    Text("Domyślna liczba porcji jest używana przy tworzeniu nowego przepisu.")
                }

                Section("O aplikacji") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CookBook · Wersja 1.0").font(.subheadline.bold()).foregroundStyle(AppTheme.green)
                        Text("Gotuj krok po kroku i korzystaj z wygodnej listy składników.").font(.subheadline)
                        Text("Twoje przepisy zawsze pod ręką").font(.caption).foregroundStyle(AppTheme.green)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(AppTheme.mint)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Ustawienia")
        }
    }
}
