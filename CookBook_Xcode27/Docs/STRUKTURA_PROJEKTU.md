# Opis struktury projektu — etap 2

CookBook jest aplikacją iOS do przeglądania i organizowania przepisów. Implementacja obejmuje osiem widoków z makiety, korzysta z SwiftUI i nie zawiera bazy danych.

## Układ katalogów

```text
CookBook.xcodeproj/     konfiguracja aplikacji, testów i wspólnego schematu
CookBook/
  App/                 start aplikacji, zakładki i wspólny stan
  Core/                modele, wyszukiwanie, walidacja i repozytorium w pamięci
  Components/          współdzielone elementy interfejsu i kolory
  Features/            poszczególne ekrany
  Services/            importowanie zdjęć oraz załączników
  Assets.xcassets/     obrazy i kolory aplikacji
  Info.plist           podstawowe informacje o aplikacji
Tests/                 testy logiki w XCTest
Docs/                  opis projektu, weryfikacja, integracja danych
RecipePhotos/          zdjęcia i ich źródła
Package.swift          możliwość uruchomienia testów samej logiki
Archiwum/Kod_Xcode16/   pierwotny kod zachowany na pulpicie
```

## Mapa implementacji

Numery odnoszą się do plików przekazanych w tej wersji. Po zmianach w kodzie mogą się przesunąć.

| Funkcja | Plik | Linia |
| --- | --- | --- |
| Uruchomienie aplikacji i wybór repozytorium | [CookBook/App/CookBookApp.swift](../CookBook/App/CookBookApp.swift) | 5 |
| Pięć zakładek i przejścia Start / Szukaj / Dodaj | [CookBook/App/ContentView.swift](../CookBook/App/ContentView.swift) | 7 |
| Wspólny stan listy, zapis, usuwanie i ulubione | [CookBook/App/RecipeStore.swift](../CookBook/App/RecipeStore.swift) | 6 |
| Model przepisu bez powiązania z bazą danych | [CookBook/Core/Recipe.swift](../CookBook/Core/Recipe.swift) | 91 |
| Przeliczanie ilości składników według liczby porcji | [CookBook/Core/Recipe.swift](../CookBook/Core/Recipe.swift) | 51 |
| Wyszukiwanie, filtry i sortowanie | [CookBook/Core/RecipeFilter.swift](../CookBook/Core/RecipeFilter.swift) | 34 |
| Walidacja nazwy, czasu, porcji, składników i kroków | [CookBook/Core/RecipeDraft.swift](../CookBook/Core/RecipeDraft.swift) | 89 |
| Przekształcenie poprawnego formularza w przepis | [CookBook/Core/RecipeDraft.swift](../CookBook/Core/RecipeDraft.swift) | 111 |
| Kontrakt do podłączenia bazy przez drugą osobę | [CookBook/Core/RecipeRepository.swift](../CookBook/Core/RecipeRepository.swift) | 6 |
| 15 demonstracyjnych przepisów | [CookBook/Core/SampleRecipes.swift](../CookBook/Core/SampleRecipes.swift) | 5 |
| Wspólne kolory i styl przycisków | [CookBook/Components/AppTheme.swift](../CookBook/Components/AppTheme.swift) | 3 |
| Wyświetlanie zdjęcia z Assets lub danych użytkownika | [CookBook/Components/RecipeComponents.swift](../CookBook/Components/RecipeComponents.swift) | 4 |
| Serce, zmiana ulubionych i animacja | [CookBook/Components/RecipeComponents.swift](../CookBook/Components/RecipeComponents.swift) | 44 |
| Wspólny wiersz list, Edytuj i Usuń | [CookBook/Components/RecipeComponents.swift](../CookBook/Components/RecipeComponents.swift) | 69 |
| Ekran Start i wyróżniony przepis | [CookBook/Features/HomeView.swift](../CookBook/Features/HomeView.swift) | 3 |
| Wyszukiwanie i lista wyników | [CookBook/Features/SearchView.swift](../CookBook/Features/SearchView.swift) | 3 |
| Panel filtrów z roboczą kopią ustawień | [CookBook/Features/SearchView.swift](../CookBook/Features/SearchView.swift) | 67 |
| Lista ulubionych z wyszukiwaniem i filtrami | [CookBook/Features/FavoritesView.swift](../CookBook/Features/FavoritesView.swift) | 11 |
| Zdjęcie, opis, porcje, składniki i otwieranie mediów | [CookBook/Features/RecipeDetailView.swift](../CookBook/Features/RecipeDetailView.swift) | 3 |
| Lista kroków, postęp i zakończenie gotowania | [CookBook/Features/CookingView.swift](../CookBook/Features/CookingView.swift) | 3 |
| Formularz dodawania i edycji | [CookBook/Features/RecipeFormView.swift](../CookBook/Features/RecipeFormView.swift) | 5 |
| Odbiór pliku wybranego w systemowym selektorze | [CookBook/Features/RecipeFormView.swift](../CookBook/Features/RecipeFormView.swift) | 229 |
| Odtwarzacz filmu lub pusty stan załącznika | [CookBook/Features/MediaPlayerView.swift](../CookBook/Features/MediaPlayerView.swift) | 6 |
| Odtwarzanie, pauza i przewijanie audio | [CookBook/Features/MediaPlayerView.swift](../CookBook/Features/MediaPlayerView.swift) | 63 |
| Preferencja liczby porcji i informacyjne ustawienia | [CookBook/Features/SettingsView.swift](../CookBook/Features/SettingsView.swift) | 3 |
| Kontrola typu/rozmiaru i tymczasowa kopia pliku | [CookBook/Services/MediaImporter.swift](../CookBook/Services/MediaImporter.swift) | 23 |

## Powiązanie z planem aplikacji

| Obszar planu | Implementacja w bieżącym zakresie |
| --- | --- |
| F01 — katalog | HomeView, RecipeRow, RecipeCard, 15 przepisów i 15 zdjęć |
| F02 — wyszukiwanie | RecipeFilter i SearchView; wyszukiwanie również w składnikach |
| F03 — filtry i sortowanie | Czas, kategoria, dieta, trudność; dopasowanie, czas, data, nazwa |
| F04 — szczegóły | RecipeDetailView i CookingView; ilości, porcje, składniki, kroki |
| F05 — ulubione | RecipeStore i FavoritesView; wspólny stan wszystkich ekranów |
| F06 — receptury | RecipeDraft i RecipeFormView; tworzenie, edycja, potwierdzane usuwanie |
| Załączniki użytkownika | Wybór plików, pusty stan i odtwarzanie wybranego pliku |
| F08 — trwałość danych | Do wykonania przez osobę odpowiedzialną za bazę; przygotowano kontrakt repozytorium |
| Animacja | FavoriteButton; wyłączenie ruchu przy systemowym ustawieniu dostępności |

Zakres uwzględnia późniejsze ustalenia użytkownika: brak bazy przepisów, powiadomień i iCloud. Początkowe załączniki są puste.

## Jak czytać kod

1. Zacznij od `CookBookApp`: powstaje jeden wspólny `RecipeStore` i trafia do środowiska widoków.
2. `ContentView` pokazuje pięć zakładek. Każda ma własną nawigację.
3. `@State` przechowuje stan danego ekranu, np. zaznaczone składniki. `@Environment(RecipeStore.self)` daje ekranowi dostęp do wspólnego katalogu.
4. Zmiana ulubionego przechodzi przez `RecipeStore`. Ponieważ magazyn jest obserwowalny, inne ekrany otrzymują aktualny stan bez ręcznego odświeżania.
5. Formularz pracuje na `RecipeDraft`, czyli osobnej wartości. Dzięki temu pisanie w polu nie zmienia od razu oryginalnego przepisu, a Anuluj jest bezpieczne.
6. `RecipeRepository` oddziela zachowanie interfejsu od sposobu przechowywania danych. Podłączenie bazy nie wymaga przepisywania każdego ekranu.
7. Czas i liczba porcji są dodatnimi liczbami całkowitymi. Ilości składników są liczbami z jednostką albo opisem, takim jak „do smaku”. Przy zmianie porcji skaluje się wyłącznie ilość liczbowa.

Kod aktualizujący wspólny stan pracuje na `MainActor`. Kopiowanie większego pliku jest wykonywane poza głównym aktorem, aby nie zatrzymywać interfejsu. To rozdzielenie jest istotne przy trybie języka Swift 6.

## Wygląd

Źródłem jest [makieta CookBook](https://www.figma.com/design/vgZWh2beTDXL7IzFBNNiK3/CookBook).
Zachowano zielony akcent, miętowe powierzchnie, jasne tło, zaokrąglone zdjęcia, układ zakładek i nazwy akcji.
SF Pro zastępuje Inter zgodnie z decyzją użytkownika. Natywne `NavigationStack`, `TabView`, `List`, `Form`, selektory i arkusze obsługują nawigację, przewijanie oraz wielkość tekstu. Nie odtwarzano sztucznego paska statusu ani Dynamic Island z makiety.

Nie wykonano jeszcze porównania renderowania SwiftUI z Figmą na iOS. Sprawdzenie wizualne i interakcyjne jest opisane w [dokumencie weryfikacji](WERYFIKACJA.md).
