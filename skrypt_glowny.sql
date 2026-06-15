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




-- Czyszczenie starego widoku, jeśli istniał
DROP VIEW IF EXISTS Widok_Pelne_Transakcje CASCADE;

-- Tworzenie widoku ogólnego transakcji
CREATE VIEW Widok_Pelne_Transakcje AS
SELECT
    t.ID_Transakcji,
    t.Data_Wymiany,
    t.Status_Transakcji,

    -- STRONA INICJUJĄCA (Co i kto oddaje)
    u_od.Login AS Uzytkownik_Inicjujacy,
    k_od.Tytul AS Ksiazka_Oddawana,

    -- STRONA ODPOWIADAJĄCA (Co i kto daje w zamian)
    u_za.Login AS Uzytkownik_Akceptujacy,
    k_za.Tytul AS Ksiazka_Otrzymywana

FROM Transakcje t
-- 1. Dołączenie danych dla oferty OD (ktoś daje tę książkę)
JOIN Oferty_Uzytkownikow o_od ON t.ID_Oferty_Od = o_od.ID_Oferty
JOIN Uzytkownicy u_od ON o_od.ID_Uzytkownika = u_od.ID_Uzytkownika
JOIN Ksiazki k_od ON o_od.ID_Ksiazki = k_od.ID_Ksiazki

-- 2. Dołączenie danych dla oferty ZA (ktoś daje tę książkę w zamian)
JOIN Oferty_Uzytkownikow o_za ON t.ID_Oferty_Za = o_za.ID_Oferty
JOIN Uzytkownicy u_za ON o_za.ID_Uzytkownika = u_za.ID_Uzytkownika
JOIN Ksiazki k_za ON o_za.ID_Ksiazki = k_za.ID_Ksiazki;



-- Czyszczenie starego widoku, jeśli istniał
DROP VIEW IF EXISTS Widok_Pelne_Oferty CASCADE;

-- Tworzenie widoku ogólnego
CREATE VIEW Widok_Pelne_Oferty AS
SELECT
    o.ID_Oferty,
    u.Login AS Uzytkownik_Proponujacy,
    k.Tytul AS Tytul_Ksiazki,
    o.Opis_Stanu AS Stan_Egzemplarza,
    s.Nazwa AS Status_Oferty
FROM Oferty_Uzytkownikow o
-- Dołączenie tabeli Użytkownicy (Moduł Osoby 1)
JOIN Uzytkownicy u ON o.ID_Uzytkownika = u.ID_Uzytkownika
-- Dołączenie tabeli Książki (Moduł Osoby 2)
JOIN Ksiazki k ON o.ID_Ksiazki = k.ID_Ksiazki
-- Dołączenie tabeli Statusy_Ofert (Twój Moduł)
JOIN Statusy_Ofert s ON o.ID_Statusu = s.ID_Statusu;





CREATE OR REPLACE PROCEDURE proc_Dodaj_Autora_i_Ksiazke(
    p_imie VARCHAR(100),
    p_nazwisko VARCHAR(100),
    p_tytul VARCHAR(300),
    p_isbn VARCHAR(17),
    p_rok SMALLINT,
    p_id_wydawnictwa INT,
    p_id_kategorii INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_autora INT;
BEGIN

    INSERT INTO Autorzy(Imie, Nazwisko)
    VALUES(p_imie, p_nazwisko)
    RETURNING ID_Autora INTO v_id_autora;

    INSERT INTO Ksiazki(
        Tytul,
        ISBN,
        Rok_Wydania,
        ID_Autora,
        ID_Wydawnictwa,
        ID_Kategorii
    )
    VALUES(
        p_tytul,
        p_isbn,
        p_rok,
        v_id_autora,
        p_id_wydawnictwa,
        p_id_kategorii
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Wystapil blad: %', SQLERRM;
        RAISE;
END;
$$;


-- Użycie
CALL proc_Dodaj_Autora_i_Ksiazke(
    'Terry',
    'Pratchett',
    'Kolor magii',
    '978-83-123-4567-8',
    1983::smallint,
    1,
    1
);


CREATE OR REPLACE PROCEDURE proc_Dodaj_Recenzje(
    p_ocena INT,
    p_tresc TEXT,
    p_id_ksiazki INT,
    p_id_uzytkownika INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Recenzje_Ksiazek(
        Wartosc,
        Tresc,
        ID_Ksiazki,
        ID_Uzytkownika
    )
    VALUES(
        p_ocena,
        p_tresc,
        p_id_ksiazki,
        p_id_uzytkownika
    );
END;
$$;


-- Użycie
CALL proc_Dodaj_Recenzje(
    10,
    'Świetna książka',
    1,
    1
);


CREATE OR REPLACE PROCEDURE proc_Dodaj_Oferte(
    p_login VARCHAR(50),
    p_tytul_ksiazki VARCHAR(300),
    p_opis_stanu VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_uzytkownika INT;
    v_id_ksiazki INT;
    v_id_statusu INT;
BEGIN
    -- 1. Znalezienie ID użytkownika na podstawie jego loginu (Moduł Osoby 1)
    SELECT ID_Uzytkownika INTO v_id_uzytkownika 
    FROM Uzytkownicy 
    WHERE Login = p_login;

    IF v_id_uzytkownika IS NULL THEN
        RAISE EXCEPTION 'Błąd walidacji: Użytkownik o loginie "%" nie istnieje!', p_login;
    END IF;

    -- 2. Znalezienie ID książki na podstawie jej tytułu (Moduł Osoby 2)
    -- Używamy ILIKE, aby wielkość liter w tytule nie miała znaczenia
    SELECT ID_Ksiazki INTO v_id_ksiazki 
    FROM Ksiazki 
    WHERE Tytul ILIKE p_tytul_ksiazki;

    IF v_id_ksiazki IS NULL THEN
        RAISE EXCEPTION 'Błąd walidacji: Książka o tytule "%" nie istnieje w katalogu!', p_tytul_ksiazki;
    END IF;

    -- 3. Automatyczne pobranie ID statusu 'Dostępna' dla nowej oferty (Twój słownik)
    SELECT ID_Statusu INTO v_id_statusu 
    FROM Statusy_Ofert 
    WHERE Nazwa = 'Dostępna';

    IF v_id_statusu IS NULL THEN
        RAISE EXCEPTION 'Błąd systemowy: Status "Dostępna" nie istnieje w słowniku statusów!';
    END IF;

    -- 4. Wstawienie nowej oferty do bazy danych
    INSERT INTO Oferty_Uzytkownikow (Opis_Stanu, ID_Uzytkownika, ID_Ksiazki, ID_Statusu)
    VALUES (p_opis_stanu, v_id_uzytkownika, v_id_ksiazki, v_id_statusu);

    RAISE NOTICE 'Sukces: Oferta dla książki "%" została dodana przez użytkownika %.', p_tytul_ksiazki, p_login;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Wystąpił nieoczekiwany błąd podczas dodawania oferty: %', SQLERRM;
        RAISE;
END;
$$;

CALL proc_Dodaj_Oferte(
    'admin', 
    'Kolor magii', 
    'Stan bardzo dobry, drobne rysy na okładce'
);




CREATE OR REPLACE PROCEDURE proc_Zmien_Status_Oferty(
    p_id_oferty INT,
    p_id_statusu INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Oferty_Uzytkownikow
    SET ID_Statusu = p_id_statusu
    WHERE ID_Oferty = p_id_oferty;
END;
$$;

-- Użycie
CALL proc_Zmien_Status_Oferty(1, 2);



CREATE OR REPLACE PROCEDURE proc_Dodaj_Uzytkownika(
    p_login VARCHAR(50),
    p_haslo VARCHAR(255),
    p_email VARCHAR(100),
    p_id_roli INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Uzytkownicy(
        Login,
        Haslo,
        Email,
        ID_Roli
    )
    VALUES(
        p_login,
        p_haslo,
        p_email,
        p_id_roli
    );
END;
$$;

-- Użycie
CALL proc_Dodaj_Uzytkownika(
    'nowy_user',
    'tajnehaslo',
    'nowy@wp.pl',
    2
);



CREATE OR REPLACE PROCEDURE proc_Usun_Recenzje(
    p_id_recenzji INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Recenzje_Ksiazek
    WHERE ID_Recenzji = p_id_recenzji;
END;
$$;


-- Użycie
CALL proc_Usun_Recenzje(1);



CREATE OR REPLACE PROCEDURE proc_Utworz_Transakcje(
    p_id_oferty_od INT,
    p_id_oferty_za INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Transakcje(
        Status_Transakcji,
        ID_Oferty_Od,
        ID_Oferty_Za
    )
    VALUES(
        'W toku',
        p_id_oferty_od,
        p_id_oferty_za
    );
END;
$$;


-- Użycie
CALL proc_Utworz_Transakcje(1, 2);



CREATE OR REPLACE PROCEDURE proc_Zmien_Role_Uzytkownika(
    p_id_uzytkownika INT,
    p_id_nowej_roli INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Uzytkownicy
    SET ID_Roli = p_id_nowej_roli
    WHERE ID_Uzytkownika = p_id_uzytkownika;
END;
$$;


-- Użycie
CALL proc_Zmien_Role_Uzytkownika(1, 1);

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