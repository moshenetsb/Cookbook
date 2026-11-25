import SwiftUI

struct SettingsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                    LabeledContent {
                        Image(systemName: "checkmark")
                            .foregroundStyle(AppTheme.green)
                    } label: {
                        Text("Na tym urządzeniu")
                    }
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
                            .buttonStyle(.borderless)
                            .frame(minWidth: 44, minHeight: 44)
                            .accessibilityIdentifier("decreaseDefaultServings")
                            .accessibilityLabel("Zmniejsz domyślną liczbę porcji")

                            Text("\(defaultServings)")
                                .font(.headline)
                                .monospacedDigit()
                                .frame(width: 25)
                                .contentTransition(.numericText())
                                .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: defaultServings)
                                .accessibilityIdentifier("defaultServingsValue")

                            Button {
                                defaultServings = min(12, defaultServings + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(defaultServings >= 12 ? Color.gray : AppTheme.green)
                            }
                            .disabled(defaultServings >= 12)
                            .buttonStyle(.borderless)
                            .frame(minWidth: 44, minHeight: 44)
                            .accessibilityIdentifier("increaseDefaultServings")
                            .accessibilityLabel("Zwiększ domyślną liczbę porcji")
                        }

                        Text("Początkowa liczba porcji w nowym przepisie i przy otwieraniu przepisu. Zmiana porcji w otwartym przepisie nie zmienia tego ustawienia.")
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
                defaultServings = ServingPreferences.normalizedDefault(defaultServings)
            }
        }
    }
}
