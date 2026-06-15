-- ====================================================================
-- PLATFORMA WYMIANY KSIĄŻEK - SKRYPT GŁÓWNY (FAZY 1, 2, 3)
-- ====================================================================

-- ====================================================================
-- FAZA 1: TWORZENIE TABEL I WSTAWIANIE DANYCH (POZIOMY 0 - 4)
-- ====================================================================

-- POZIOM 0 (Słowniki)
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

-- POZIOM 1 (Zależne od Poziomu 0)
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

-- POZIOM 2 (Zależne od Poziomu 1)
CREATE TABLE Oferty_Uzytkownikow (
    ID_Oferty SERIAL PRIMARY KEY,
    Opis_Stanu VARCHAR(255),
    ID_Uzytkownika INTEGER NOT NULL,
    ID_Ksiazki INTEGER NOT NULL,
    ID_Statusu INTEGER NOT NULL,
    CONSTRAINT fk_oferty_uzytkownicy FOREIGN KEY (ID_Uzytkownika) REFERENCES Uzytkownicy(ID_Uzytkownika),
    CONSTRAINT fk_oferty_ksiazki FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazki(ID_Ksiazki),
    CONSTRAINT fk_oferty_statusy FOREIGN KEY (ID_Statusu) REFERENCES Statusy_Ofert(ID_Statusu)
);

-- POZIOM 3 (Zależne od Poziomu 2)
CREATE TABLE Transakcje (
    ID_Transakcji SERIAL PRIMARY KEY,
    Data_Wymiany TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status_Transakcji VARCHAR(50) NOT NULL,
    ID_Oferty_Od INTEGER NOT NULL,
    ID_Oferty_Za INTEGER NOT NULL,
    CONSTRAINT fk_transakcje_oferty_od FOREIGN KEY (ID_Oferty_Od) REFERENCES Oferty_Uzytkownikow(ID_Oferty),
    CONSTRAINT fk_transakcje_oferty_za FOREIGN KEY (ID_Oferty_Za) REFERENCES Oferty_Uzytkownikow(ID_Oferty)
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

-- POZIOM 4 (Zależne od Poziomu 3)
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

-- WSTAWIANIE DANYCH TESTOWYCH
INSERT INTO Role (Nazwa_Roli) VALUES ('Admin'), ('Uzytkownik');
INSERT INTO Autorzy (Imie, Nazwisko) VALUES ('Andrzej', 'Sapkowski'), ('Henryk', 'Sienkiewicz'), ('Adam', 'Mickiewicz');
INSERT INTO Wydawnictwa (Nazwa) VALUES ('SuperNOWA'), ('PWN'), ('Znak');
INSERT INTO Kategorie (Nazwa) VALUES ('Fantastyka'), ('Powieść historyczna'), ('Poezja');
INSERT INTO Statusy_Ofert (Nazwa) VALUES ('Dostępna'), ('W trakcie wymiany'), ('Wymieniona');

INSERT INTO Uzytkownicy (Login, Haslo, Email, ID_Roli) VALUES
('ksiazkowymol1', 'haslo123', 'ksiazkowyMol1@wp.pl', 2),
('KasiaKsiążkowa', 'Reksio123!', 'kasiak@gmail.com', 2),
('admin', 'RootPassword', 'admin@gmail.com', 1);

INSERT INTO Ksiazki (Tytul, ISBN, Rok_Wydania, ID_Autora, ID_Wydawnictwa, ID_Kategorii) VALUES
('Ostatnie życzenie', '978-83-7578-063-5', 1993, 1, 1, 1),
('Quo Vadis', '978-83-240-1234-5', 1896, 2, 2, 2),
('Pan Tadeusz', '978-83-111-1111-1', 1834, 3, 3, 3);

INSERT INTO Oferty_Uzytkownikow (Opis_Stanu, ID_Uzytkownika, ID_Ksiazki, ID_Statusu) VALUES
('Lekko zagięte rogi', 1, 1, 1), ('Stan idealny', 2, 2, 1), ('Ślady czytania', 3, 3, 1), ('Nowa', 1, 3, 1), ('Dobra', 2, 1, 1);

INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za) VALUES
('Zrealizowana', 1, 2), ('W toku', 3, 4), ('Zrealizowana', 5, 1);

INSERT INTO Recenzje_Ksiazek (Wartosc, Tresc, ID_Ksiazki, ID_Uzytkownika) VALUES
(9, 'Niesamowita książka.', 1, 2), (5, 'Całkiem średnia.', 2, 1);

INSERT INTO Oceny_Transakcji (Wartosc, Komentarz, ID_Transakcji, ID_Oceniajacego) VALUES
(5, 'Szybka i bezproblemowa wymiana.', 1, 2), (4, 'Wymiana udana.', 2, 1);


-- ====================================================================
-- FAZA 2: ZAAWANSOWANY SQL, WIDOKI I WYZWALACZE
-- ====================================================================

-- 1. KACPER: WIDOK (Ranking Ksiazek)
CREATE OR REPLACE VIEW Ranking_Ksiazek AS
SELECT k.Tytul, a.Nazwisko AS Autor, ROUND(AVG(r.Wartosc), 2) AS Srednia_Ocena, COUNT(r.ID_Recenzji) AS Liczba_Glosow
FROM Ksiazki k
JOIN Autorzy a ON k.ID_Autora = a.ID_Autora
JOIN Recenzje_Ksiazek r ON k.ID_Ksiazki = r.ID_Ksiazki
GROUP BY k.Tytul, a.Nazwisko ORDER BY Srednia_Ocena DESC;

-- 2. KACPER: TRIGGER (Walidacja oceny transakcji)
CREATE OR REPLACE FUNCTION walidacja_oceny_transakcji() RETURNS TRIGGER AS $$
DECLARE aktualny_status VARCHAR(50);
BEGIN
    SELECT Status_Transakcji INTO aktualny_status FROM Transakcje WHERE ID_Transakcji = NEW.ID_Transakcji;
    IF aktualny_status != 'Zrealizowana' THEN RAISE EXCEPTION 'Nie można ocenić niezakończonej transakcji!'; END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRG_Zablokuj_Przedwczesna_Ocene
BEFORE INSERT ON Oceny_Transakcji FOR EACH ROW EXECUTE FUNCTION walidacja_oceny_transakcji();

-- 3. MARTYNA: TRIGGER (Email)
CREATE OR REPLACE FUNCTION sprawdzenie_poprawnosci_email() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Email NOT LIKE '%@%' THEN RAISE EXCEPTION 'Błąd: Email musi zawierać znak @!'; END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER weryfikacja_email_przed_zapisem
BEFORE INSERT OR UPDATE ON Uzytkownicy FOR EACH ROW EXECUTE FUNCTION sprawdzenie_poprawnosci_email();

-- 4. AGATA: WIDOK (Pelny Katalog)
CREATE OR REPLACE VIEW v_Ksiazki_Szczegoly AS
SELECT k.ID_Ksiazki, k.Tytul, k.ISBN, k.Rok_Wydania, a.Imie || ' ' || a.Nazwisko AS Autor, w.Nazwa AS Wydawnictwo, kat.Nazwa AS Kategoria
FROM Ksiazki k JOIN Autorzy a ON k.ID_Autora = a.ID_Autora JOIN Wydawnictwa w ON k.ID_Wydawnictwa = w.ID_Wydawnictwa JOIN Kategorie kat ON k.ID_Kategorii = kat.ID_Kategorii;

-- 5. DAMIAN: TRIGGER (Zmiana statusu)
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


-- ====================================================================
-- FAZA 3: BEZPIECZEŃSTWO I TRANSAKCJE ACID
-- ====================================================================

-- MARTYNA: TWORZENIE RÓL SYSTEMOWYCH
DROP ROLE IF EXISTS Aplikacja_Konto;
DROP ROLE IF EXISTS Administrator_Konto;

CREATE ROLE Aplikacja_Konto LOGIN PASSWORD 'SilneHasloAplikacji2026!';
CREATE ROLE Administrator_Konto LOGIN PASSWORD 'SuperAdmin2026!';

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO Aplikacja_Konto;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM Aplikacja_Konto;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO Aplikacja_Konto;

-- KACPER: NADANIE UPRAWNIEŃ (POPRAWIONE NAZWY RÓL)
GRANT SELECT, INSERT ON Recenzje_Ksiazek TO Aplikacja_Konto;
GRANT SELECT, INSERT ON Oceny_Transakcji TO Aplikacja_Konto;
GRANT SELECT ON Statusy_Ofert TO Aplikacja_Konto;

GRANT ALL PRIVILEGES ON Recenzje_Ksiazek TO Administrator_Konto;
GRANT ALL PRIVILEGES