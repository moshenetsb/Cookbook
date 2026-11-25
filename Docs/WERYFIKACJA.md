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

##Wynik wykonanych testów na macu

Running tests...
    t =      nans Interface orientation changed to Portrait
Test Suite 'All tests' started at 2026-11-25 17:49:20.199.
Test Suite 'CookBookUITests.xctest' started at 2026-11-25 17:49:20.200.
Test Suite 'RecipeFlowUITests' started at 2026-11-25 17:49:20.200.
Test Case '-[CookBookUITests.RecipeFlowUITests testDefaultsDoNotOverwriteAnInProgressDraft]' started.
    t =     0.00s Start Test at 2026-11-25 17:49:20.205
    t =     0.44s Set Up
    t =     0.45s Open moshenets-majerczak.CookBook
    t =     0.45s     Launch moshenets-majerczak.CookBook
AX Safe category class 'SFBarButtonGroupContainerAccessibility' was not found!
    t =     0.89s         Setting up automation session
objc[3761]: Class UIAccessibilityLoaderWebShared is implemented in both /private/var/run/com.apple.security.cryptexd/mnt/com.apple.iPhoneOS.SimulatorRuntime-v24.1.434.0.0wUlov/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 27.0.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebKit.axbundle/WebKit (0x109a7c398) and /private/var/run/com.apple.security.cryptexd/mnt/com.apple.iPhoneOS.SimulatorRuntime-v24.1.434.0.0wUlov/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 27.0.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/WebCore.axbundle/WebCore (0x109bb4310). This may cause spurious casting failures and mysterious crashes. One of the duplicates must be removed or renamed.
AX Safe category class 'SLHighlightDisambiguationPillViewAccessibility' was not found!
    t =     4.16s         Wait for moshenets-majerczak.CookBook to idle
    t =     7.74s Waiting 10.0s for "Szukaj" Button to exist
    t =     8.77s     Checking `Expect predicate `existsNoRetry == 1` for object "Szukaj" Button`
    t =     8.77s         Checking existence of `"Szukaj" Button`
    t =     9.06s Tap "Ustawienia" Button
    t =     9.06s     Wait for moshenets-majerczak.CookBook to idle
    t =     9.07s     Find the "Ustawienia" Button
    t =     9.14s     Check for interrupting elements affecting "Ustawienia" Button
    t =     9.26s     Synthesize event
    t =     9.76s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.65s Tap "increaseDefaultServings" Button
    t =    11.65s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.66s     Find the "increaseDefaultServings" Button
    t =    11.90s     Check for interrupting elements affecting "increaseDefaultServings" Button
    t =    12.02s     Synthesize event
    t =    12.31s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.31s Tap "increaseDefaultServings" Button
    t =    12.31s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.32s     Find the "increaseDefaultServings" Button
    t =    12.44s     Check for interrupting elements affecting "increaseDefaultServings" Button
    t =    12.55s     Synthesize event
    t =    12.85s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.85s Tap "Dodaj" Button
    t =    12.86s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.86s     Find the "Dodaj" Button
    t =    12.99s     Check for interrupting elements affecting "Dodaj" Button
    t =    13.10s     Synthesize event
    t =    13.40s     Wait for moshenets-majerczak.CookBook to idle
    t =    15.61s Tap "recipeTitle" TextField
    t =    15.61s     Wait for moshenets-majerczak.CookBook to idle
    t =    15.62s     Find the "recipeTitle" TextField
    t =    15.99s     Check for interrupting elements affecting "recipeTitle" TextField
    t =    16.13s     Synthesize event
    t =    16.42s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.14s Type 'Mój szkic' into "recipeTitle" TextField
    t =    17.14s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.15s     Find the "recipeTitle" TextField
    t =    17.39s     Check for interrupting elements affecting "recipeTitle" TextField
    t =    17.57s     Synthesize event
    t =    17.92s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.93s Tap "Ustawienia" Button
    t =    17.93s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.93s     Find the "Ustawienia" Button
    t =    18.13s     Check for interrupting elements affecting "gearshape" Button
    t =    18.31s     Synthesize event
    t =    18.60s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.37s Tap "increaseDefaultServings" Button
    t =    20.37s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.38s     Find the "increaseDefaultServings" Button
    t =    20.52s     Check for interrupting elements affecting "increaseDefaultServings" Button
    t =    20.63s     Synthesize event
    t =    20.93s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.93s Tap "Dodaj" Button
    t =    20.93s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.93s     Find the "Dodaj" Button
    t =    21.05s     Check for interrupting elements affecting "plus" Button
    t =    21.15s     Synthesize event
    t =    21.45s     Wait for moshenets-majerczak.CookBook to idle
    t =    23.25s Find the "recipeTitle" TextField
    t =    23.48s Find the "recipeServings" TextField
    t =    23.67s Tap "Wyczyść" Button
    t =    23.67s     Wait for moshenets-majerczak.CookBook to idle
    t =    23.67s     Find the "Wyczyść" Button
    t =    23.86s     Check for interrupting elements affecting "Wyczyść" Button
    t =    24.04s     Synthesize event
    t =    24.34s     Wait for moshenets-majerczak.CookBook to idle
    t =    25.27s Tap "Odrzuć zmiany" Button
    t =    25.27s     Wait for moshenets-majerczak.CookBook to idle
    t =    25.29s     Find the "Odrzuć zmiany" Button
    t =    25.54s     Check for interrupting elements affecting "Odrzuć zmiany" Button
    t =    25.76s     Synthesize event
    t =    26.06s     Wait for moshenets-majerczak.CookBook to idle
    t =    26.49s Find the "recipeServings" TextField
    t =    26.80s Tear Down
Test Case '-[CookBookUITests.RecipeFlowUITests testDefaultsDoNotOverwriteAnInProgressDraft]' passed (27.036 seconds).
Test Case '-[CookBookUITests.RecipeFlowUITests testDetailServingsDoNotOverwriteDefaults]' started.
    t =     0.00s Start Test at 2026-11-25 17:49:47.244
    t =     0.04s Set Up
    t =     0.04s Open moshenets-majerczak.CookBook
    t =     0.05s     Launch moshenets-majerczak.CookBook
    t =     0.05s         Terminate moshenets-majerczak.CookBook:3770
    t =     1.52s         Setting up automation session
    t =     4.41s         Wait for moshenets-majerczak.CookBook to idle
    t =     7.87s Waiting 10.0s for "Szukaj" Button to exist
    t =     8.90s     Checking `Expect predicate `existsNoRetry == 1` for object "Szukaj" Button`
    t =     8.90s         Checking existence of `"Szukaj" Button`
    t =     9.06s Tap "Ustawienia" Button
    t =     9.06s     Wait for moshenets-majerczak.CookBook to idle
    t =     9.06s     Find the "Ustawienia" Button
    t =     9.14s     Check for interrupting elements affecting "Ustawienia" Button
    t =     9.21s     Synthesize event
    t =     9.53s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.36s Tap "increaseDefaultServings" Button
    t =    11.36s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.37s     Find the "increaseDefaultServings" Button
    t =    11.57s     Check for interrupting elements affecting "increaseDefaultServings" Button
    t =    11.68s     Synthesize event
    t =    11.97s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.97s Tap "increaseDefaultServings" Button
    t =    11.97s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.98s     Find the "increaseDefaultServings" Button
    t =    12.10s     Check for interrupting elements affecting "increaseDefaultServings" Button
    t =    12.21s     Synthesize event
    t =    12.50s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.51s Find the "defaultServingsValue" StaticText
    t =    12.65s Tap "Szukaj" Button
    t =    12.65s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.65s     Find the "Szukaj" Button
    t =    12.76s     Check for interrupting elements affecting "Szukaj" Button
    t =    12.88s     Synthesize event
    t =    13.17s     Wait for moshenets-majerczak.CookBook to idle
    t =    15.11s Waiting 5.0s for "recipeSearch" TextField to exist
    t =    16.13s     Checking `Expect predicate `existsNoRetry == 1` for object "recipeSearch" TextField`
    t =    16.13s         Checking existence of `"recipeSearch" TextField`
    t =    16.35s Tap "recipeSearch" TextField
    t =    16.35s     Wait for moshenets-majerczak.CookBook to idle
    t =    16.36s     Find the "recipeSearch" TextField
    t =    16.48s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    16.59s     Synthesize event
    t =    16.88s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.30s Type 'Tost z awokado' into "recipeSearch" TextField
    t =    17.30s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.31s     Find the "recipeSearch" TextField
    t =    17.51s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    17.66s     Synthesize event
    t =    18.10s     Wait for moshenets-majerczak.CookBook to idle
    t =    18.10s Tap Button (First Match)
    t =    18.10s     Wait for moshenets-majerczak.CookBook to idle
    t =    18.11s     Find the Button (First Match)
    t =    18.21s     Check for interrupting elements affecting "recipe-2799CBC3-3E3F-41C7-BFAF-3A37334D6C38" Button
    t =    18.33s     Synthesize event
    t =    18.63s     Wait for moshenets-majerczak.CookBook to idle
    t =    18.93s Find the "servingsStepper" Stepper
    t =    19.34s Find the "servingsStepper" Stepper
    t =    19.62s Tap Button (Element at index 1)
    t =    19.62s     Wait for moshenets-majerczak.CookBook to idle
    t =    19.64s     Find the Button (Element at index 1)
    t =    19.81s     Check for interrupting elements affecting "servingsStepper-Increment" Button
    t =    19.96s     Synthesize event
    t =    20.26s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.27s Find the "servingsStepper" Stepper
    t =    20.45s Tap "Ustawienia" Button
    t =    20.45s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.46s     Find the "Ustawienia" Button
    t =    20.62s     Check for interrupting elements affecting "gearshape" Button
    t =    20.77s     Synthesize event
    t =    21.06s     Wait for moshenets-majerczak.CookBook to idle
    t =    22.78s Find the "defaultServingsValue" StaticText
    t =    22.93s Tap "Szukaj" Button
    t =    22.93s     Wait for moshenets-majerczak.CookBook to idle
    t =    22.93s     Find the "Szukaj" Button
    t =    23.04s     Check for interrupting elements affecting "magnifyingglass" Button
    t =    23.15s     Synthesize event
    t =    23.45s     Wait for moshenets-majerczak.CookBook to idle
    t =    25.15s Find the "servingsStepper" Stepper
    t =    25.34s Tap Button (Element at index 0)
    t =    25.34s     Wait for moshenets-majerczak.CookBook to idle
    t =    25.35s     Find the Button (Element at index 0)
    t =    25.50s     Check for interrupting elements affecting "BackButton" Button
    t =    25.66s     Synthesize event
    t =    25.97s     Wait for moshenets-majerczak.CookBook to idle
    t =    26.53s Tap Button (First Match)
    t =    26.53s     Wait for moshenets-majerczak.CookBook to idle
    t =    26.54s     Find the Button (First Match)
    t =    26.66s     Check for interrupting elements affecting "recipe-2799CBC3-3E3F-41C7-BFAF-3A37334D6C38" Button
    t =    26.79s     Synthesize event
    t =    27.08s     Wait for moshenets-majerczak.CookBook to idle
    t =    27.52s Find the "servingsStepper" Stepper
    t =    27.69s Tear Down
Test Case '-[CookBookUITests.RecipeFlowUITests testDetailServingsDoNotOverwriteDefaults]' passed (27.968 seconds).
Test Case '-[CookBookUITests.RecipeFlowUITests testEmptyRecipeShowsValidationInsteadOfSaving]' started.
    t =     0.00s Start Test at 2026-11-25 17:50:15.213
    t =     0.04s Set Up
    t =     0.04s Open moshenets-majerczak.CookBook
    t =     0.05s     Launch moshenets-majerczak.CookBook
    t =     0.05s         Terminate moshenets-majerczak.CookBook:3796
    t =     1.50s         Setting up automation session
    t =     4.24s         Wait for moshenets-majerczak.CookBook to idle
    t =     7.79s Waiting 10.0s for "Szukaj" Button to exist
    t =     8.82s     Checking `Expect predicate `existsNoRetry == 1` for object "Szukaj" Button`
    t =     8.82s         Checking existence of `"Szukaj" Button`
    t =     9.01s Tap "Dodaj" Button
    t =     9.01s     Wait for moshenets-majerczak.CookBook to idle
    t =     9.02s     Find the "Dodaj" Button
    t =     9.09s     Check for interrupting elements affecting "Dodaj" Button
    t =     9.16s     Synthesize event
    t =     9.50s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.71s Find the "saveRecipe" Button
    t =    13.01s     Find the "saveRecipe" Button (retry 1)
    t =    14.21s     Find the "saveRecipe" Button (retry 2)
    t =    14.40s Swipe up Target Application 'moshenets-majerczak.CookBook'
    t =    14.40s     Wait for moshenets-majerczak.CookBook to idle
    t =    14.40s     Find the Target Application 'moshenets-majerczak.CookBook'
    t =    14.53s     Check for interrupting elements affecting "CookBook" Application
    t =    14.68s     Synthesize event
    t =    15.10s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.19s Find the "saveRecipe" Button
    t =    17.40s Find the "saveRecipe" Button
    t =    17.59s Tap "saveRecipe" Button
    t =    17.59s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.59s     Find the "saveRecipe" Button
    t =    17.75s     Check for interrupting elements affecting "saveRecipe" Button
    t =    17.91s     Synthesize event
    t =    18.21s     Wait for moshenets-majerczak.CookBook to idle
    t =    18.21s Waiting 5.0s for "recipeValidationSummary" Any to exist
    t =    19.23s     Checking `Expect predicate `existsNoRetry == 1` for object "recipeValidationSummary" Any`
    t =    19.23s         Checking existence of `"recipeValidationSummary" Any`
    t =    19.46s Checking existence of `"Dodaj przepis" NavigationBar`
    t =    19.63s Tear Down
Test Case '-[CookBookUITests.RecipeFlowUITests testEmptyRecipeShowsValidationInsteadOfSaving]' passed (19.867 seconds).
Test Case '-[CookBookUITests.RecipeFlowUITests testFavoriteButtonDoesNotOpenRecipeAndSynchronizesWithFavorites]' started.
    t =     0.00s Start Test at 2026-11-25 17:50:35.082
    t =     0.04s Set Up
    t =     0.04s Open moshenets-majerczak.CookBook
    t =     0.05s     Launch moshenets-majerczak.CookBook
    t =     0.05s         Terminate moshenets-majerczak.CookBook:3819
    t =     1.57s         Setting up automation session
    t =     4.31s         Wait for moshenets-majerczak.CookBook to idle
    t =     7.76s Waiting 10.0s for "Szukaj" Button to exist
    t =     8.78s     Checking `Expect predicate `existsNoRetry == 1` for object "Szukaj" Button`
    t =     8.78s         Checking existence of `"Szukaj" Button`
    t =     8.93s Tap "Szukaj" Button
    t =     8.93s     Wait for moshenets-majerczak.CookBook to idle
    t =     8.93s     Find the "Szukaj" Button
    t =     9.01s     Check for interrupting elements affecting "Szukaj" Button
    t =     9.08s     Synthesize event
    t =     9.41s     Wait for moshenets-majerczak.CookBook to idle
    t =    11.40s Waiting 5.0s for "recipeSearch" TextField to exist
    t =    12.41s     Checking `Expect predicate `existsNoRetry == 1` for object "recipeSearch" TextField`
    t =    12.41s         Checking existence of `"recipeSearch" TextField`
    t =    12.65s Tap "recipeSearch" TextField
    t =    12.65s     Wait for moshenets-majerczak.CookBook to idle
    t =    12.65s     Find the "recipeSearch" TextField
    t =    12.77s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    12.89s     Synthesize event
    t =    13.19s     Wait for moshenets-majerczak.CookBook to idle
    t =    13.58s Type 'Curry warzywne' into "recipeSearch" TextField
    t =    13.58s     Wait for moshenets-majerczak.CookBook to idle
    t =    13.59s     Find the "recipeSearch" TextField
    t =    13.81s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    13.96s     Synthesize event
    t =    14.40s     Wait for moshenets-majerczak.CookBook to idle
    t =    14.41s Waiting 5.0s for Button (First Match) to exist
    t =    15.42s     Checking `Expect predicate `existsNoRetry == 1` for object Button (First Match)`
    t =    15.42s         Checking existence of `Button (First Match)`
    t =    15.53s Find the Button (First Match)
    t =    15.64s Tap "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    15.64s     Wait for moshenets-majerczak.CookBook to idle
    t =    15.64s     Find the "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    15.74s     Check for interrupting elements affecting "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    15.87s     Synthesize event
    t =    16.16s     Wait for moshenets-majerczak.CookBook to idle
    t =    16.20s Find the "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    16.32s Checking existence of `"Szukaj przepisów" NavigationBar`
    t =    16.45s Tap "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    16.45s     Wait for moshenets-majerczak.CookBook to idle
    t =    16.46s     Find the "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    16.58s     Check for interrupting elements affecting "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    16.71s     Synthesize event
    t =    17.01s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.01s Find the "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    17.13s Tap "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    17.13s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.13s     Find the "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    17.23s     Check for interrupting elements affecting "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    17.35s     Synthesize event
    t =    17.65s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.65s Tap "Ulubione" Button
    t =    17.65s     Wait for moshenets-majerczak.CookBook to idle
    t =    17.66s     Find the "Ulubione" Button
    t =    17.81s     Check for interrupting elements affecting "heart" Button
    t =    17.95s     Synthesize event
    t =    18.24s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.07s Tap "recipeSearch" TextField
    t =    20.07s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.08s     Find the "recipeSearch" TextField
    t =    20.25s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    20.37s     Synthesize event
    t =    20.66s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.67s Type 'Curry warzywne' into "recipeSearch" TextField
    t =    20.67s     Wait for moshenets-majerczak.CookBook to idle
    t =    20.67s     Find the "recipeSearch" TextField
    t =    20.83s     Check for interrupting elements affecting "recipeSearch" TextField
    t =    20.97s     Synthesize event
    t =    21.41s     Wait for moshenets-majerczak.CookBook to idle
    t =    21.49s Waiting 5.0s for Button (First Match) to exist
    t =    22.51s     Checking `Expect predicate `existsNoRetry == 1` for object Button (First Match)`
    t =    22.51s         Checking existence of `Button (First Match)`
    t =    22.63s Tap Button (First Match)
    t =    22.63s     Wait for moshenets-majerczak.CookBook to idle
    t =    22.64s     Find the Button (First Match)
    t =    22.73s     Check for interrupting elements affecting "favorite-D9D5C9FD-594B-4C3B-9521-D4B743B37519" Button
    t =    22.86s     Synthesize event
    t =    23.15s     Wait for moshenets-majerczak.CookBook to idle
    t =    23.48s Waiting 5.0s for "Brak pasujących przepisów" StaticText to exist
    t =    24.51s     Checking `Expect predicate `existsNoRetry == 1` for object "Brak pasujących przepisów" StaticText`
    t =    24.51s         Checking existence of `"Brak pasujących przepisów" StaticText`
    t =    24.67s Tear Down
Test Case '-[CookBookUITests.RecipeFlowUITests testFavoriteButtonDoesNotOpenRecipeAndSynchronizesWithFavorites]' passed (24.939 seconds).
Test Suite 'RecipeFlowUITests' passed at 2026-11-25 17:51:00.021.
	 Executed 4 tests, with 0 failures (0 unexpected) in 99.811 (99.821) seconds
Test Suite 'CookBookUITests.xctest' passed at 2026-11-25 17:51:00.025.
	 Executed 4 tests, with 0 failures (0 unexpected) in 99.811 (99.825) seconds
Test Suite 'All tests' passed at 2026-11-25 17:51:00.026.
	 Executed 4 tests, with 0 failures (0 unexpected) in 99.811 (99.827) seconds




##Test vid aud
f1
f11
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
non-launching port is incompatible with service identifier "com.apple.PointerUI.pointeruid.default-service"
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
    AVAudioSession_iOS.mm:978   This method can lead to UI unresponsiveness if called on the main thread. Consider using the asynchronous activate/deactivate API instead for calls from the main thread.
AddInstanceForFactory: No factory registered for id <CFUUID 0x114bc4a60> F8BB1C28-BAE8-11D6-9C31-00039315CD46
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
    AVAudioSession_iOS.mm:978   This method can lead to UI unresponsiveness if called on the main thread. Consider using the asynchronous activate/deactivate API instead for calls from the main thread.
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
Snapshotting a view (0x10731cc80, _UINavigationBarLargeTitleView) that has not been rendered at least once requires afterScreenUpdates:YES.
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
    AVAudioSession_iOS.mm:978   This method can lead to UI unresponsiveness if called on the main thread. Consider using the asynchronous activate/deactivate API instead for calls from the main thread.
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
    AVAudioSession_iOS.mm:978   This method can lead to UI unresponsiveness if called on the main thread. Consider using the asynchronous activate/deactivate API instead for calls from the main thread.
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
Unable to get ISSymbol for UTI: com.apple.ios-simulator Error: Error Domain=com.apple.iconServices.symbol-error Code=-1 "Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0" UserInfo={NSLocalizedDescription=Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0}
Unable to get ISSymbol for UTI: com.apple.ios-simulator Error: Error Domain=com.apple.iconServices.symbol-error Code=-1 "Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0" UserInfo={NSLocalizedDescription=Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0}
cannot add handler to 0 from 0 - dropping
Unable to get ISSymbol for UTI: com.apple.ios-simulator Error: Error Domain=com.apple.iconServices.symbol-error Code=-1 "Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0" UserInfo={NSLocalizedDescription=Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0}
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
cannot add handler to 0 from 0 - dropping
Unable to get ISSymbol for UTI: com.apple.ios-simulator Error: Error Domain=com.apple.iconServices.symbol-error Code=-1 "Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0" UserInfo={NSLocalizedDescription=Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0}
cannot add handler to 0 from 0 - dropping
Unable to get ISSymbol for UTI: com.apple.ios-simulator Error: Error Domain=com.apple.iconServices.symbol-error Code=-1 "Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0" UserInfo={NSLocalizedDescription=Failed to find symbol using type id: com.apple.ios-simulator. Options: 1, strategy: 0}
