# Cookbook

Natywna książka kucharska w SwiftUI ze stałym lokalnym zapisem SwiftData.
Projekt zachowuje konfigurację z main: Xcode 27, deployment target iOS 27.0, iPhone i iPad.

## Stan po naprawie mediów 25.11.2026

Log dostarczony z Maca potwierdza 4 zaliczone testy UI poprzedniej wersji.
Poprawiona wersja zawiera 31 testów logiki/integracji i 5 testów UI (łącznie 36).
Kontrole statyczne i dekodowanie plików mediów na Windows przeszły poprawnie.
**Kompilacja, nowe testy i odtwarzanie na iOS po tej poprawce wymagają weryfikacji na Macu.**

- [Naprawa mediów, aktualne wyniki i kroki przed oddaniem](Docs/NAPRAWA_MEDIA_2026-11-25.md)

- [Audyt i lista poprawek](Docs/AUDYT.md)
- [Struktura i działanie projektu](Docs/STRUKTURA_PROJEKTU.md)
- [Procedura testów i miejsce na wyniki z Maca](Docs/WERYFIKACJA.md)
- [Maszynowy raport kontroli statycznej](Docs/static-validation.json)

## Najważniejsze zachowania

- **Porcje:** ustawienie 1–12 określa początkową liczbę porcji w nowym przepisie
  i po otwarciu szczegółów. W szczegółach można wybrać 1–100 porcji na potrzeby
  bieżącego gotowania. Ta zmiana nie nadpisuje preferencji ani bazowych ilości w bazie.
  Edycja przepisu pokazuje jego własną bazową liczbę porcji.
- **Ulubione:** serce działa na liście i w szczegółach; zapis jest jawny, a przy
  błędzie stan jest cofany. Animacja uwzględnia ustawienie systemowe Ogranicz ruch.
- **Edycja i usuwanie:** przeciągnij wiersz w prawo. Usuwanie wymaga potwierdzenia.
  Edycja zachowuje tożsamość przepisu, datę utworzenia i polubienie.
- **Dane startowe:** 15 przykładowych przepisów dodaje się raz. Usunięcie całej
  książki nie powoduje odtworzenia przykładów przy kolejnym starcie.
- **Multimedia:** wybór własnego zdjęcia i załączników jest dostępny.
  Przyciski odtwarzania w każdej potrawie zawsze uruchamiają te same pliki
  `wrap_chicken.mp4` i `wrap_chicken.wav` z pakietu aplikacji, także offline.
  Szczegóły: [Multimedia](Docs/MULTIMEDIA.md).

Do końcowego zaliczenia pozostaje uruchomienie na urządzeniu iOS, udokumentowanie
wyników testów oraz sprawdzenie odtwarzania dołączonego filmu i audio.

## Pochodzenie

Baza robocza Main: `moshenetsb/Cookbook`.
Kontekst porównania: [scalenie SwiftData](https://github.com/moshenetsb/Cookbook/commit/25e1b3faa478107ca0e612b5994bc161e2fc8b11)
oraz [wcześniejsza integracja interfejsu](https://github.com/moshenetsb/Cookbook/commit/a52c75570b559d15fba37181c06e445f7b92a3f0).

## Schemat bazy danych

Dane przepisów są przechowywane lokalnie przez `SwiftData`. Usunięcie przepisu usuwa również powiązane składniki i kroki przygotowania.

```mermaid
erDiagram
    RECIPE ||--o{ INGREDIENT : "zawiera"
    RECIPE ||--o{ PREPARATION_STEP : "ma kroki"

    RECIPE {
        UUID id PK
        String title
        String summary
        RecipeCategory category
        Diet diet
        Int preparationTime
        Difficulty difficulty
        Int servings
        String imageName
        Data imageData
        Bool isFavorite
        Date createdAt
        String videoPath
        String videoFileName
        String audioPath
        String audioFileName
    }

    INGREDIENT {
        UUID id PK
        String name
        Double amount
        String unit
        Int order
        UUID recipe FK
    }

    PREPARATION_STEP {
        UUID id PK
        String title
        String instruction
        Int order
        UUID recipe FK
    }
```
