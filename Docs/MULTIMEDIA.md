# Multimedia: Wrap z kurczakiem

Aktualizacja 21.11.2026 po audycie.

- Film użytkownika `Cooking_chicken_tortilla_wrap_57b89e75.mp4` skopiowano bez
  modyfikacji do `CookBook/Resources/wrap_chicken.mp4` (6 400 753 bajty).
- Zsynchronizowana grupa CookBook obejmuje ten zasób w aplikacji. Nie wymaga internetu.
- Przy pierwszym uruchomieniu tej wersji seeder przypina film do przykładowego
  „Wrapa z kurczakiem”, także w istniejącej bazie. Nie odtwarza usuniętego przepisu,
  nie zastępuje własnego załącznika i nie przywraca filmu po późniejszym usunięciu.
- Ścieżka w bazie: `bundle:wrap_chicken.mp4`. Jest rozwiązywana względem aktualnego
  pakietu aplikacji, dzięki czemu nie zależy od zmiennej ścieżki kontenera iOS.
- Otwórz przepis i dotknij **Obejrzyj film**.

## Audio dodane

Ponownie dostarczony `instrukcja-wrap-z-kurczakiem.wav` jest poprawnym WAV:
PCM 16-bit, mono, 48 kHz, 21,92 sekundy, 2 104 364 bajty. Skopiowano go bez
modyfikacji do `CookBook/Resources/wrap_chicken.wav`; alternatywny MP3 nie był potrzebny.
W szczegółach przepisu wybierz **Instrukcja audio**, a następnie **Odtwórz**.

Ścieżka w bazie to `bundle:wrap_chicken.wav`. Niezależna migracja
`wrapChickenBundledAudioV1` uzupełnia istniejący przepis także po wcześniejszym
dodaniu filmu. Nie zastępuje własnego nagrania ani nie przywraca później usuniętego audio.
Poprzednia, błędna wersja pliku zawierająca HTML nie została dodana do aplikacji.

## Weryfikacja

Sprawdzono nagłówek i strukturę MP4, zgodność kopii SHA-256 oraz składnię Swift.
Sprawdzono również pełny odczyt danych PCM i zgodność kopii WAV przez SHA-256.
Testy obejmują migrację filmu, ochronę własnych załączników i niezależne dodanie audio.
Testy XCTest i odtwarzanie w AVPlayer wymagają uruchomienia na Macu/iOS.
