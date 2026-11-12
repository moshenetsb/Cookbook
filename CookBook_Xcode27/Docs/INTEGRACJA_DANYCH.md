# Podłączenie bazy danych

Ta wersja celowo nie tworzy bazy SwiftData, Core Data, SQLite ani pliku JSON z przepisami.
Punkt wymiany to protokół `RecipeRepository` w `CookBook/Core/RecipeRepository.swift`.

## Przepływ danych

```text
Widok SwiftUI → RecipeStore → RecipeRepository
                               └── InMemoryRecipeRepository (obecnie)
```

`Recipe` to struktura opisująca przepis. `RecipeStore` udostępnia widokom aktualną listę i obsługuje błędy operacji. `InMemoryRecipeRepository` przechowuje zwykłą tablicę.

1. Dodaj własną klasę zgodną z `RecipeRepository` i zaimplementuj `loadRecipes()`, `save(_:)`, `delete(id:)`.
2. W `CookBookApp.swift` przekaż nową klasę do `RecipeStore(repository: ...)`.
3. Pozostaw identyfikatory przepisów stabilne między uruchomieniami. Nie twórz nowego UUID przy każdym odczycie.
4. Zachowuj `createdAt` podczas edycji; sortowanie „Najnowsze” używa tej daty.
5. Zapisz ulubione razem z przepisem. Zadbaj, żeby usunięcie obejmowało dane powiązane.
6. Dla zdjęć i załączników zaplanuj trwały katalog aplikacji oraz czyszczenie nieużywanych plików. Obecnych adresów z `temporaryDirectory` nie wolno traktować jako trwałych odwołań.
7. Dane demonstracyjne dodawaj tylko przy pierwszym utworzeniu bazy. Usunięcie wszystkich przepisów przez użytkownika nie powinno automatycznie odtwarzać katalogu.

Obecny kontrakt jest synchroniczny i izolowany do `MainActor`, co wystarcza dla małego katalogu. Jeśli nowy magazyn wymaga długich operacji, rozszerz kontrakt o `async` i dodaj stan ładowania w `RecipeStore`; nie blokuj interfejsu długimi odczytami.

Metoda `save(_:)` oznacza dodanie lub aktualizację według `id`. Nie dodawaj duplikatu przy edycji.
W przypadku błędu rzucaj wyjątek zamiast go ignorować. Widoki otrzymują komunikat przez `RecipeStore.errorMessage`.

## Model do odwzorowania w bazie

| Element | Pola / uwagi |
| --- | --- |
| Recipe | id, title, summary, category, diet, preparationTime, difficulty, servings, createdAt, isFavorite, isUserCreated |
| Ingredient | id, name, amount, unit; `amount == nil` oznacza np. „do smaku” |
| PreparationStep | id, title, instruction; zachowaj kolejność tablicy |
| Zdjęcie | nazwa zasobu aplikacji albo dane zdjęcia użytkownika |
| MediaAttachment | rodzaj, nazwa pliku i trwały identyfikator/lokalizacja; obecne URL-e są tymczasowe |

Filtry i edycja są niezależne od magazynu. `RecipeDraft` przechowuje roboczą kopię formularza, a dopiero `makeRecipe()` po walidacji przekazuje poprawny przepis do zapisu.

Po integracji wykonaj dodatkowo: dodaj przepis i ulubione, zamknij aplikację, uruchom ponownie; sprawdź trwałość danych, zdjęć i załączników. Następnie usuń wszystkie przepisy i sprawdź, że nie odtworzyły się bez zgody użytkownika.
