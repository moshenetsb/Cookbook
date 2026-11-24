"""Wykonuje kontrole na hoście i tworzy raport; nie symuluje wyników XCTest.
Dependencies: reportlab, Pillow, pypdf, tree-sitter, tree-sitter-swift,
openstep-parser, imageio-ffmpeg. Run with Python 3.12+.
"""
from pathlib import Path
import array, csv, hashlib, json, platform, re, shutil, subprocess, sys, wave
from datetime import datetime
from zoneinfo import ZoneInfo
from xml.sax.saxutils import escape
import imageio_ffmpeg
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'Docs/TestyEtap3'
OUT.mkdir(parents=True, exist_ok=True)
stamp = datetime.now(ZoneInfo('Europe/Warsaw')).isoformat(timespec='seconds')
def write(name, text):
    (OUT / name).write_text(text, encoding='utf-8', newline='\n')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
files = sorted(p for folder in ['CookBook','CookBookTests','CookBookUITests','CookBook.xcodeproj'] for p in (ROOT/folder).rglob('*') if p.is_file() and 'xcuserdata' not in p.parts)
manifest = {p.relative_to(ROOT).as_posix():sha(p) for p in files}
revision = hashlib.sha256(json.dumps(manifest,sort_keys=True).encode()).hexdigest()
write('manifest-sha256.json',json.dumps(manifest,indent=2,ensure_ascii=False))

checks=[]
def check(id, title, passed, actual, evidence):
    checks.append(dict(id=id,title=title,status='PASS' if passed else 'FAIL',actual=actual,evidence=evidence))
r=subprocess.run([sys.executable,'-X','utf8',str(ROOT/'Scripts/verify_project.py')],capture_output=True,text=True,encoding='utf-8')
write('static-run.log',r.stdout+r.stderr)
s=json.loads((ROOT/'Docs/static-validation.json').read_text(encoding='utf-8'))
check('S01','Składnia i integralność projektu',r.returncode==0 and not s['errors'],f"{s['swift_files_parsed']} plików Swift; {s['xcode_objects']} obiektów; 3 targety; schemat XML; brak błędów raportu. Nie sprawdzono typów ani makr.",'static-run.log; ../static-validation.json')
check('S02','Obrazy i fotografie',s['unique_recipe_photos']==15 and s['asset_images_verified']==19 and not s['errors'],'Odczytano 19 obrazów; 15 różnych zdjęć potraw; ikony mają 1024 x 1024.','static-run.log')
ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
version=subprocess.run([ffmpeg,'-version'],capture_output=True,text=True).stdout.splitlines()[0]
write('ffmpeg-version.txt',version)
for num,ext in [(3,'mp4'),(4,'wav')]:
    path=ROOT/f'CookBook/Resources/wrap_chicken.{ext}'
    args=[ffmpeg,'-hide_banner','-v','error','-xerror','-i',str(path),'-map','0:v?','-map','0:a?','-f','null','-']
    run=subprocess.run(args,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=120)
    write(f'decode-{ext}.log',f'Time: {stamp}\nCommand: {args!r}\nExit: {run.returncode}\n'+run.stdout+run.stderr)
    info=subprocess.run([ffmpeg,'-hide_banner','-i',str(path)],capture_output=True,text=True,encoding='utf-8',errors='replace')
    write(f'info-{ext}.log',info.stderr)
    check(f'S0{num}',f'Pełne dekodowanie {ext.upper()}',run.returncode==0,f'FFmpeg przetworzył cały plik; kod zakończenia {run.returncode}. To test pliku, nie odtwarzacza iOS.',f'decode-{ext}.log; info-{ext}.log')
with wave.open(str(ROOT/'CookBook/Resources/wrap_chicken.wav')) as w:
    n=w.getnframes(); rate=w.getframerate(); channels=w.getnchannels(); width=w.getsampwidth(); data=w.readframes(n)
    audio=dict(seconds=n/rate,frames=n,rate=rate,channels=channels,bits=width*8,bytes=len(data),nonzero=any(array.array('h',data)))
write('audio-pcm.json',json.dumps(audio,indent=2))
check('S05','Struktura WAV i dane PCM',len(data)==n*channels*width and audio['nonzero'],f"{audio['seconds']} s; {rate} Hz; {channels} kanał; {width*8} bit; odczyt wszystkich próbek, sygnał nie jest całkowicie zerowy. Nie oceniano treści narracji.",'audio-pcm.json')
originals={'mp4':'Cooking_chicken_tortilla_wrap_57b89e75.mp4','wav':'instrukcja-wrap-z-kurczakiem.wav'}
copies={ext:sha(ROOT/f'CookBook/Resources/wrap_chicken.{ext}')==sha(Path.home()/'Downloads'/name) for ext,name in originals.items()}
write('media-copy.json',json.dumps(copies,indent=2))
check('S06','Zgodność załączników z oryginałami',all(copies.values()),'Porównanie SHA-256 obu zasobów z dostarczonymi plikami w Downloads.','media-copy.json; manifest-sha256.json')
desktop=Path.home()/'Desktop/Cookbook-main/Cookbook-main'
same=all((desktop/name).exists() and sha(desktop/name)==value for name,value in manifest.items())
check('S07','Tożsamość testowanej wersji',same,f'Porównano {len(manifest)} plików źródeł, testów, zasobów i projektu z folderem na Pulpicie.','manifest-sha256.json')
missing=[]
for path in ROOT.rglob('*.md'):
    for link in re.findall(r'\]\(([^)]+)\)',path.read_text(encoding='utf-8')):
        if not link.startswith(('https:','http:','#')) and not (path.parent/link.split('#')[0]).exists(): missing.append(str(path)+': '+link)
write('documentation-links.json',json.dumps(missing,ensure_ascii=False))
check('S08','Lokalne odsyłacze dokumentacji',not missing,f'Nieprawidłowe lokalne odsyłacze: {len(missing)}. Nie sprawdzano stron zewnętrznych.','documentation-links.json')
environment={'timestamp':stamp,'os':platform.platform(),'python':sys.version,'ffmpeg':version,'xcodebuild':shutil.which('xcodebuild'),'swift':shutil.which('swift'),'revision_sha256':revision,'source_folder':str(desktop)}
write('environment.json',json.dumps(environment,indent=2,ensure_ascii=False))

objectives=[
'Odczyt 1,5; 1/2; 250g i tekstu do smaku','Odrzucenie zera, wartości ujemnych, błędnych ułamków i przepełnienia','Skalowanie 200 g / 2 do 300 g / 3 bez zmiany modelu','Brak dzielenia przez zero dla starych danych','Domyślne porcje dla nowego szkicu, bazowe dla edycji','Ograniczenie preferencji do 1-12','Zachowanie Double i UUID przy edycji','Niezależność niezapisanego szkicu od modelu','Wymagane pola pustego formularza','Błędy częściowo wypełnionych wierszy','Pomijanie całkowicie pustych dodatkowych wierszy','Granice porcji 1-100 i czasu 1-1440','Wyszukiwanie bez polskich znaków i wieloma słowami','Przecięcie filtrów i dieta wegetariańska','Sortowanie i stabilność remisów','Walidacja 15 przykładów i kolejność składników',
'Film w istniejącej bazie, brak odtwarzania po usunięciu','Zachowanie własnego filmu i audio','Audio po wcześniejszej migracji filmu, tylko raz','Wielokrotne polubienie i odczyt w nowym kontekście','Tożsamość edytowanego modelu, data i polubienie','Usunięcie starych dzieci i poprawne relacje nowych','Usuwanie kaskadowe składników i kroków','Błędny szkic nie zmienia bazy','Jednorazowy seed, także po wyczyszczeniu książki','Brak zasiewania istniejącej bazy','Ponowne otwarcie magazynu na dysku','Rollback po zapisie do magazynu tylko do odczytu','Stabilność załącznika i względna ścieżka',
'Serce bez nawigacji; synchronizacja z Ulubionymi','Bieżące porcje nie nadpisują preferencji','Zmiana preferencji nie nadpisuje rozpoczętego szkicu','Pusty formularz zgłasza walidację zamiast zapisu']
tests=[]
for name in ['CookBookTests/RecipeLogicTests.swift','CookBookTests/RecipePersistenceTests.swift','CookBookUITests/RecipeFlowUITests.swift']:
    for method in re.findall(r'func (test\w+)\(', (ROOT/name).read_text(encoding='utf-8')):
        idx=len(tests)
        tests.append(dict(id=f'A{idx+1:02}',file=name,method=method,title=objectives[idx],status='NIEWYKONANY',actual='Brak Xcode/SDK iOS w środowisku wykonawczym.',evidence='Do uzyskania: Tests.xcresult'))
assert len(tests)==33

# Cel, warunki początkowe, kroki, oczekiwany wynik, dowód.
cases=[
('Dodanie przepisu','Zwykła instalacja, zakładka Dodaj.','Wpisz Test ryżu, 20 min, 2 porcje, Ryż 200 g, krok Ugotuj. Zapisz i wyszukaj Test ryżu.','Jeden przepis z podanymi danymi; formularz wyczyszczony po zapisie.','Zrzut formularza i szczegółów'),
('Walidacja granic','Nowy formularz z poprawnym składnikiem i krokiem.','Sprawdź osobno porcje 0, 1, 100, 101 oraz czas 0, 1, 1440, 1441. Sprawdź pusty tytuł i ilość 1/0.','1 i 100 porcji oraz 1 i 1440 min akceptowane; pozostałe skrajne wartości odrzucone. Puste wymagane dane nie zapisują przepisu.','Zrzuty błędów, tabela wejść i wyników'),
('Anulowanie edycji','Istnieje Test ryżu.','Przeciągnij wiersz w prawo, Edytuj. Zmień tytuł i ilość; Anuluj, odrzuć zmiany.','Oryginalny tytuł, 200 g i liczba porcji pozostają.','Zrzut przed i po'),
('Edycja i kolejność','Test ryżu ma dwa składniki i dwa kroki; jest ulubiony.','Usuń jeden składnik i krok, dodaj nowe; zapisz; zamknij i otwórz aplikację.','Zmiany trwałe, kolejność właściwa, brak duplikatu przepisu i polubienie zachowane.','Nagranie i zrzut po restarcie'),
('Potwierdzenie usuwania','Test ryżu istnieje.','Wybierz Usuń gestem; anuluj. Powtórz i potwierdź; sprawdź wyszukiwanie i Ulubione.','Anulowanie zachowuje wiersz. Potwierdzenie usuwa przepis ze wszystkich list.','Nagranie obu wariantów'),
('Ulubione i animacja','Curry warzywne nie jest ulubione; Ogranicz ruch wyłączone.','Dotknij serca na liście; otwórz szczegóły i Ulubione; usuń polubienie. Powtórz 10 kliknięć na liście.','Serce nie otwiera przepisu; stan zgodny; bounce widoczny; parzysta liczba przełączeń przywraca stan; brak awarii.','Nagranie ekranu'),
('Ogranicz ruch','Włącz systemowe Ogranicz ruch.','Powtórz przełączenie serca w szczegółach i usunięcie pozycji z Ulubionych.','Zapis działa bez bounce i animowanego przejścia listy.','Nagranie z ustawieniem systemowym'),
('Skalowanie porcji','Domyślne 3; Orzo ma 180 g dla 2 porcji.','Otwórz Orzo; wybierz 4 porcje; przejdź do gotowania; sprawdź ustawienia i edycję bazowego przepisu.','270 g na wejściu, 360 g dla 4; gotowanie używa 4; preferencja nadal 3; baza 180 g / 2.','Zrzuty wszystkich wartości'),
('Preferencje i szkic','Domyślne 3.','W Dodaj wpisz tytuł. Zmień preferencję na 4. Wróć do szkicu, następnie Wyczyść i potwierdź.','Szkic zachowuje 3 oraz tytuł; nowy czysty formularz zaczyna od 4.','Nagranie'),
('Wyszukiwanie i filtry','Przykładowe przepisy dostępne.','Szukaj losos cytryna. Następnie wyczyść, ustaw do 15 min, śniadania, dieta wegetariańska; sprawdź anulowanie i zatwierdzenie filtrów.','Pierwsze zapytanie zwraca łososia; filtry dają tost i owsiankę; anulowanie nie zmienia filtrów.','Zrzuty wyników'),
('Trwałość po restarcie','Utwórz Test ryżu, polub go i ustaw preferencję 4.','Zamknij proces aplikacji z przełącznika, uruchom ponownie.','Przepis, polubienie i preferencja zachowane. Nie testować na efemerycznej bazie UI-testów.','Nagranie restartu'),
('Pusta książka','Osobna testowa instalacja bez prywatnych danych.','Usuń wszystkie przepisy; uruchom ponownie; sprawdź Start, Szukaj, Ulubione.','Puste stany czytelne, przykłady nie wracają; dodanie nowego przepisu nadal działa.','Zrzut po restarcie'),
('Zdjęcie','Testowy przepis i zdjęcie w bibliotece.','Dodaj zdjęcie; zapisz; uruchom ponownie; edytuj i usuń zdjęcie.','Zdjęcie poprawnie obrócone i trwałe; usunięcie daje placeholder.','Zrzuty'),
('Film wrapa','Wrap z kurczakiem, głośność słyszalna.','Obejrzyj film; odtwórz do końca, pauzuj, przewiń, wyjdź podczas odtwarzania i otwórz ponownie.','Widoczny obraz, prawidłowy dźwięk jeśli obecny w pliku; brak awarii; po wyjściu dźwięk nie trwa.','Nagranie i obserwacja dźwięku'),
('Audio wrapa','Wrap z kurczakiem, głośność słyszalna.','Instrukcja audio; odtwórz do końca, uruchom drugi raz, pauzuj i przewiń; zamknij odtwarzacz.','Słyszalna instrukcja, około 21,92 s; suwak i pauza działają; zamknięcie zatrzymuje audio.','Nagranie i obserwacja słuchowa'),
('Offline i aktualizacja','Dla migracji: wcześniejsza instalacja bez mediów i zapisane własne dane.','Zainstaluj nową wersję bez odinstalowania. Sprawdź wrap, własne przepisy; włącz tryb samolotowy i odtwórz oba media.','Dane zachowane; brakujące media uzupełnione; własne załączniki niezastąpione; materiały działają offline.','Zrzuty przed/po i nagranie offline'),
('Gotowanie','Otwarty przepis z kilkoma krokami.','Zaznacz składnik, zaznacz i odznacz krok, zakończ gotowanie i wróć do przepisu.','Znaczniki i licznik postępu zgodne; poprawny powrót po komunikacie.','Nagranie'),
('Układ i dostępność','Mały iPhone oraz iPad lub symulator; duży tekst; VoiceOver.','Otwórz listy i formularz, obróć ekran, wyświetl klawiaturę; przejdź po sercu, porcji i odtwarzaczu VoiceOver.','Brak zasłoniętych krytycznych kontrolek; treść przewijalna; etykiety i stany zrozumiałe.','Zrzuty z rozmiarami ekranów i notatka VoiceOver'),
('Tło i seria operacji','Zwykła instalacja testowa.','10 razy: otwórz przepis, zmień porcje, polub, wróć; dodaj i usuń testowy przepis. Przenieś aplikację do tła i wróć.','Brak awarii, duplikatów i utraty zapisanych danych; interfejs reaguje. To próba stabilności, nie benchmark.','Nagranie i ewentualne logi awarii'),
('Przepis dnia','Przykłady w bazie; znany przepis dnia.','Zanotuj wybór; uruchom ponownie tego samego dnia; usuń ten przepis i sprawdź Start.','Wybór stabilny tego samego dnia; po usunięciu wskazuje dostępny przepis. Przejście przez północ wymaga oddzielnej obserwacji.','Zrzuty z datą i godziną')]
manual=[dict(id=f'M{i+1:02}',title=c[0],preconditions=c[1],steps=c[2],expected=c[3],evidence=c[4],status='NIEWYKONANY',actual='Brak uruchomienia na iOS.',tester='',date='',device='') for i,c in enumerate(cases)]
results={'environment':environment,'checks':checks,'automated':tests,'manual':manual}
write('wyniki.json',json.dumps(results,ensure_ascii=False,indent=2))
with (OUT/'przypadki-reczne.csv').open('w',encoding='utf-8-sig',newline='') as f:
    writer=csv.DictWriter(f,fieldnames=list(manual[0]),delimiter=';'); writer.writeheader(); writer.writerows(manual)

pdfmetrics.registerFont(TTFont('Arial',r'C:\Windows\Fonts\arial.ttf'))
pdfmetrics.registerFont(TTFont('Arial-Bold',r'C:\Windows\Fonts\arialbd.ttf'))
pdfmetrics.registerFontFamily('Arial',normal='Arial',bold='Arial-Bold',italic='Arial',boldItalic='Arial-Bold')
styles=getSampleStyleSheet()
for key in ['Normal','BodyText','Heading1','Heading2','Heading3','Title']:
    styles[key].fontName='Arial-Bold' if key.startswith('Heading') or key=='Title' else 'Arial'
styles['Normal'].fontSize=9; styles['Normal'].leading=13
styles['Heading1'].fontSize=19; styles['Heading1'].leading=24; styles['Heading1'].textColor=colors.HexColor('#235B46')
styles['Heading2'].fontSize=12; styles['Heading2'].leading=16
styles.add(ParagraphStyle(name='SmallCell',fontName='Arial',fontSize=8,leading=11))
story=[]
def p(text,style='Normal'): return Paragraph(escape(str(text)).replace('\n','<br/>'),styles[style])
def add(text,style='Normal'): story.extend([p(text,style),Spacer(1,5)])
def page(title):
    if story: story.append(PageBreak())
    add(title,'Heading1')
def table(rows,widths):
    t=Table([[p(x,'SmallCell') for x in row] for row in rows],colWidths=widths,repeatRows=1,hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#DDECE4')),('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),0.3,colors.HexColor('#CBD5CE')),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('TOPPADDING',(0,0),(-1,-1),5),('BOTTOMPADDING',(0,0),(-1,-1),5)]))
    story.append(t)
page('CookBook | Raport testów - etap 3')
add('Raport częściowy z wykonanych kontroli oraz kompletny protokół testów do uruchomienia na iOS.','Heading2')
add('Data wykonania: '+stamp)
add('Status odbioru: WSTRZYMANY - brak wyników kompilacji, XCTest i prób na urządzeniu.','Heading2')
add(f"Wykonano {len(checks)} kontroli na Windows: {sum(c['status']=='PASS' for c in checks)} PASS, {sum(c['status']=='FAIL' for c in checks)} FAIL. Przygotowano 33 testy XCTest oraz 20 scenariuszy ręcznych; ich status to NIEWYKONANY. Nie obliczano procentu pokrycia kodu.")
add('1. Cel i podstawa','Heading2')
add('Sprawdzić logikę porcji, ulubione, trwałość danych, formularze, multimedia i interfejs po scaleniu projektu. Dokument kursu wymaga opisu przeprowadzonych testów oraz uzyskanych wyników, a także uruchomienia projektu na urządzeniu iOS. Nie podaje liczby testów ani progu pokrycia. Zestaw poniżej jest planem technicznym zespołu.')
add('Źródło wymagań: Aplikacje_mobilne_na_platformę_iOS_2026a (1).pdf, strony 1-2, dostarczony przez użytkownika. Raport nie zawiera wyników, których nie zaobserwowano.')
add('2. Środowisko i wersja','Heading2')
add(environment['os']+'; Python '+platform.python_version())
add('Źródła: '+str(desktop))
add('Wersję określa manifest SHA-256 źródeł, zasobów i testów. Identyfikator zestawu: '+revision)
add('Brak xcodebuild i kompilatora Swift w PATH. Brak dostępnego urządzenia iOS lub zdalnego Maca w zadaniu. Testów nie zastępowano przepisaniem logiki Swift na Python.')
add('3. Znaczenie statusów','Heading2')
add('PASS: określona kontrola została wykonana i spełniła kryterium. FAIL: wykonana kontrola nie spełniła kryterium. NIEWYKONANY: brak wykonania; nie jest ani sukcesem, ani wykrytym błędem aplikacji. Poprawna składnia nie oznacza poprawnej kompilacji lub działania.')
page('Wykonane kontrole i dowody')
for c in checks:
    add(c['id']+' | '+c['title']+' | '+c['status'],'Heading2'); add(c['actual']); add('Dowód: '+c['evidence'])
add('Narzędzie multimedialne: '+version)
add('Dekodowanie odbyło się lokalnie do wyjścia null, bez modyfikowania plików. Nie jest dowodem działania AVPlayer/AVAudioPlayer, synchronizacji obrazu z dźwiękiem ani zgodności treści nagrań z recepturą.')
page('Testy automatyczne | logika')
add('Target CookBookTests, plik RecipeLogicTests.swift. Wszystkie poniższe przypadki: NIEWYKONANY. Oczekiwane zachowanie jest zapisane jako asercje XCTest; dowodem wykonania będzie .xcresult.')
table([['ID / metoda','Cel i oczekiwany wynik']]+[[t['id']+'\n'+t['method'],t['title']] for t in tests[:16]],[88*mm,86*mm])
page('Testy automatyczne | baza i UI')
add('A17-A29: RecipePersistenceTests.swift (CookBookTests). A30-A33: RecipeFlowUITests.swift (CookBookUITests). Status każdego: NIEWYKONANY; przyczyna: brak Xcode/SDK iOS.')
table([['ID / metoda','Cel i oczekiwany wynik']]+[[t['id']+'\n'+t['method'],t['title']] for t in tests[16:]],[88*mm,86*mm])
for start in range(0,20,4):
    page(f'Scenariusze ręczne | {start+1}-{start+4}')
    add('Wynik rzeczywisty każdego przypadku: NIEWYKONANY (brak iOS). Formularz do wpisania wyników: przypadki-reczne.csv. Wykonujący uzupełnia datę, urządzenie, wynik i ścieżkę dowodu.')
    for c in manual[start:start+4]:
        group=[p(c['id']+' | '+c['title'],'Heading2')]
        for label,key in [('Warunki','preconditions'),('Kroki','steps'),('Oczekiwane','expected'),('Dowód','evidence')]: group.append(p(label+': '+c[key]))
        group.append(Spacer(1,12)); story.append(KeepTogether(group))
page('Pokrycie wymagań i ograniczenia')
table([['Wymaganie / ryzyko','Dowód dostępny','Do wykonania'],['15 zdjęć','S02: odczyt i unikatowe SHA-256','M18: prezentacja w UI'],['Film i audio','S03-S06: dekodowanie, PCM, kopie','M14-M16: odtwarzanie na iOS'],['Animacja','Kod i scenariusze A30, M06-M07','Ocena wizualna i Ogranicz ruch'],['Porcje i formularz','A01-A12, A31-A33 przygotowane','Cmd+U; M01-M04, M08-M09'],['Baza i integracja','A17-A29 przygotowane','Cmd+U; M04-M05, M11-M12, M16'],['Urządzenie fizyczne','Brak','Uruchomienie i scenariusze na iPhonie/iPadzie'],['Raport wyników','Ten PDF, wyniki.json, logi','Uzupełnienie rzeczywistych wyników z Maca']],[48*mm,63*mm,63*mm])
add('Zidentyfikowane problemy i retesty','Heading2')
add('W poprzednim audycie poprawiono m.in. nadpisywanie preferencji porcjami bieżącymi, zastępowanie całego przepisu przy edycji oraz przywracanie przykładów po wyczyszczeniu bazy. To historia przeglądu kodu, nie lista awarii odtworzonych na urządzeniu. Retesty przypisane: A31/M08, A21/M04, A25/M12. Ich wyniki pozostają niewykonane.')
add('Wcześniejszy plik nazwany WAV zawierał HTML. Zastąpiono go poprawnym plikiem użytkownika. Obecny retest danych i dekodowania: S04-S06 PASS. Retest w odtwarzaczu aplikacji: M15 niewykonany.')
add('Nie wykonano pomiarów wydajności i zużycia pamięci, testów długotrwałych, pełnego audytu dostępności ani audytu bezpieczeństwa. M19 jest próbą stabilności, nie pomiarem szybkości. Nie ustalono zgodności z innymi wersjami iOS; projekt deklaruje target 27.0.')
page('Wykonanie na Macu i zamknięcie etapu')
add('Procedura','Heading2')
for line in ['1. Przenieś cały projekt na Maca. Otwórz CookBook.xcodeproj, wybierz schemat CookBook i symulator zgodny z targetem iOS 27.0. Zapisz wersję Xcode i iOS.', '2. Wykonaj Cmd+B, następnie Cmd+U. Zachowaj wynik każdego testu, także pominiętego. Użyj skryptu: bash Scripts/verify_on_mac.sh UDID_SYMULATORA.', '3. Skrypt zapisuje wersję Xcode, tests.log, Tests.xcresult i buduje Release dla symulatora. Brak błędów parsera z Windows nie zastępuje tego kroku.', '4. Uruchom normalną aplikację na fizycznym urządzeniu, z własnym Team do podpisu. Wykonaj M01-M20. Testy trwałości rób poza izolowanym trybem UI_TESTING.', '5. Dla M16 użyj wcześniejszej wersji na osobnej instalacji testowej; aktualizuj bez usuwania bazy. Nie usuwaj prywatnych danych przy M12.', '6. Wpisz wyniki do CSV, dołącz zrzuty/nagrania z nazwami Mxx_data. Błędy opisz: środowisko, kroki, oczekiwane/rzeczywiste, dowód, poprawka i retest.', '7. Zaktualizuj raport wynikami i identyfikatorem testowanej wersji. Po zmianie kodu powtórz test obszaru i zależne regresje.']:
    add(line)
add('Kryteria proponowanego odbioru','Heading2')
add('Debug i Release budują się; 33 testy automatyczne wykonane z wyjaśnieniem każdego FAIL lub pominięcia; scenariusze krytyczne zapisu, porcji, ulubionych i mediów przechodzą na urządzeniu; brak błędów utraty danych i awarii blokujących; wyniki mają dowody. Nie jest to oficjalny próg prowadzącego.')
add('Demonstracja na zajęciach','Heading2')
add('Pokaż wynik XCTest i jeden test skalowania, następnie przepływ dodania/edycji, porcje i ulubione, restart aplikacji oraz film i audio. Wyjaśnij różnicę między testem jednostkowym, integracyjnym i UI oraz pokaż jeden rzeczywiście znaleziony błąd i jego retest.')
add('Wniosek','Heading2')
add('Dostępne kontrole plików i projektu zakończyły się zgodnie z tabelą wyników. Nie ma jeszcze podstaw do potwierdzenia pełnej poprawności aplikacji ani zakończenia etapu 3. Ten dokument jest rzetelnym raportem częściowym i protokołem dalszego wykonania, nie deklaracją zaliczenia testów iOS.')
def footer(c,doc):
    c.setFont('Arial',8); c.setFillColor(colors.HexColor('#587064'))
    c.drawString(18*mm,12*mm,'CookBook | etap 3 | raport częściowy | 21.11.2026')
    c.drawRightString(192*mm,12*mm,str(doc.page))
doc=SimpleDocTemplate(str(OUT/'Raport_testow_CookBook.pdf'),pagesize=(210*mm,297*mm),leftMargin=18*mm,rightMargin=18*mm,topMargin=17*mm,bottomMargin=20*mm,title='CookBook - raport testów etapu 3',author='Dokumentacja projektu CookBook')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print(json.dumps({'checks':checks,'automated_pending':len(tests),'manual_pending':len(manual),'pdf':str(OUT/'Raport_testow_CookBook.pdf')},ensure_ascii=False,indent=2))
