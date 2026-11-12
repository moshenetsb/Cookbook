COOKBOOK — PAKIET ŹRÓDŁOWY DLA XCODE 16
=====================================

Konfiguracja docelowa:
- Xcode 16
- Swift 5 (ustawienie Swift Language Version = Swift 5)
- iOS Deployment Target = 17.0
- SwiftUI + SwiftData + AVKit + AVFoundation
- bez backendu, konta użytkownika i synchronizacji iCloud

CO ZAWIERA PAKIET
-----------------
CookBookApp.swift     punkt startowy aplikacji i konfiguracja SwiftData
Recipe.swift          model przepisu przechowywany lokalnie
SampleRecipes.swift   15 przykładowych przepisów
ContentView.swift     nawigacja i widoki aplikacji
MediaViews.swift      odtwarzacz wideo i audio

JAK URUCHOMIĆ NA MACU W LABORATORIUM
------------------------------------
1. Uruchom Xcode 16.
2. Wybierz File > New > Project.
3. Wybierz iOS > App.
4. Product Name: CookBook
5. Interface: SwiftUI
6. Language: Swift
7. Minimum Deployments: iOS 17.0.
8. Zapisz projekt.
9. Usuń wygenerowany przez Xcode plik ContentView.swift i zastąp go plikiem
   CookBook/ContentView.swift z tego pakietu.
10. Dodaj pozostałe pliki .swift do projektu:
    CookBookApp.swift, Recipe.swift, SampleRecipes.swift, MediaViews.swift.
    Zaznacz opcję "Copy items if needed" i dodaj je do targetu CookBook.
11. Zostaw tylko jeden plik z oznaczeniem @main — CookBookApp.swift z pakietu.
    Jeżeli Xcode utworzył drugi plik aplikacji, usuń go z targetu lub zastąp
    jego zawartość wersją z pakietu.
12. W ustawieniach projektu ustaw:
    - iOS Deployment Target: 17.0
    - Swift Language Version: Swift 5
13. Uruchom aplikację na symulatorze iPhone.

WAŻNE — MULTIMEDIA I ZDJĘCIA
----------------------------
Kod zawiera 15 rekordów przykładowych przepisów. Na tym etapie zdjęcia dla
większości pozycji są zastępowane ikoną kategorii. Nie oznacza to spełnienia
wymogu 15 różnych zdjęć — właściwe fotografie trzeba jeszcze dodać do
Assets.xcassets i przypisać do przepisów.

W widoku Start użyte są nazwy zasobów:
recipe_orzo, recipe_salmon, recipe_chickpea.
Należy utworzyć dla nich Image Set w Assets.xcassets i umieścić pliki PNG/JPG.

Aby spełnić wymagania multimedialne kursu, dodaj do targetu aplikacji:
- cooking_video.mp4
- cooking_audio.mp3

Pliki muszą być dodane do targetu (Target Membership) i kopiowane do bundle.
Kod wyświetli komunikat, jeśli plik nie został dodany. W tym pakiecie nie
dołączono fikcyjnych plików multimedialnych udających prawdziwe nagrania.

ZAKRES FUNKCJONALNY W TEJ WERSJI
--------------------------------
- 5 zakładek: Start, Szukaj, Ulubione, Dodaj, Ustawienia
- 15 przykładowych przepisów
- wyszukiwanie po nazwie i składnikach
- filtry: czas, dieta i trudność; czyszczenie filtrów
- szczegóły przepisu, składniki i kroki
- zaznaczanie składników podczas gotowania
- ulubione z animacją
- dodawanie, edycja i usuwanie własnych przepisów z potwierdzeniem
- wybór zdjęcia własnego przepisu z galerii i lokalny zapis zdjęcia
- notatki i ocena lokalna
- lokalny zapis SwiftData

UWAGA TECHNICZNA
----------------
To jest pierwsza wersja kodu źródłowego, a nie zweryfikowany build Xcode.
W tym środowisku nie ma macOS/Xcode, dlatego nie mogę wykonać kompilacji iOS.
Po pierwszym uruchomieniu na Macu trzeba sprawdzić ewentualne komunikaty
kompilatora i poprawić je przed oddaniem projektu.
