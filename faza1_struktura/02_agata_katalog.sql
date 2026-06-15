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

CREATE TABLE Ksiazki (
    ID_Ksiazki SERIAL PRIMARY KEY,
    Tytul VARCHAR(300) NOT NULL,
    ISBN VARCHAR(17) UNIQUE,
    Rok_Wydania SMALLINT CHECK (Rok_Wydania BETWEEN 1000 AND 2100),
    ID_Autora INT NOT NULL REFERENCES Autorzy(ID_Autora) ON UPDATE CASCADE ON DELETE RESTRICT,
    ID_Wydawnictwa INT NOT NULL REFERENCES Wydawnictwa(ID_Wydawnictwa) ON UPDATE CASCADE ON DELETE RESTRICT,
    ID_Kategorii INT NOT NULL REFERENCES Kategorie(ID_Kategorii) ON UPDATE CASCADE ON DELETE RESTRICT
);

---
-- Autorzy
INSERT INTO Autorzy (Imie, Nazwisko) VALUES
('Andrzej', 'Sapkowski'),
('Henryk', 'Sienkiewicz'),
('Adam', 'Mickiewicz'),
('J.R.R.', 'Tolkien'),
('George', 'Orwell'),
('Stephen', 'King'),
('Joanne', 'Rowling'),
('Stanisław', 'Lem'),
('Bolesław', 'Prus'),
('Paulo', 'Coelho');

-- Wydawnictwa
INSERT INTO Wydawnictwa (Nazwa) VALUES
('SuperNOWA'),
('PWN'),
('Znak'),
('Prószyński i S-ka'),
('Albatros'),
('Rebis'),
('Media Rodzina'),
('Czytelnik'),
('Iskry'),
('Muza');

-- Kategorie
INSERT INTO Kategorie (Nazwa) VALUES
('Fantastyka'),
('Powieść historyczna'),
('Poezja'),
('Fantasy'),
('Dystopia'),
('Horror'),
('Literatura młodzieżowa'),
('Science Fiction'),
('Klasyka'),
('Literatura obyczajowa');

-- Ksiazki
INSERT INTO Ksiazki (
    Tytul,
    ISBN,
    Rok_Wydania,
    ID_Autora,
    ID_Wydawnictwa,
    ID_Kategorii
) VALUES
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