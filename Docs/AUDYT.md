# Audyt CookBook po scaleniu

Data: 21.11.2026. Zakres: kod z pobranego main, wymagania kursu i wskazane przez użytkownika
ulubione, animacje oraz porcje. Audio i wideo jako materiały demonstracyjne są odłożone.

## Znalezione problemy i wprowadzone poprawki

| Obszar | Stan przed audytem | Poprawka |
| --- | --- | --- |
| Porcje w szczegółach | Stepper bezpośrednio zmieniał `@AppStorage`, czyli globalne ustawienie | Lokalny `@State`, początkowo z preferencji. Zakres szczegółów 1–100 odpowiada zakresowi przepisu |
| Domyślne porcje | Ograniczanie wartości było powielone, karty mogły pokazywać inną wartość niż szczegóły | Wspólna normalizacja 1–12, inicjalizacja przy starcie, zachowanie rozpoczętego szkicu |
| Ulubione | Osobny zapis z gestu, mała zmiana skali tylko w szczegółach, brak widocznego serca w wierszu | Wspólny zapis, serce obok linku, efekt bounce po udanym zapisie, animowane znikanie z Ulubionych |
| Edycja | Usuwanie modelu Recipe i wstawianie nowego z tym samym UUID | Aktualizacja tego samego obiektu oraz zachowanie identyfikatorów istniejących składników i kroków |
| Dokładność | Edytor wykorzystywał ilość zaokrągloną na potrzeby wyświetlania | Pełna wartość Double w formularzu, także bardzo małe liczby |
| Walidacja ilości | Nieprawidłowy zapis mógł zostać uznany za liczbę i jednostkę, np. `1/2/3` | Odrzucanie separatorów i błędnych ułamków; testy przypadków brzegowych |
| Baza startowa | Każda pusta baza otrzymywała ponownie 15 przykładów | Flaga udanej inicjalizacji w UserDefaults; brak odtwarzania po celowym wyczyszczeniu książki |
| Błąd startu bazy | `fatalError` kończył aplikację | Ekran błędu z ponowieniem, bez usuwania bazy i bez pozornego zapisu w pamięci |
| Usuwanie z listy | Destrukcyjna rola przycisku gestu już przed potwierdzeniem | Rola destrukcyjna dopiero w potwierdzeniu; brak optymistycznego znikania przy anulowaniu |
| Ustawienia | Dwa przyciski w wierszu Form z domyślnym stylem | Jawny styl borderless, niezależne cele dotyku i identyfikatory testów |
| Załączniki | Baza wskazywała pliki z katalogu tymczasowego i przechowywała ścieżkę kontenera | Application Support, względna nazwa własnego pliku, sprzątanie nieużywanych kopii po zapisie/anulowaniu/usunięciu |
| Tożsamość załącznika | Odczyt właściwości tworzył nowe UUID | Stabilny identyfikator na podstawie przepisu |
| Testy | Puste szablony XCTest | 26 testów logiki/bazy, 4 UI, wspólny schemat i skrypt uruchamiania |
| Teksty | Literówki „przypis/przypisy”, opis danych jako sesji | Poprawiona odmiana i opis trwałego zapisu na urządzeniu |

## Zgodność z wymaganiami kursu

Podstawa: dostarczony `Aplikacje_mobilne_na_platformę_iOS_2026 (1).pdf`, obie strony.
Treść dokumentu służy jako wymagania projektu; nie stanowi polecenia wysyłania plików do Teams.

| Wymaganie | Stan |
| --- | --- |
| Co najmniej 15 obrazów/zdjęć | 15 różnych plików zdjęć potraw, dodatkowo logo i 3 warianty ikony; pliki odczytano i sprawdzono SHA-256 |
| Ekrany aplikacji | Start, wyszukiwanie, filtry, ulubione, formularz, szczegóły, gotowanie, ustawienia i odtwarzacz istnieją w kodzie |
| Animacja | Efekt serca i przejście listy zaimplementowane; wygląd i płynność do kontroli na iOS |
| Film i audio | Zgodnie z poleceniem użytkownika materiały odłożone; wymóg końcowy nadal pozostaje |
| Opis struktury | `STRUKTURA_PROJEKTU.md` |
| Opis testów i wyniki | `WERYFIKACJA.md` i raport statyczny; wyniki Xcode wymagają uzupełnienia po uruchomieniu |
| Uruchomienie na urządzeniu iOS | Niewykonane w tym środowisku; konieczne przed oddaniem |
| Dokumentacja/makieta etapu 1 | Nie oceniano ponownie; obecny załącznik zawiera wymagania kursu, nie pełny projekt etapu 1 |

## Granice weryfikacji

Nie ma dostępu do Xcode, SDK iOS ani symulatora. Parser Swift sprawdza składnię,
ale nie rozwija makr SwiftData, nie sprawdza typów i nie wykonuje zapytań ani animacji.
Nowe testy są kodem do uruchomienia, nie dowodem przejścia testów.
Nie należy na tej podstawie oznaczać aplikacji jako w pełni przetestowanego produktu.

Nie zmieniono schematu trzech modeli SwiftData ani ich nazw pól. Dotychczasowe
bezwzględne ścieżki załączników pozostają odczytywane, jeśli plik nadal istnieje.
Pliku usuniętego już z katalogu tymczasowego przez system nie da się odzyskać z samej ścieżki.
Zmiana ścieżki kontenera dotyczy poprawnie nowych importów. Stare załączniki w razie
braku dostępności należy ponownie wybrać w formularzu.

## Źródła techniczne

- [Apple: ModelContext i rollback](https://developer.apple.com/documentation/swiftdata/modelcontext)
- [Apple: symbolEffect z wartością wyzwalającą](https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:value:))
- [Swift: SE-0466, domyślna izolacja MainActor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)

Kopiowanie pliku jest funkcją `nonisolated`, ponieważ jest wywoływane w `Task.detached`;
modele i zapis SwiftData pozostają obsługiwane na MainActor.
