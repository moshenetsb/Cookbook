# CookBook — etap 2 projekt na Xcode 27

Natywna aplikacja w SwiftUI z ośmioma ekranami opartymi na makiecie CookBook.
Projekt ma własny plik `CookBook.xcodeproj`. Nie trzeba tworzyć nowego projektu ani ręcznie dodawać plików Swift.

## Co jest zaimplementowane

- Start, Szukaj, Szczegóły przepisu, Gotowanie, Ulubione, Dodaj/Edytuj, Filtry i Ustawienia.
- 15 przykładowych przepisów z 15 różnymi lokalnymi zdjęciami; logo oraz trzy pierwsze zdjęcia pochodzą z Figmy.
- Wyszukiwanie po nazwie i składnikach, także bez polskich znaków; filtrowanie czasu, trudności, diety i kategorii.
- Sortowanie według dopasowania, czasu, daty utworzenia i nazwy.
- Dodawanie, edycja i usuwanie przepisów po potwierdzeniu; walidacja formularza i wybór zdjęcia.
- Ulubione, wyszukiwanie w ulubionych oraz animacja serca z poszanowaniem ustawienia Ogranicz ruch.
- Zmiana porcji z przeliczeniem ilości składników, zaznaczanie składników i postępu gotowania.
- Wybór własnego filmu/audio z aplikacji Pliki i ich odtwarzanie po zapisaniu przepisu. Początkowo załączniki są puste.
- Ustawienie domyślnej liczby porcji dla nowych przepisów.

Na listach można edytować i usuwać także przepisy demonstracyjne, zgodnie z akcjami widocznymi w makiecie.
Wyszukiwanie i filtry nie zmieniają katalogu. Anulowanie edycji nie zapisuje zmian.

## Dane — ważne na tym etapie

**Nie ma bazy danych przepisów.** `InMemoryRecipeRepository` przechowuje dane wyłącznie w pamięci procesu.
Dodane przepisy, edycje, usunięcia i ulubione znikają po pełnym zamknięciu i ponownym uruchomieniu aplikacji. To celowe ograniczenie zakresu tej wersji.

Zdjęcia dodane przez użytkownika pozostają w pamięci, a załączniki audio/wideo są kopiowane do katalogu tymczasowego aplikacji. Nie powstaje trwały katalog przepisów. Domyślna liczba porcji to jedyna preferencja zapisywana przez `AppStorage`.

Nie zaimplementowano synchronizacji iCloud ani systemu powiadomień. Ich wiersze w ustawieniach są informacyjne i pokazują „Niedostępne”.

Osoba odpowiedzialna za bazę powinna zacząć od [instrukcji integracji](Docs/INTEGRACJA_DANYCH.md).

## Pliki do nauki i dalszej pracy

- [Opis struktury projektu i mapa kodu](Docs/STRUKTURA_PROJEKTU.md) — artefakt etapu 2 i miejsca implementacji.
- [Źródła zdjęć](RecipePhotos/SOURCES.md) — autorzy i strony źródłowe.
- `RecipePhotos/` — osobny folder ze zdjęciami, a `CookBook/Assets.xcassets/` — ich kopie używane przez aplikację.
- `Archiwum/Kod_Xcode16/` — niezmieniony kod sprzed przebudowy, zachowany na pulpicie poza targetem aplikacji.


