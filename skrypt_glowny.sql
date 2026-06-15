-- ====================================================================
-- PLATFORMA WYMIANY KSIĄŻEK - SKRYPT MASTER (FAZY 1, 2 I 3)
-- Zintegrowany, zoptymalizowany i oczyszczony z duplikatów
-- Silnik bazy danych: PostgreSQL (psql)
-- ====================================================================

-- --------------------------------------------------------------------
-- 0. CZYSZCZENIE BAZY DANYCH (KULOODPORNE RESETOWANIE STRUKTURY)
-- --------------------------------------------------------------------
DROP VIEW IF EXISTS Ranking_Ksiazek CASCADE;
DROP VIEW IF EXISTS v_Ksiazki_Szczegoly CASCADE;
DROP VIEW IF EXISTS v_Autorzy_Statystyki CASCADE;
DROP VIEW IF EXISTS v_Kategorie_Statystyki CASCADE;
DROP VIEW IF EXISTS Statystyki_Statusow_Ofert CASCADE;
DROP VIEW IF EXISTS Rejestr_Aktywnych_Transakcji CASCADE;
DROP VIEW IF EXISTS Widok_Zaangazowanie_Ofert CASCADE;
DROP VIEW IF EXISTS Widok_Pelne_Oferty CASCADE;
DROP VIEW IF EXISTS Widok_Pelne_Transakcje CASCADE;
DROP VIEW IF EXISTS Widok_Oferty_W_Toku CASCADE;
DROP VIEW IF EXISTS Widok_Najnowsza_Transakcja CASCADE;

DROP TABLE IF EXISTS Oceny_Transakcji CASCADE;
DROP TABLE IF EXISTS Recenzje_Ksiazek CASCADE;
DROP TABLE IF EXISTS Transakcje CASCADE;
DROP TABLE IF EXISTS Oferty_Uzytkownikow CASCADE;
DROP TABLE IF EXISTS Ksiazki CASCADE;
DROP TABLE IF EXISTS Uzytkownicy CASCADE;
DROP TABLE IF EXISTS Statusy_Ofert CASCADE;
DROP TABLE IF EXISTS Kategorie CASCADE;
DROP TABLE IF EXISTS Wydawnictwa CASCADE;
DROP TABLE IF EXISTS Autorzy CASCADE;
DROP TABLE IF EXISTS Role CASCADE;

-- ====================================================================
-- FAZA 1: STRUKTURA TABEL (DDL) I DANE INICJALNE (DML)
-- Hierarchia zachowana według poziomów zależności kluczy obcych
-- ====================================================================

-- POZIOM 0: Słowniki (Brak kluczy obcych)
CREATE TABLE Role (
    ID_Roli SERIAL PRIMARY KEY,
    Nazwa_Roli VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Autorzy (
    ID_Autora SERIAL PRIMARY KEY,
    Imie VARCHAR(100) NOT NULL,
    Nazwisko VARCHAR(100) NOT NULL
);

CREATE TABLE Wydawnictwa (
    ID_Wydawnictwa SERIAL PRIMARY KEY,
    Nazwa VARCHAR(200) NOT NULL
);

CREATE TABLE Kategorie (
    ID_Kategorii SERIAL PRIMARY KEY,
    Nazwa VARCHAR(100) NOT NULL
);

CREATE TABLE Statusy_Ofert (
    ID_Statusu SERIAL PRIMARY KEY,
    Nazwa VARCHAR(50) NOT NULL UNIQUE
);

-- POZIOM 1: Tabele zależne bezpośrednio od Poziomu 0
CREATE TABLE Uzytkownicy (
    ID_Uzytkownika SERIAL PRIMARY KEY,
    Login VARCHAR(50) NOT NULL UNIQUE,
    Haslo VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Data_Rejestracji TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ID_Roli INTEGER NOT NULL,
    CONSTRAINT fk_uzytkownicy_role FOREIGN KEY (ID_Roli) REFERENCES Role(ID_Roli)
);

CREATE TABLE Ksiazki (
    ID_Ksiazki SERIAL PRIMARY KEY,
    Tytul VARCHAR(300) NOT NULL,
    ISBN VARCHAR(17) UNIQUE,
    Rok_Wydania SMALLINT CHECK (Rok_Wydania BETWEEN 1000 AND 2100),
    ID_Autora INT NOT NULL REFERENCES Autorzy(ID_Autora) ON UPDATE CASCADE ON DELETE RESTRICT,
    ID_Wydawnictwa INT NOT NULL REFERENCES Wydawnictwa(ID_Wydawnictwa) ON UPDATE CASCADE ON DELETE RESTRICT,
    ID_Kategorii INT NOT NULL REFERENCES Kategorie(ID_Kategorii) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- POZIOM 2: Operacyjne tabele ofert użytkowników
CREATE TABLE Oferty_Uzytkownikow (
    ID_Oferty SERIAL PRIMARY KEY,
    Opis_Stanu VARCHAR(255),
    ID_Uzytkownika INTEGER NOT NULL,
    ID_Ksiazki INTEGER NOT NULL,
    ID_Statusu INTEGER NOT NULL,
    CONSTRAINT fk_oferty_uzytkownicy FOREIGN KEY (ID_Uzytkownika) REFERENCES Uzytkownicy(ID_Uzytkownika) ON DELETE CASCADE,
    CONSTRAINT fk_oferty_ksiazki FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazki(ID_Ksiazki) ON DELETE RESTRICT,
    CONSTRAINT fk_oferty_statusy FOREIGN KEY (ID_Statusu) REFERENCES Statusy_Ofert(ID_Statusu)
);

-- POZIOM 3: Transakcje wymiany oraz recenzje literackie
CREATE TABLE Transakcje (
    ID_Transakcji SERIAL PRIMARY KEY,
    Data_Wymiany TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status_Transakcji VARCHAR(50) NOT NULL,
    ID_Oferty_Od INTEGER NOT NULL,
    ID_Oferty_Za INTEGER NOT NULL,
    CONSTRAINT fk_transakcje_oferty_od FOREIGN KEY (ID_Oferty_Od) REFERENCES Oferty_Uzytkownikow(ID_Oferty) ON DELETE CASCADE,
    CONSTRAINT fk_transakcje_oferty_za FOREIGN KEY (ID_Oferty_Za) REFERENCES Oferty_Uzytkownikow(ID_Oferty) ON DELETE CASCADE
);

CREATE TABLE Recenzje_Ksiazek (
    ID_Recenzji SERIAL PRIMARY KEY,
    Wartosc INT NOT NULL CHECK (Wartosc >= 1 AND Wartosc <= 10),
    Tresc TEXT,
    Data_Dodania TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ID_Ksiazki INT NOT NULL,
    ID_Uzytkownika INT NOT NULL,
    FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazki(ID_Ksiazki) ON DELETE CASCADE,
    FOREIGN KEY (ID_Uzytkownika) REFERENCES Uzytkownicy(ID_Uzytkownika) ON DELETE CASCADE
);

-- POZIOM 4: Oceny sfinalizowanych transakcji barterowych
CREATE TABLE Oceny_Transakcji (
    ID_Oceny SERIAL PRIMARY KEY,
    Wartosc INT NOT NULL CHECK (Wartosc >= 1 AND Wartosc <= 5),
    Komentarz TEXT,
    Data_Dodania TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ID_Transakcji INT NOT NULL,
    ID_Oceniajacego INT NOT NULL,
    FOREIGN KEY (ID_Transakcji) REFERENCES Transakcje(ID_Transakcji) ON DELETE CASCADE,
    FOREIGN KEY (ID_Oceniajacego) REFERENCES Uzytkownicy(ID_Uzytkownika) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- ZASILANIE BAZY DANYCH (WSTAWIANIE REKORDÓW TESTOWYCH)
-- --------------------------------------------------------------------
-- Wpisywanie danych do słowników
INSERT INTO Role (Nazwa_Roli) VALUES ('Admin'), ('Uzytkownik');
INSERT INTO Statusy_Ofert (Nazwa) VALUES ('Dostępna'), ('W trakcie wymiany'), ('Wymieniona');

INSERT INTO Autorzy (Imie, Nazwisko) VALUES 
('Andrzej', 'Sapkowski'), ('Henryk', 'Sienkiewicz'), ('Adam', 'Mickiewicz'),
('J.R.R.', 'Tolkien'), ('George', 'Orwell'), ('Stephen', 'King'),
('Joanne', 'Rowling'), ('Stanisław', 'Lem'), ('Bolesław', 'Prus'), ('Paulo', 'Coelho');

INSERT INTO Wydawnictwa (Nazwa) VALUES 
('SuperNOWA'), ('PWN'), ('Znak'), ('Prószyński i S-ka'), ('Albatros'),
('Rebis'), ('Media Rodzina'), ('Czytelnik'), ('Iskry'), ('Muza');

INSERT INTO Kategorie (Nazwa) VALUES 
('Fantastyka'), ('Powieść historyczna'), ('Poezja'), ('Fantasy'), ('Dystopia'),
('Horror'), ('Literatura młodzieżowa'), ('Science Fiction'), ('Klasyka'), ('Literatura obyczajowa');

-- Wpisywanie użytkowników
INSERT INTO Uzytkownicy (Login, Haslo, Email, ID_Roli) VALUES
('ksiazkowymol1', 'haslo123', 'ksiazkowyMol1@wp.pl', 2),
('KasiaKsiążkowa', 'Reksio123!', 'kasiak@gmail.com', 2),
('Fantastic_lover', 'TrudneHaslo987', 'lover@gmail.com', 2),
('Bookworm123', 'Haslo456', 'bookworm123@gmail.com', 2),
('admin', 'RootPassword2026', 'tomek.admin@gmail.com', 1);

-- Wpisywanie katalogu książek
INSERT INTO Ksiazki (Tytul, ISBN, Rok_Wydania, ID_Autora, ID_Wydawnictwa, ID_Kategorii) VALUES
('Ostatnie życzenie', '978-83-7578-063-5', 1993, 1, 1, 1),
('Quo Vadis', '978-83-240-1234-5', 1896, 2, 2, 2),
('Pan Tadeusz', '978-83-111-1111-1', 1834, 3, 3, 3),
('Władca Pierścieni', '978-83-222-2222-2', 1954, 4, 4, 4),
('Rok 1984', '978-83-333-3333-3', 1949, 5, 5, 5),
('Lśnienie', '978-83-444-4444-4', 1977, 6, 6, 6),
('Harry Potter i Kamień Filozoficzny', '978-83-555-5555-5', 1997, 7, 7, 7),
('Solaris', '978-83-666-6666-6', 1961, 8, 8, 8),
('Lalka', '978-83-777-7777-7', 1890, 9, 9, 9),
('Alchemik', '978-83-888-8888-8', 1988, 10, 10, 10);

-- Wystawianie ofert fizycznych egzemplarzy książek
INSERT INTO Oferty_Uzytkownikow (Opis_Stanu, ID_Uzytkownika, ID_Ksiazki, ID_Statusu) VALUES
('Lekko zagięte rogi', 1, 1, 1),
('Stan idealny', 2, 2, 1),
('Ślady czytania', 3, 3, 1),
('Nowa, nieczytana', 4, 4, 1),
('Zalana kawą, ale da się czytać', 5, 5, 1),
('Raz przeczytana', 1, 6, 1),
('Stan bardzo dobry', 2, 7, 1),
('Brak obwoluty', 3, 8, 1),
('Drobne rysy na okładce', 4, 9, 1),
('Z dedykacją', 5, 10, 1);

-- Rejestracja początkowych transakcji (Uwaga: statusy ofert zaktualizują się za sprawą triggera AFTER INSERT)
INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za) VALUES
('Zrealizowana', 1, 2),
('W toku', 3, 4),
('Zrealizowana', 5, 6);

-- Dodawanie recenzji oraz ocen transakcji
INSERT INTO Recenzje_Ksiazek (Wartosc, Tresc, ID_Ksiazki, ID_Uzytkownika) VALUES
(9, 'Niesamowita książka, polecam wszystkim fanom gatunku!', 1, 2),
(5, 'Całkiem średnia, spodziewałem się czegoś lepszego.', 2, 1);

INSERT INTO Oceny_Transakcji (Wartosc, Komentarz, ID_Transakcji, ID_Oceniajacego) VALUES
(5, 'Szybka i bezproblemowa wymiana. Książka w idealnym stanie.', 1, 2),
(4, 'Wymiana udana, chociaż musieliśmy chwilę poczekać.', 2, 1);


-- ====================================================================
-- FAZA 2: ZAAWANSOWANY SQL - WIDOKI ANALITYCZNE I INTEGRACYJNE
-- ====================================================================

-- 1. KACPER: Widok rankingu ocenianych książek
CREATE VIEW Ranking_Ksiazek AS
SELECT 
    k.Tytul, 
    a.Nazwisko AS Autor, 
    ROUND(AVG(r.Wartosc), 2) AS Srednia_Ocena, 
    COUNT(r.ID_Recenzji) AS Liczba_Glosow
FROM Ksiazki k
JOIN Autorzy a ON k.ID_Autora = a.ID_Autora
JOIN Recenzje_Ksiazek r ON k.ID_Ksiazki = r.ID_Ksiazki
GROUP BY k.Tytul, a.Nazwisko 
ORDER BY Srednia_Ocena DESC;

-- 2. AGATA: Widok szczegółów pełnego katalogu (bez identyfikatorów cyfrowych)
CREATE VIEW v_Ksiazki_Szczegoly AS
SELECT 
    k.ID_Ksiazki, k.Tytul, k.ISBN, k.Rok_Wydania, 
    a.Imie || ' ' || a.Nazwisko AS Autor, 
    w.Nazwa AS Wydawnictwo, 
    kat.Nazwa AS Kategoria
FROM Ksiazki k 
JOIN Autorzy a ON k.ID_Autora = a.ID_Autora 
JOIN Wydawnictwa w ON k.ID_Wydawnictwa = w.ID_Wydawnictwa 
JOIN Kategorie kat ON k.ID_Kategorii = kat.ID_Kategorii;

-- 3. AGATA: Widoki statystyczne dla autorów i kategorii
CREATE VIEW v_Autorzy_Statystyki AS
SELECT a.ID_Autora, a.Imie, a.Nazwisko, COUNT(k.ID_Ksiazki) AS Liczba_Ksiazek
FROM Autorzy a LEFT JOIN Ksiazki k ON a.ID_Autora = k.ID_Autora
GROUP BY a.ID_Autora, a.Imie, a.Nazwisko;

CREATE VIEW v_Kategorie_Statystyki AS
SELECT kat.ID_Kategorii, kat.Nazwa, COUNT(k.ID_Ksiazki) AS Liczba_Ksiazek
FROM Kategorie kat LEFT JOIN Ksiazki k ON kat.ID_Kategorii = k.ID_Kategorii
GROUP BY kat.ID_Kategorii, kat.Nazwa;

-- 4. DAMIAN: Widoki modułu ofert i transakcji
CREATE VIEW Statystyki_Statusow_Ofert AS
SELECT s.Nazwa AS Status_Oferty, COUNT(o.ID_Oferty) AS Liczba_Przypisanych_Ofert
FROM Statusy_Ofert s LEFT JOIN Oferty_Uzytkownikow o ON s.ID_Statusu = o.ID_Statusu
GROUP BY s.ID_Statusu, s.Nazwa ORDER BY Liczba_Przypisanych_Ofert DESC;

CREATE VIEW Rejestr_Aktywnych_Transakcji AS
SELECT ID_Transakcji, Data_Wymiany, Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za
FROM Transakcje WHERE Status_Transakcji = 'W toku' ORDER BY Data_Wymiany ASC;

CREATE VIEW Widok_Zaangazowanie_Ofert AS
SELECT o.ID_Oferty, o.ID_Uzytkownika, o.Opis_Stanu,
    (SELECT COUNT(*) FROM Transakcje t WHERE t.ID_Oferty_Od = o.ID_Oferty OR t.ID_Oferty_Za = o.ID_Oferty) AS Liczba_Podejsc_Do_Wymiany
FROM Oferty_Uzytkownikow o ORDER BY Liczba_Podejsc_Do_Wymiany DESC;

-- 5. DAMIAN: Widoki ogólne (pełna integracja między modułami całego zespołu)
CREATE VIEW Widok_Pelne_Oferty AS
SELECT o.ID_Oferty, u.Login AS Uzytkownik_Proponujacy, k.Tytul AS Tytul_Ksiazki, o.Opis_Stanu AS Stan_Egzemplarza, s.Nazwa AS Status_Oferty
FROM Oferty_Uzytkownikow o
JOIN Uzytkownicy u ON o.ID_Uzytkownika = u.ID_Uzytkownika
JOIN Ksiazki k ON o.ID_Ksiazki = k.ID_Ksiazki
JOIN Statusy_Ofert s ON o.ID_Statusu = s.ID_Statusu;

CREATE VIEW Widok_Pelne_Transakcje AS
SELECT t.ID_Transakcji, t.Data_Wymiany, t.Status_Transakcji,
    u_od.Login AS Uzytkownik_Inicjujacy, k_od.Tytul AS Ksiazka_Oddawana,
    u_za.Login AS Uzytkownik_Akceptujacy, k_za.Tytul AS Ksiazka_Otrzymywana
FROM Transakcje t
JOIN Oferty_Uzytkownikow o_od ON t.ID_Oferty_Od = o_od.ID_Oferty
JOIN Uzytkownicy u_od ON o_od.ID_Uzytkownika = u_od.ID_Uzytkownika
JOIN Ksiazki k_od ON o_od.ID_Ksiazki = k_od.ID_Ksiazki
JOIN Oferty_Uzytkownikow o_za ON t.ID_Oferty_Za = o_za.ID_Oferty
JOIN Uzytkownicy u_za ON o_za.ID_Uzytkownika = u_za.ID_Uzytkownika
JOIN Ksiazki k_za ON o_za.ID_Ksiazki = k_za.ID_Ksiazki;

-- 6. DAMIAN: Widoki oparte na zapytaniach zagnieżdżonych i podzapytaniach
CREATE VIEW Widok_Oferty_W_Toku AS
SELECT ID_Oferty, Opis_Stanu, ID_Statusu FROM Oferty_Uzytkownikow
WHERE ID_Oferty IN (
    SELECT ID_Oferty_Od FROM Transakcje WHERE Status_Transakcji = 'W toku'
    UNION
    SELECT ID_Oferty_Za FROM Transakcje WHERE Status_Transakcji = 'W toku'
);

CREATE VIEW Widok_Najnowsza_Transakcja AS
SELECT ID_Transakcji, Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za, Data_Wymiany FROM Transakcje
WHERE Data_Wymiany = (SELECT MAX(Data_Wymiany) FROM Transakcje);


-- ====================================================================
-- FAZA 2: LOGIKA PROCEDURALNA - FUNKCJE I WYZWALACZE (PL/pgSQL)
-- ====================================================================

-- --- MODUŁ MARTYNY ---
-- Wyzwalacz 1: Sprawdzenie poprawności e-mail (obecność znaku @)
CREATE OR REPLACE FUNCTION sprawdzenie_poprawnosci_email() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Email NOT LIKE '%@%' THEN 
        RAISE EXCEPTION 'Błąd walidacji: Adres e-mail (%) musi zawierać znak @!', NEW.Email; 
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER weryfikacja_email_przed_zapisem
BEFORE INSERT OR UPDATE ON Uzytkownicy FOR EACH ROW EXECUTE FUNCTION sprawdzenie_poprawnosci_email();

-- Wyzwalacz 2: Ochrona przed usunięciem ostatniego administratora
CREATE OR REPLACE FUNCTION ochrona_ostatniego_admina() RETURNS TRIGGER AS $$
DECLARE
    id_roli_admin INTEGER;
    liczba_adminow INTEGER;
BEGIN
    SELECT ID_Roli INTO id_roli_admin FROM Role WHERE Nazwa_Roli = 'Admin';
    IF OLD.ID_Roli = id_roli_admin THEN
        SELECT COUNT(*) INTO liczba_adminow FROM Uzytkownicy WHERE ID_Roli = id_roli_admin;
        IF liczba_adminow <= 1 THEN 
            RAISE EXCEPTION 'Błąd: W bazie musi pozostać co najmniej jeden Administrator!'; 
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ochrona_ostatniego_admina_w_bazie
BEFORE DELETE ON Uzytkownicy FOR EACH ROW EXECUTE FUNCTION ochrona_ostatniego_admina();

-- Wyzwalacz 3: Domyślna rola użytkownika przy rejestracji
CREATE OR REPLACE FUNCTION ustawienie_domyslnej_roli() RETURNS TRIGGER AS $$
DECLARE id_roli_domyslnej INTEGER;
BEGIN
    IF NEW.ID_Roli IS NULL THEN
        SELECT ID_Roli INTO id_roli_domyslnej FROM Role WHERE Nazwa_Roli = 'Uzytkownik';
        NEW.ID_Roli := id_roli_domyslnej;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ustawienie_domyslnej_roli_uzytkownik
BEFORE INSERT ON Uzytkownicy FOR EACH ROW EXECUTE FUNCTION ustawienie_domyslnej_roli();

-- Wyzwalacz 4: Limit administratorów (maksymalnie 3 konta admina)
CREATE OR REPLACE FUNCTION limit_administratorow() RETURNS TRIGGER AS $$
DECLARE
    id_roli_admin INTEGER;
    liczba_adminow INTEGER;
BEGIN
    SELECT ID_Roli INTO id_roli_admin FROM Role WHERE Nazwa_Roli = 'Admin';
    IF NEW.ID_Roli = id_roli_admin THEN
        SELECT COUNT(*) INTO liczba_adminow FROM Uzytkownicy WHERE ID_Roli = id_roli_admin;
        IF liczba_adminow >= 3 THEN 
            RAISE EXCEPTION 'Odmowa: Osiągnięto maksymalny limit (3) administratorów w systemie.'; 
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ograniczenie_ilosci_adminow
BEFORE INSERT OR UPDATE ON Uzytkownicy FOR EACH ROW EXECUTE FUNCTION limit_administratorow();


-- --- MODUŁ AGATY ---
-- Funkcja 1: Liczba książek danego autora
CREATE OR REPLACE FUNCTION fn_Liczba_Ksiazek_Autora(p_id_autora INT) RETURNS INT AS $$
DECLARE v_liczba INT;
BEGIN
    SELECT COUNT(*) INTO v_liczba FROM Ksiazki WHERE ID_Autora = p_id_autora;
    RETURN v_liczba;
END;
$$ LANGUAGE plpgsql;

-- Wyzwalacz 5: Automatyczne uzupełnianie bieżącego roku wydania książki
CREATE OR REPLACE FUNCTION fn_Ustaw_Rok() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Rok_Wydania IS NULL THEN NEW.Rok_Wydania := EXTRACT(YEAR FROM CURRENT_DATE); END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_Ustaw_Rok
BEFORE INSERT ON Ksiazki FOR EACH ROW EXECUTE FUNCTION fn_Ustaw_Rok();

-- Wyzwalacz 6: Blokada usunięcia autora posiadającego powiązane pozycje książkowe
CREATE OR REPLACE FUNCTION fn_Blokuj_Usuniecie_Autora() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Ksiazki WHERE ID_Autora = OLD.ID_Autora) THEN
        RAISE EXCEPTION 'Nie można usunąć autora posiadającego książki w katalogu.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_Blokuj_Usuniecie_Autora
BEFORE DELETE ON Autorzy FOR EACH ROW EXECUTE FUNCTION fn_Blokuj_Usuniecie_Autora();

-- Wyzwalacz 7: Konwersja tytułów nowo wstawianych książek do wielkich liter (UPPER)
CREATE OR REPLACE FUNCTION fn_Upper_Tytul() RETURNS TRIGGER AS $$
BEGIN
    NEW.Tytul := UPPER(NEW.Tytul);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_Upper_Tytul
BEFORE INSERT ON Ksiazki FOR EACH ROW EXECUTE FUNCTION fn_Upper_Tytul();


-- --- MODUŁ DAMIAN ---
-- Wyzwalacz 8: Automatyczna zmiana statusu powiązanych ofert na "Wymieniona" po zapisie transakcji
CREATE OR REPLACE FUNCTION zaktualizuj_status_ofert() RETURNS TRIGGER AS $$
DECLARE v_id_statusu INTEGER;
BEGIN
    SELECT ID_Statusu INTO v_id_statusu FROM Statusy_Ofert WHERE Nazwa = 'Wymieniona';
    UPDATE Oferty_Uzytkownikow SET ID_Statusu = v_id_statusu WHERE ID_Oferty IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_po_dodaniu_transakcji
AFTER INSERT ON Transakcje FOR EACH ROW EXECUTE FUNCTION zaktualizuj_status_ofert();

-- Wyzwalacz 9: Zabezpieczenie przed barterową wymianą tej samej oferty za samą siebie
CREATE OR REPLACE FUNCTION zapobiegaj_wymianie_tej_samej_oferty() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Oferty_Od = NEW.ID_Oferty_Za THEN
        RAISE EXCEPTION 'Błąd logiczny: Oferta oddawana i oczekiwana to ta sama oferta (ID: %)!', NEW.ID_Oferty_Od;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_walidacja_id_ofert
BEFORE INSERT OR UPDATE ON Transakcje FOR EACH ROW EXECUTE FUNCTION zapobiegaj_wymianie_tej_samej_oferty();

-- Wyzwalacz 10: Blokowanie podwójnej rezerwacji egzemplarzy w transakcjach "W toku"
CREATE OR REPLACE FUNCTION zapobiegaj_podwojnej_rezerwacji() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Transakcje WHERE Status_Transakcji = 'W toku'
        AND (ID_Oferty_Od IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za) OR ID_Oferty_Za IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za))
    ) THEN
        RAISE EXCEPTION 'Odmowa transakcji: Jedna z ofert bierze już udział w innej aktywnej wymianie.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_blokada_rezerwacji
BEFORE INSERT ON Transakcje FOR EACH ROW EXECUTE FUNCTION zapobiegaj_podwojnej_rezerwacji();

-- Wyzwalacz 11: Uniemożliwianie fizycznego usuwania zrealizowanych transakcji archiwalnych
CREATE OR REPLACE FUNCTION chron_zrealizowane_transakcje() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Status_Transakcji = 'Zrealizowana' THEN
        RAISE EXCEPTION 'Odmowa: Archiwalna transakcja zrealizowana (ID: %) nie może zostać skasowana!', OLD.ID_Transakcji;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_blokada_usuniecia_transakcji
BEFORE DELETE ON Transakcje FOR EACH ROW EXECUTE FUNCTION chron_zrealizowane_transakcje();

-- Wyzwalacz 12: Zapobieganie dublowaniu identycznych aktywnych ofert przez jednego użytkownika
CREATE OR REPLACE FUNCTION zapobiegaj_duplikatom_ofert() RETURNS TRIGGER AS $$
DECLARE v_id_wymieniona INT;
BEGIN
    SELECT ID_Statusu INTO v_id_wymieniona FROM Statusy_Ofert WHERE Nazwa = 'Wymieniona';
    IF EXISTS (
        SELECT 1 FROM Oferty_Uzytkownikow 
        WHERE ID_Uzytkownika = NEW.ID_Uzytkownika AND ID_Ksiazki = NEW.ID_Ksiazki AND ID_Statusu != v_id_wymieniona
    ) THEN
        RAISE EXCEPTION 'Odmowa: Posiadasz już aktywną ofertę wymiany dla tej książki!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_zablokuj_duplikaty_ofert
BEFORE INSERT ON Oferty_Uzytkownikow FOR EACH ROW EXECUTE FUNCTION zapobiegaj_duplikatom_ofert();


-- --- MODUŁ KACPRA ---
-- Wyzwalacz 13: Sprawdzanie czy transakcja została zakończona sukcesem przed wystawieniem oceny użytkownika
CREATE OR REPLACE FUNCTION walidacja_oceny_transakcji() RETURNS TRIGGER AS $$
DECLARE aktualny_status VARCHAR(50);
BEGIN
    SELECT Status_Transakcji INTO aktualny_status FROM Transakcje WHERE ID_Transakcji = NEW.ID_Transakcji;
    IF aktualny_status != 'Zrealizowana' AND aktualny_status != 'Zakończona' THEN 
        RAISE EXCEPTION 'Nie można ocenić niezakończonej transakcji!'; 
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRG_Zablokuj_Przedwczesna_Ocene
BEFORE INSERT ON Oceny_Transakcji FOR EACH ROW EXECUTE FUNCTION walidacja_oceny_transakcji();

-- Wyzwalacz 14: Ograniczenie pozwalające użytkownikowi napisać tylko jedną recenzję dla danej pozycji książkowej
CREATE OR REPLACE FUNCTION sprawdz_podwojna_recenzje() RETURNS TRIGGER AS $$
DECLARE ile_recenzji INT;
BEGIN
    SELECT COUNT(*) INTO ile_recenzji FROM Recenzje_Ksiazek
    WHERE ID_Ksiazki = NEW.ID_Ksiazki AND ID_Uzytkownika = NEW.ID_Uzytkownika;
    IF ile_recenzji > 0 THEN 
        RAISE EXCEPTION 'Błąd: Ten użytkownik dodał już recenzję dla tej książki!'; 
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRG_Blokuj_Podwojna_Recenzje
BEFORE INSERT ON Recenzje_Ksiazek FOR EACH ROW EXECUTE FUNCTION sprawdz_podwojna_recenzje();


-- ====================================================================
-- FAZA 2: PROCEDURY SKŁADOWANE (STORED PROCEDURES)
-- Uproszczenie operacji na bazie dla interfejsów klienckich
-- ====================================================================

-- Procedura A: Dynamiczne dodawanie autora wraz z jego nową książką (Zabezpieczenie typu smallint)
CREATE OR REPLACE PROCEDURE proc_Dodaj_Autora_i_Ksiazke(
    p_imie VARCHAR(100), p_nazwisko VARCHAR(100), p_tytul VARCHAR(300),
    p_isbn VARCHAR(17), p_rok INT, p_id_wydawnictwa INT, p_id_kategorii INT
) LANGUAGE plpgsql AS $$
DECLARE v_id_autora INT;
BEGIN
    INSERT INTO Autorzy(Imie, Nazwisko) VALUES(p_imie, p_nazwisko) RETURNING ID_Autora INTO v_id_autora;
    INSERT INTO Ksiazki(Tytul, ISBN, Rok_Wydania, ID_Autora, ID_Wydawnictwa, ID_Kategorii)
    VALUES(p_tytul, p_isbn, p_rok::SMALLINT, v_id_autora, p_id_wydawnictwa, p_id_kategorii);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Wystąpił błąd w procedurze: %', SQLERRM; RAISE;
END;
$$;

-- Procedura B: Wygodne wstawianie recenzji literackich
CREATE OR REPLACE PROCEDURE proc_Dodaj_Recenzje(
    p_ocena INT, p_tresc TEXT, p_id_ksiazki INT, p_id_uzytkownika INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Recenzje_Ksiazek(Wartosc, Tresc, ID_Ksiazki, ID_Uzytkownika)
    VALUES(p_ocena, p_tresc, p_id_ksiazki, p_id_uzytkownika);
END;
$$;

-- Procedura C: Inteligentne dodawanie oferty użytkownika na bazie loginów i tytułów (zamiast surowych ID)
CREATE OR REPLACE PROCEDURE proc_Dodaj_Oferte(
    p_login VARCHAR(50), p_tytul_ksiazki VARCHAR(300), p_opis_stanu VARCHAR(255)
) LANGUAGE plpgsql AS $$
DECLARE
    v_id_uzytkownika INT; v_id_ksiazki INT; v_id_statusu INT;
BEGIN
    SELECT ID_Uzytkownika INTO v_id_uzytkownika FROM Uzytkownicy WHERE Login = p_login;
    IF v_id_uzytkownika IS NULL THEN RAISE EXCEPTION 'Błąd walidacji: Użytkownik % nie istnieje!', p_login; END IF;

    SELECT ID_Ksiazki INTO v_id_ksiazki FROM Ksiazki WHERE Tytul ILIKE p_tytul_ksiazki;
    IF v_id_ksiazki IS NULL THEN RAISE EXCEPTION 'Błąd walidacji: Książka "%" nie istnieje!', p_tytul_ksiazki; END IF;

    SELECT ID_Statusu INTO v_id_statusu FROM Statusy_Ofert WHERE Nazwa = 'Dostępna';

    INSERT INTO Oferty_Uzytkownikow (Opis_Stanu, ID_Uzytkownika, ID_Ksiazki, ID_Statusu)
    VALUES (p_opis_stanu, v_id_uzytkownika, v_id_ksiazki, v_id_statusu);
    RAISE NOTICE 'Sukces: Dodano ofertę dla użytkownika %.', p_login;
END;
$$;

-- Procedura D: Modyfikacja statusu fizycznej oferty
CREATE OR REPLACE PROCEDURE proc_Zmien_Status_Oferty(p_id_oferty INT, p_id_statusu INT) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Oferty_Uzytkownikow SET ID_Statusu = p_id_statusu WHERE ID_Oferty = p_id_oferty;
END;
$$;

-- Procedura E: Dodawanie nowych kont użytkowników systemu
CREATE OR REPLACE PROCEDURE proc_Dodaj_Uzytkownika(
    p_login VARCHAR(50), p_haslo VARCHAR(255), p_email VARCHAR(100), p_id_roli INT
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Uzytkownicy(Login, Haslo, Email, ID_Roli) VALUES(p_login, p_haslo, p_email, p_id_roli);
END;
$$;

-- Procedura F: Bezpieczne usuwanie recenzji książek
CREATE OR REPLACE PROCEDURE proc_Usun_Recenzje(p_id_recenzji INT) LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM Recenzje_Ksiazek WHERE ID_Recenzji = p_id_recenzji;
END;
$$;

-- Procedura G: Szybkie inicjowanie transakcji barterowej wymiany
CREATE OR REPLACE PROCEDURE proc_Utworz_Transakcje(p_id_oferty_od INT, p_id_oferty_za INT) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO Transakcje(Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za) VALUES('W toku', p_id_oferty_od, p_id_oferty_za);
END;
$$;

-- Procedura H: Zaawansowane dodawanie transakcji z pełną kontrolą i obsługą wyjątków
CREATE OR REPLACE PROCEDURE proc_Dodaj_Transakcje(
    p_id_oferty_od INT, p_id_oferty_za INT, p_status_transakcji VARCHAR(50) DEFAULT 'W toku'
) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Oferty_Uzytkownikow WHERE ID_Oferty = p_id_oferty_od) THEN
        RAISE EXCEPTION 'Oferta inicjująca o ID % nie istnieje w systemie!', p_id_oferty_od;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Oferty_Uzytkownikow WHERE ID_Oferty = p_id_oferty_za) THEN
        RAISE EXCEPTION 'Oferta oczekiwana o ID % nie istnieje w systemie!', p_id_oferty_za;
    END IF;

    INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za)
    VALUES (p_status_transakcji, p_id_oferty_od, p_id_oferty_za);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Wystąpił błąd podczas tworzenia transakcji: %', SQLERRM; RAISE;
END;
$$;

-- Procedura I: Zmiana uprawnień / roli systemowej przypisanej do użytkownika
CREATE OR REPLACE PROCEDURE proc_Zmien_Role_Uzytkownika(p_id_uzytkownika INT, p_id_nowej_roli INT) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Uzytkownicy SET ID_Roli = p_id_nowej_roli WHERE ID_Uzytkownika = p_id_uzytkownika;
END;
$$;

-- --------------------------------------------------------------------
-- DEMONSTRACJA WYWOŁAŃ PROCEDUR (TEST POPRAWNOŚCI LOGIKI FAZY 2)
-- --------------------------------------------------------------------
CALL proc_Dodaj_Autora_i_Ksiazke('Terry', 'Pratchett', 'Kolor magii', '978-83-123-4567-8', 1983, 1, 1);
CALL proc_Dodaj_Recenzje(10, 'Absolutny klasyk literatury fantasy!', 1, 1);
CALL proc_Dodaj_Oferte('admin', 'Kolor magii', 'Stan idealny, raz czytana');
CALL proc_Zmien_Status_Oferty(1, 2);
CALL proc_Dodaj_Uzytkownika('nowy_user', 'tajnehaslo2026', 'nowy_uzytkownik@wp.pl', 2);
CALL proc_Utworz_Transakcje(7, 8);
CALL proc_Zmien_Role_Uzytkownika(4, 1);


-- ====================================================================
-- FAZA 3: BEZPIECZEŃSTWO SYSTEMOWE I TRANSAKCJE ACID (DCL)
-- Zabezpieczenie integralności oraz kontrola poziomów dostępu ról
-- ====================================================================

-- Sekcja kont i ról serwerowych (zostawić jako komentarze na ograniczonej bazie studenckiej, 
-- odkomentować wyłącznie z poziomu superużytkownika bazy 'postgres')
-- DROP ROLE IF EXISTS Aplikacja_Konto;
-- DROP ROLE IF EXISTS Administrator_Konto;
-- CREATE ROLE Aplikacja_Konto LOGIN PASSWORD 'SilneHasloAplikacji2026!';
-- CREATE ROLE Administrator_Konto LOGIN PASSWORD 'SuperAdmin2026!';

-- Przypisywanie bezpiecznych uprawnień (DCL) do struktur bazy danych publicznej aplikacji
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO Aplikacja_Konto;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM Aplikacja_Konto;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO Aplikacja_Konto;

GRANT SELECT, INSERT ON Recenzje_Ksiazek TO Aplikacja_Konto;
GRANT SELECT, INSERT ON Oceny_Transakcji TO Aplikacja_Konto;
GRANT SELECT ON Statusy_Ofert TO Aplikacja_Konto;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO Administrator_Konto;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO Administrator_Konto;


-- --------------------------------------------------------------------
-- FAZA 3: PREZENTACJA MECHANIZMÓW IZOLACJI TRANSAKCJI
-- Wykorzystanie poziomu SERIALIZABLE do eliminacji anomalii współbieżnych
-- --------------------------------------------------------------------
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Próba dodania transakcji wymiany barterowej - w tle uruchomią się zdefiniowane wyzwalacze,
-- automatycznie chroniąc bazę przed usterkami logicznymi typu Double-booking.
INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za)
VALUES ('W toku', 9, 10);

COMMIT;
-- ====================================================================
-- KONIEC MASTER SKRYPTU INSTALACYJNEGO BAZY DANYCH
-- ====================================================================