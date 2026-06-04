### 1. Struktura Tabel (Podział na 4 Moduły)

**PK** = Primary Key (Klucz główny - unikalny identyfikator, np. 1, 2, 3...)

**FK** = Foreign Key (Klucz obcy - odwołanie do innej tabeli)

**Osoba 1: Moduł Użytkowników**

- `Role`

  - `ID_Roli` (PK)

  - `Nazwa_Roli` (np. Admin, Uzytkownik)

- `Uzytkownicy`

  - `ID_Uzytkownika` (PK)

  - `Login`, `Haslo`, `Email`, `Data_Rejestracji`

  - `ID_Roli` (FK -> odwołuje się do tabeli Role)

**Osoba 2: Moduł Katalogu Książek**

- `Autorzy` (`ID_Autora` PK, `Imie`, `Nazwisko`)

- `Wydawnictwa` (`ID_Wydawnictwa` PK, `Nazwa`)

- `Kategorie` (`ID_Kategorii` PK, `Nazwa`)

- `Ksiazki`

  - `ID_Ksiazki` (PK)

  - `Tytul`, `ISBN`, `Rok_Wydania`

  - `ID_Autora` (FK -> Autorzy)

  - `ID_Wydawnictwa` (FK -> Wydawnictwa)

  - `ID_Kategorii` (FK -> Kategorie)

**Osoba 3: Moduł Ofert i Transakcji**

- `Statusy_Ofert` (`ID_Statusu` PK, `Nazwa` np. Dostępna, Wymieniona)

- `Oferty_Uzytkownikow` (Fizyczne egzemplarze, które ktoś chce oddać)

  - `ID_Oferty` (PK)

  - `Opis_Stanu` (np. "lekko zagięte rogi")

  - `ID_Uzytkownika` (FK -> Uzytkownicy)

  - `ID_Ksiazki` (FK -> Ksiazki)

  - `ID_Statusu` (FK -> Statusy_Ofert)

- `Transakcje` (Właściwa wymiana)

  - `ID_Transakcji` (PK)

  - `Data_Wymiany`, `Status_Transakcji` (np. Zrealizowana, W toku)

  - `ID_Oferty_Od` (FK -> Oferty_Uzytkownikow) - co ktoś daje

  - `ID_Oferty_Za` (FK -> Oferty_Uzytkownikow) - co chce w zamian

**Osoba 4: Moduł Społecznościowy (Oceny)**

- `Oceny_Transakcji`

  - `ID_Oceny` (PK)

  - `Wartosc` (1-5), `Komentarz`

  - `ID_Transakcji` (FK -> Transakcje)

  - `ID_Oceniajacego` (FK -> Uzytkownicy)

- `Recenzje_Ksiazek`

  - `ID_Recenzji` (PK)

  - `Wartosc` (1-10), `Tresc`

  - `ID_Ksiazki` (FK -> Ksiazki)

  - `ID_Uzytkownika` (FK -> Uzytkownicy)

### 2. Poziomy Tworzenia (Kolejność wykonywania skryptów)

Kiedy będziecie łączyć kod w jeden plik, musicie go odpalić dokładnie w tej kolejności, inaczej baza wywali błąd braku klucza obcego.

- **Poziom 0 (Słowniki - brak kluczy obcych):** `Role`, `Autorzy`, `Wydawnictwa`, `Kategorie`, `Statusy_Ofert`. _(Tworzą: Osoba 1, 2 i 3)_

- **Poziom 1 (Zależą od Poziomu 0):** `Uzytkownicy`, `Ksiazki`. _(Tworzą: Osoba 1 i 2)_

- **Poziom 2 (Zależą od Poziomu 1):** `Oferty_Uzytkownikow`. _(Tworzy: Osoba 3)_

- **Poziom 3 (Zależą od Poziomu 2):** `Transakcje`, `Recenzje_Ksiazek`. _(Tworzą: Osoba 3 i 4)_

- **Poziom 4 (Zależą od Poziomu 3):** `Oceny_Transakcji`. _(Tworzy: Osoba 4)_

### 3. Zadaniowy Plan Pracy (Fazy 1 - 3)

Zgodnie z wymogami projektu, każda faza dodaje nowe mechanizmy. Podział pracy na osoby:

#### Faza 1: Ocena 3.0 (Struktura, Podstawy i Wypełnienie Danymi)

Każdy pracuje na swoich tabelach. Cel to stworzenie schematu i udowodnienie, że działa.

- **Osoba 1:** Pisze kod `CREATE TABLE` dla `Role` i `Uzytkownicy`. Następnie pisze zapytania `INSERT INTO`, dodając 2 role i 5 użytkowników.

- **Osoba 2:** Pisze `CREATE TABLE` dla `Autorzy`, `Wydawnictwa`, `Kategorie`, `Ksiazki`. Wypełnia je danymi (np. 10 książek, 5 autorów).

- **Osoba 3:** Pisze `CREATE TABLE` dla `Statusy_Ofert`, `Oferty_Uzytkownikow` i `Transakcje`. Dodaje kilka statusów, wystawia 10 ofert z przypisaniem do użytkowników i książek, oraz tworzy 3 testowe wymiany.

- **Osoba 4:** Pisze `CREATE TABLE` dla `Oceny_Transakcji` i `Recenzje_Ksiazek`. Wrzuca testowe komentarze i oceny do stworzonych już transakcji i książek. Pisze "Prostą dokumentację użytkową" (krótki opis, co baza robi).

#### Faza 2: Ocena 3.5 - 4.0 (Widoki, Zaawansowany SQL i Wyzwalacze)

Ożywiamy bazę. Wymagane są procedury/wyzwalacze (Triggery) i zaawansowane zapytania (np. `JOIN`, `GROUP BY`).

- **Osoba 1 (SQL + Trigger):** * Tworzy zapytanie: Wyświetla użytkowników wraz z łączną liczbą ofert, które wystawili (`JOIN`, `GROUP BY`, `COUNT`).

  - Pisze Wyzwalacz (`TRIGGER`): Przed dodaniem nowego użytkownika do bazy sprawdza, czy email zawiera znak `@`. Jeśli nie, odrzuca operację.

- **Osoba 2 (Widok + Trigger):**

  - Tworzy Widok (`VIEW`): `Widok_Pelny_Katalog` – łączy tabele Książki, Autorzy, Wydawnictwa i Kategorie, aby pokazać wszystko w jednej ładnej tabeli (bez numerów ID, same nazwy).

  - Pisze Wyzwalacz (`TRIGGER`): Przy dodawaniu nowej książki automatycznie zamienia wszystkie litery tytułu na wielkie (UPPER).

- **Osoba 3 (Zagnieżdżenie + Trigger):**

  - Tworzy zapytanie zagnieżdżone: Szuka użytkowników, którzy mają wystawione oferty, ale _nie brali udziału w żadnej transakcji_ (użycie `NOT IN` lub `NOT EXISTS`).

  - Pisze Wyzwalacz (`TRIGGER`): Po dodaniu nowej `Transakcji`, automatycznie aktualizuje `Status` powiązanych `Ofert` na "Wymieniona".

- **Osoba 4 (Widok + Dokumentacja):**

  - Tworzy Widok (`VIEW`): `Ranking_Uzytkownikow` – wylicza średnią ocenę każdego użytkownika na podstawie Tabeli `Oceny_Transakcji`.

  - Rysuje diagram ERD (Entity-Relationship Diagram) dla całej Waszej bazy i scala skrypty wszystkich osób do dokumentacji technicznej.

#### Faza 3: Ocena 4.5 (Transakcje, Izolacja i Uprawnienia)

Baza staje się w 100% profesjonalna i odporna na usterki systemowe.

- **Osoba 1 (Bezpieczeństwo):** Realizuje wymóg "Uwzględnienie bezpieczeństwa danych". Za pomocą poleceń SQL tworzy użytkownika systemowego `Aplikacja_Konto` i nadaje mu uprawnienia `GRANT SELECT, INSERT, UPDATE` na wszystkich tabelach, ale np. zabrania używania `DELETE` (aby aplikacja nie mogła fizycznie usunąć danych z bazy).

- **Osoba 2 (Transakcje SQL):** Realizuje wymóg "Wykorzystanie mechanizmów transakcyjnych". Pisze skrypt z blokiem `BEGIN TRANSACTION ... COMMIT/ROLLBACK`, który pozwala na dodanie nowego Autora i od razu nowej Książki w jednym bloku. Jeśli dodanie książki z jakiegoś powodu się nie uda, wycofuje również dodanie Autora.

- **Osoba 3 (Poziomy Izolacji):** Ustawia na swoim bloku transakcyjnym odpowiedni poziom izolacji (np. `SET TRANSACTION ISOLATION LEVEL SERIALIZABLE`). Robi to po to, aby przy procesie akceptacji wymiany przez dwóch użytkowników w tym samym ułamku sekundy, baza wymusiła zrobienie tego po kolei, zapobiegając nadpisaniu danych.

- **Osoba 4 (Weryfikacja 3NF i Dokumentacja):** Przeprowadza oficjalny "audyt" bazy w dokumentacji, opisując krótko dla prowadzącego, dlaczego baza spełnia wymogi 3 postaci normalnej (3NF) - np. "Nie przechowujemy imion autorów w tabeli Książki, żeby uniknąć redundancji" i wysyła paczkę do prowadzącego.
