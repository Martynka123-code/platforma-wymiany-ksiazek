-- ==========================================
-- FAZA 1: TWORZENIE TABEL I DANE TESTOWE
-- ==========================================

-- POZIOM 0: Statusy_Ofert (Słownik - brak kluczy obcych)
CREATE TABLE Statusy_Ofert (
    ID_Statusu SERIAL PRIMARY KEY,
    Nazwa VARCHAR(50) NOT NULL UNIQUE
);

-- POZIOM 2: Oferty_Uzytkownikow (Zależy od Uzytkownicy, Ksiazki, Statusy_Ofert)
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

-- POZIOM 3: Transakcje (Zależy od Oferty_Uzytkownikow)
CREATE TABLE Transakcje (
    ID_Transakcji SERIAL PRIMARY KEY,
    Data_Wymiany TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Status_Transakcji VARCHAR(50) NOT NULL,
    ID_Oferty_Od INTEGER NOT NULL,
    ID_Oferty_Za INTEGER NOT NULL,
    CONSTRAINT fk_transakcje_oferty_od FOREIGN KEY (ID_Oferty_Od) REFERENCES Oferty_Uzytkownikow(ID_Oferty),
    CONSTRAINT fk_transakcje_oferty_za FOREIGN KEY (ID_Oferty_Za) REFERENCES Oferty_Uzytkownikow(ID_Oferty)
);

-- WSTAWIANIE DANYCH (INSERT)

-- Dodanie statusów ofert
INSERT INTO Statusy_Ofert (Nazwa) VALUES 
('Dostępna'), 
('W trakcie wymiany'), 
('Wymieniona');

-- Wystawienie 10 testowych ofert (Zakładamy, że Użytkownicy 1-5 i Książki 1-10 już istnieją)
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

-- Utworzenie 3 testowych wymian (Używamy ID_Oferty utworzonych powyżej)
INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za) VALUES
('Zrealizowana', 1, 2),
('W toku', 3, 4),
('Zrealizowana', 5, 6);

SELECT 
    ID_Oferty, 
    Opis_Stanu, 
    ID_Statusu
FROM Oferty_Uzytkownikow
WHERE ID_Oferty IN (
    -- Podzapytanie wyciąga numery ID ofert, 
    -- które aktualnie są w trwających transakcjach
    SELECT ID_Oferty_Od 
    FROM Transakcje 
    WHERE Status_Transakcji = 'W toku'
    
    UNION
    
    SELECT ID_Oferty_Za 
    FROM Transakcje 
    WHERE Status_Transakcji = 'W toku'
);