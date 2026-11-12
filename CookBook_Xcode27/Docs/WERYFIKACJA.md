# Stan weryfikacji — 12 listopada 2026

## Wykonano na Windowsie

- Odczyt obu PDF-ów użytkownika i wizualną kontrolę stron dotyczących makiety oraz wymagań.
- Odczyt struktury wszystkich ośmiu ekranów Figmy, pełnego kontekstu Start i Filtry oraz wizualny przegląd pozostałych ekranów w przeglądarce. Dalszy odczyt kontekstu przez Figma MCP zatrzymał limit planu Starter.
- Kontrolę składni 21 plików Swift parserem Tree-sitter: 19 plików aplikacji, plik testów i manifest pakietu. Po poprawkach brak błędów składni wykrywanych przez ten parser.
- Odczyt `project.pbxproj` parserem OpenStep; sprawdzenie odwołań obiektów, dwóch targetów oraz zgodności 19 plików aplikacji z fazą kompilacji.
- Odczyt pliku Info.plist, schematu, danych workspace i katalogów zasobów.
- Sprawdzenie, że istnieje jeden punkt wejścia `@main`, brak zależności od SwiftData, CloudKit i UserNotifications oraz brak dołączonych plików audio/wideo.
- Weryfikację 15 różnych zdjęć przepisów: dekodowanie, minimalny wymiar 600 px, różne sumy SHA-256, zgodność z kopiami w katalogu zdjęć oraz wizualny przegląd miniaturek.
- Kontrolę, że kod aplikacji nie korzysta z tymczasowych URL-i Figmy.

**Parser składni nie sprawdza typów, izolacji aktorów ani dostępności API w SDK. Powyższe wyniki nie są wynikiem kompilacji Xcode.**

## Jeszcze niewykonane

- Kompilacja na Xcode 27 i uruchomienie na iOS.
- Wykonanie 15 przygotowanych testów XCTest / `swift test`.
- Kontrola wyglądu, nawigacji, zdjęć, importowania i odtwarzania na rzeczywistym iOS lub symulatorze.
- Sprawdzenie dużego rozmiaru tekstu, VoiceOver, małego iPhone'a oraz zachowania przy zmianie aktywności aplikacji.

## Scenariusze na Macu

| Scenariusz | Oczekiwany wynik |
| --- | --- |
| Uruchomienie ⌘R | Ekran Start, zdjęcie orzo, karty szybkich przepisów i pięć zakładek |
| Wyszukanie `losos` | Wynik „Łosoś z cytryną” mimo braku polskich znaków |
| Wyszukanie `orzo szpinak` | Wynik „Orzo z cytryną i ziołami” |
| Wyszukanie nieistniejącego dania | Czytelny pusty wynik i możliwość wyczyszczenia |
| Czas do 30 min + łatwe + dieta wegetariańska + kategoria Makaron | Orzo i makaron pomidorowy |
| Edycja filtrów → Anuluj | Dotychczasowe kryteria pozostają bez zmian |
| Filtry → Wyczyść → Pokaż wyniki | Wszystkie kryteria i sortowanie wracają do wartości domyślnych; fraza wyszukiwania pozostaje |
| Kliknięcie serca | Aktualizują się lista ulubionych i stan serca; pojawia się animacja |
| Usunięcie ostatniego ulubionego | Pojawia się stan „Brak ulubionych” |
| Pusty formularz → Zapisz | Komunikaty o wymaganych danych, brak nowego przepisu |
| Nowy przepis z nazwą, dodatnim czasem/porcjami, składnikiem i krokiem | Nowy przepis pojawia się na początku wyników „Najnowsze” |
| Dodanie składnika `1/2 szt.` albo `1,5 łyżki` | Poprawna ilość w szczegółach i skalowanie |
| Edycja istniejącego przepisu → Anuluj | Oryginał, zdjęcie i ulubione pozostają bez zmian |
| Edycja → Zapisz | Zmienia się ten sam rekord, bez duplikatu |
| Usuń → Anuluj / Usuń | Pierwsza akcja zachowuje przepis; druga usuwa go z wszystkich list |
| Orzo: porcje 2 → 4 → 1 | Orzo: 180 g → 360 g → 90 g; ilości pozostałych składników też się zmieniają |
| Gotowanie | Można zaznaczać składniki i kroki; postęp się aktualizuje; zakończenie wraca do przepisu |
| Dodaj zdjęcie, także z obrotem EXIF | Zdjęcie jest poprawnie obrócone, wyświetla się w formularzu i po zapisie |
| Dodaj film/audio → anulowanie selektora | Brak nowego załącznika i brak fałszywego potwierdzenia |
| Dodaj własny poprawny MP4/MP3 → zapisz | Załącznik można odtworzyć w szczegółach; audio obsługuje pauzę, przewijanie i ponowne odtwarzanie |
| Wyjście z odtwarzacza | Odtwarzanie zatrzymuje się |
| Brak załącznika | Czytelna informacja o braku pliku |
| Zmiana domyślnych porcji | Nowy pusty formularz korzysta z ustawionej wartości; rozpoczęta edycja nie zostaje nadpisana |
| iCloud i powiadomienia | Wiersze informacyjne „Niedostępne”, bez wywoływania usług systemowych |
| Pełne zamknięcie i ponowne uruchomienie | Odtworzenie danych demonstracyjnych; preferencja liczby porcji pozostaje. To oczekiwane do czasu podłączenia bazy |

Nie zaznaczaj tych scenariuszy jako zaliczonych przed ich faktycznym wykonaniem.
