# Struktura i działanie CookBook

| Katalog | Odpowiedzialność |
| --- | --- |
| `CookBook/App` | Otwarcie bazy, obsługa błędu startu i pięć zakładek |
| `CookBook/Models` | Recipe, Ingredient, PreparationStep, enumy, załączniki, inicjalizacja danych |
| `CookBook/Core` | Niezależne od ekranów reguły filtrowania, szkic formularza, walidacja, zakresy porcji i przykłady |
| `CookBook/Services` | Jawne operacje zapisu/rollback oraz import zdjęć i plików |
| `CookBook/Components` | Kolory, wspólne kontrolki, zdjęcia, wiersze, karty i przycisk serca |
| `CookBook/Views` | Ekrany i lokalny stan interfejsu |
| `CookBook/Assets.xcassets` | 15 zdjęć, logo, ikony i kolory |
| `CookBookTests` | Testy reguł biznesowych i prawdziwego magazynu SwiftData |
| `CookBookUITests` | Scenariusze interakcji wykonywane przez XCTest |
| `Scripts` | Kontrola statyczna i uruchamianie testów na Macu |

Projekt Xcode używa grup synchronizowanych z katalogami. Pliki Swift dodane do
`CookBook`, `CookBookTests` i `CookBookUITests` są automatycznie objęte odpowiednimi targetami.

## Trzy różne znaczenia liczby porcji

1. **Domyślna liczba porcji**: `@AppStorage("defaultServings")`, zapisana między uruchomieniami.
   Służy do rozpoczęcia nowego formularza i nowo otwartych szczegółów.
2. **Bazowe porcje przepisu**: `Recipe.servings`. Dla tej liczby podano ilości w bazie.
3. **Bieżące porcje**: `RecipeDetailView.selectedServings`. Zmieniają prezentację składników
   i są przekazane do CookingView. Nie zmieniają dwóch poprzednich wartości.

Przykład: w bazie jest 200 g mąki dla 2 porcji, domyślna liczba wynosi 3.
Po otwarciu widać `200 × 3 / 2 = 300 g`. Wybranie 4 porcji daje 400 g,
ale w bazie nadal są 200 g i 2 porcje, a ustawienie nadal wynosi 3.
Po ponownym otwarciu przepisu początkowa wartość ponownie wynosi 3.

Edycja przepisu pokazuje wartości bazowe, ponieważ służy do zmiany receptury.
Zmieniając bazową liczbę porcji w edytorze, użytkownik określa, dla ilu osób
są wpisane obok ilości — nie jest to przycisk skalowania istniejącej receptury.

## Bezpieczna edycja i zapis

`RecipeDraft` zawiera wartości edytowane w formularzu. Zmiana pola nie modyfikuje
modelu w bazie. Dopiero poprawna walidacja i `RecipePersistence.save` przenoszą wartości
do modelu. Aktualizacja zachowuje obiekt Recipe oraz istniejące identyfikatory
składników i kroków, a usuwa wyłącznie elementy usunięte ze szkicu.

Jawny `ModelContext.save()` pozwala obsłużyć błąd. `rollback()` przywraca ostatni
zapisany stan. Dotyczy to także przełączenia serca i usuwania przepisu.
Usunięcie Recipe kaskadowo usuwa jego składniki i kroki.

## Ulubione i animacja

`FavoriteButton` jest współdzielony przez szczegóły i wiersz na liście.
Serce jest osobnym przyciskiem obok NavigationLink, dlatego nie powinno otwierać przepisu.
Licznik wyzwalający `symbolEffect(.bounce)` zmienia się po udanym zapisie.
Filtr Ulubionych odświeża się na podstawie danych SwiftData; usunięcie pozycji
ma animację przejścia. Ogranicz ruch wyłącza te efekty.

## Przechowywanie

Baza SwiftData i pliki w Application Support są lokalne. UserDefaults przechowuje
preferencje, przepis dnia oraz informację o zakończonej inicjalizacji przykładów.
Załączniki zapisane przez aplikację mają w modelu względną nazwę pliku, nie pełną
ścieżkę kontenera. Zdjęcia wybrane przez użytkownika są zmniejszane do 1600 px
i przechowywane przez SwiftData jako Data z externalStorage.

Testy UI uruchamiają osobny magazyn w pamięci i oddzielne UserDefaults.
Tryb ten jest dostępny tylko w Debug i nie usuwa prywatnej książki użytkownika.
Test trwałości bazy wykorzystuje osobny katalog tymczasowy na dysku.
