import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultServings") private var defaultServings = 1
    
    var body: some View {
        NavigationStack {
            Form {
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
                    LabeledContent("iCloud", value: "Niedostępne")
                } header: {
                    Text("Przechowywanie danych")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Domyślne porcje")

                            Spacer()

                            Button {
                                defaultServings = max(1, defaultServings - 1)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(defaultServings <= 1 ? Color.gray : AppTheme.green)
                            }
                            .disabled(defaultServings <= 1)
                            .accessibilityLabel("Zmniejsz domyślną liczbę porcji")

                            Text("\(defaultServings)")
                                .font(.headline)
                                .monospacedDigit()
                                .frame(width: 25)
                                .contentTransition(.numericText())
                                .animation(.snappy(duration: 0.2), value: defaultServings)

                            Button {
                                defaultServings = min(12, defaultServings + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(defaultServings >= 12 ? Color.gray : AppTheme.green)
                            }
                            .disabled(defaultServings >= 12)
                            .accessibilityLabel("Zwiększ domyślną liczbę porcji")
                        }

                        Text("Używana przy tworzeniu przepisu i wyświetlaniu przeliczonych ilości składników.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent("Powiadomienia", value: "Niedostępne")

                } header: {
                    Text("Preferencje")
                }
                
                Section("O aplikacji") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CookBook · Wersja 1.0").font(.subheadline.bold()).foregroundStyle(AppTheme.green)
                        Text("Gotuj krok po kroku i korzystaj z wygodnej listy składników").font(.subheadline)
                        Text("Twoje przepisy zawsze pod ręką").font(.caption).foregroundStyle(AppTheme.green)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(AppTheme.mint)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Ustawienia")
            .onAppear {
                defaultServings = min(max(defaultServings, 1), 12)
            }
        }
    }
}
