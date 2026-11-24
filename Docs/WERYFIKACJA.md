# Weryfikacja CookBook

## Wyniki uzyskane 24.11.2026 na Windows

| Kontrola | Wynik |
| --- | --- |
| Przegląd wszystkich plików Swift, konfiguracji i zasobów | Wykonany; poprawki opisano w AUDYT.md |
| Składnia Swift: Tree-sitter | 27 plików, brak błędów parsera |
| Odczyt project.pbxproj: parser OpenStep | 37 obiektów, 3 targety |
| Schemat CookBook: XML i identyfikatory targetów | Poprawny odczyt i powiązania |
| Zasoby obrazów i wymiary ikon | 19 obrazów odczytanych; 3 ikony po 1024 × 1024 |
| Unikatowe zdjęcia potraw | 15 różnych sum SHA-256 |
| Kompilacja i sprawdzenie typów Swift | **Niewykonane — brak Xcode/SDK iOS** |
| XCTest: 29 testów logiki i integracji | **Przygotowane, niewykonane** |
| XCTest: 4 testy interfejsu | **Przygotowane, niewykonane** |
| Animacje, układ i gesty na iOS | **Niewykonane** |
| Uruchomienie na fizycznym urządzeniu | **Niewykonane** |
| Odtwarzanie audio/wideo | **Film i WAV dodane; odtwarzanie na iOS niesprawdzone** |

Dokładny raport i sumy plików źródłowych: `static-validation.json`.
Kontrola statyczna nie jest substytutem kompilacji, testów ani przeglądu wizualnego.

## Brakujące testy na Macu

1. Otwórz `CookBook.xcodeproj` w Xcode 27 lub zgodnym nowszym wydaniu.
2. Wybierz schemat CookBook i dostępny symulator iOS zgodny z targetem 27.0.
3. **Cmd+B**: zbuduj aplikację. Zanotuj błędy i ostrzeżenia.
4. **Cmd+U**: wykonaj oba targety testowe. Testy UI korzystają z osobnej bazy w pamięci.
5. Uruchom zwykłą aplikację **Cmd+R** i wykonaj scenariusze poniżej.
6. Wykonaj próbę na fizycznym iPhonie/iPadzie, wybierając własny Team do podpisu.

Można użyć skryptu: `bash Scripts/verify_on_mac.sh UDID_SYMULATORA`.
Bez argumentu wyświetla on listę urządzeń. Wynik to `TestResults/<czas>/Tests.xcresult`
oraz logi testów i budowania Release. Nie wpisuj wyniku PASS, jeśli skrypt
przerwał działanie lub któryś z testów został pominięty.

## Zakres testów automatycznych

| Plik | Liczba | Scenariusze |
| --- | --- | --- |
| RecipeLogicTests.swift | 16 | Ilości polskie, ułamki, niepoprawne zapisy, skalowanie, ochrona przed zerowym mianownikiem, domyślne/bazowe porcje, precyzja, niezależność szkicu, walidacja pól, filtry, sortowanie, 15 poprawnych przykładów |
| RecipePersistenceTests.swift | 13 | Wielokrotne polubienie, trwały zapis, edycja tego samego obiektu, brak osieroconych składników, kaskada usuwania, brak zapisu błędnego szkicu, jednokrotna inicjalizacja, istniejąca baza, ponowne otwarcie bazy na dysku, rollback po odmowie zapisu i stabilność ścieżki załącznika |
| RecipeFlowUITests.swift | 4 | Serce bez nawigacji, synchronizacja Ulubionych, oddzielenie bieżących porcji od preferencji, zachowanie szkicu przy zmianie ustawień, komunikat walidacji |

Jeden test może zawierać kilka powiązanych asercji. Testy UI sprawdzają stan
i interakcje; nie oceniają jakości animacji na podstawie obrazu.

## Ręczna kontrola ulubionych i animacji

- [ ] Wyszukaj Curry warzywne. Dotknij serca: karta pozostaje na miejscu,
  serce się wypełnia i wykonuje jeden krótki bounce. Nie otwierają się szczegóły.
- [ ] Dotknij ponownie: serce wraca do pustego. Sprawdź 10 szybkich kliknięć —
  parzysta liczba przywraca początkowy stan, nie ma opóźnionego ponownego polubienia.
- [ ] Otwórz szczegóły, przełącz serce i wróć do listy. Stan jest jednakowy.
- [ ] Otwórz Ulubione, usuń polubienie. Wiersz znika płynnie, licznik maleje.
  Usunięcie ostatniego pokazuje ekran pustej listy.
- [ ] Sprawdź akcję serca po przeciągnięciu wiersza w prawo.
- [ ] Zamknij proces aplikacji i otwórz ją ponownie. Polubienia pozostają.
- [ ] W systemie włącz Dostępność → Ruch → Ogranicz ruch. Serce działa bez bounce,
  lista zmienia się bez animowanego przejścia. Wyłącz opcję i sprawdź ponownie.

## Ręczna kontrola porcji

- [ ] Ustaw domyślne porcje na 3. Otwórz Orzo: 180 g / 2 × 3 daje **270 g**.
- [ ] Zmień bieżące porcje na 4: Orzo pokazuje **360 g**. Ustawienia nadal pokazują 3.
- [ ] Przejdź do gotowania: nagłówek pokazuje 4, ilość Orzo wynosi 360 g.
- [ ] Wróć do listy i ponownie otwórz przepis: zaczyna od 3 i 270 g.
- [ ] Edytuj Orzo: liczba bazowa nadal wynosi 2, ilość 180 g.
- [ ] Nowy formularz zaczyna od 3. Zmień tytuł, przejdź do ustawień i ustaw 4.
  Rozpoczęty formularz zachowuje 3. Po Wyczyść → Odrzuć zmiany pokazuje 4.
- [ ] W ustawieniach minus przy 1 i plus przy 12 są wyłączone; kliknięcie jednego
  przycisku nie uruchamia drugiego. Szczegóły pozwalają wybrać do 100 porcji.
- [ ] Po ponownym uruchomieniu aplikacji preferencja pozostaje zapisana.

## Pozostałe scenariusze odbioru

- [ ] Dodaj kompletny przepis, przejdź do wyszukiwania, otwórz go i uruchom ponownie aplikację.
- [ ] Edytuj tytuł, składnik, liczbę porcji i krok. Sprawdź kolejność po ponownym uruchomieniu.
- [ ] Anuluj edycję: dane oryginalne nie ulegają zmianie. Sprawdź potwierdzenie odrzucenia zmian.
- [ ] Usuń składnik i krok, dodaj nowe, zapisz. Nie ma starych ani podwójnych elementów.
- [ ] Niepoprawne ilości, brak nazwy, czasu, składników i kroków blokują zapis i mają komunikaty.
- [ ] Wywołaj usuwanie gestem, anuluj. Wiersz zostaje. Potwierdzenie usuwa go ze wszystkich list.
- [ ] Na testowej instalacji usuń wszystkie przepisy. Restart pozostawia pustą książkę.
- [ ] Wyszukaj „losos”, „cytryna”, kilka słów; połącz filtry, sprawdź sortowania i puste wyniki.
- [ ] Anulowanie arkusza filtrów nie stosuje zmian. Pokaż wyniki je stosuje.
- [ ] Wybierz zdjęcie, zapisz, zamknij aplikację. Zdjęcie pozostaje i ma poprawną orientację.
- [ ] Przepis dnia jest stabilny w ciągu dnia; po jego usunięciu wybierany jest inny.
- [ ] Sprawdź checklistę i postęp gotowania, powrót z komunikatu Smacznego.
- [ ] Sprawdź mały i duży iPhone, iPad, obrót, duży rozmiar tekstu, VoiceOver i klawiaturę.
- [ ] Po dodaniu końcowych materiałów: import, odtwarzanie, pauza, przewijanie, wyjście
  z odtwarzacza, ponowne uruchomienie i odtwarzanie zapisanych plików.

## Wyniki do uzupełnienia po wykonaniu

| Data / urządzenie / iOS / Xcode | Scenariusz | PASS / FAIL / niewykonany | Dowód lub opis błędu |
| --- | --- | --- | --- |
| — | Budowanie Debug i Release | niewykonany | — |
| — | 29 testów logiki/bazy | niewykonany | plik .xcresult |
| — | 4 testy UI | niewykonany | plik .xcresult |
| — | Animacje i Ogranicz ruch | niewykonany | obserwacja/nagranie |
| — | Urządzenie fizyczne | niewykonany | — |
| — | Końcowe audio/wideo | niewykonany | Pliki dołączone; sprawdzić na iOS |

## Powtórzenie kontroli statycznej

Zainstaluj `tree-sitter`, `tree-sitter-swift`, `openstep-parser` i `Pillow`,
a następnie wykonaj `python Scripts/verify_project.py`.
Skrypt zapisuje tylko wynik analizy statycznej; celowo nie oznacza kompilacji i XCTest jako wykonanych.

Aktualizacja multimediów: patrz [MULTIMEDIA.md](MULTIMEDIA.md). Dwa dodatkowe testy
sprawdzają jednorazowe dodanie filmu do istniejącej bazy i ochronę własnego załącznika.

Dodano też test niezależnej migracji WAV po wcześniejszym dodaniu filmu.
