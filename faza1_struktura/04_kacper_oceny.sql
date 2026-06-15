-- Tabela Recenzje_Ksiazek 
CREATE TABLE Recenzje_Ksiazek (
    ID_Recenzji SERIAL PRIMARY KEY,
    Ocena INT NOT NULL CHECK (Ocena >= 1 AND Ocena <= 10),
    Tresc TEXT,
    Data_Dodania TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    ID_Ksiazki INT NOT NULL,
    ID_Uzytkownika INT NOT NULL,
    FOREIGN KEY (ID_Ksiazki) REFERENCES Ksiazki(ID_Ksiazki) ON DELETE CASCADE,
    FOREIGN KEY (ID_Uzytkownika) REFERENCES Uzytkownicy(ID_Uzytkownika) ON DELETE CASCADE
);

-- Tabela Oceny_Transakcji
CREATE TABLE Oceny_Transakcji (
    ID_Oceny SERIAL PRIMARY KEY,
    Ocena INT NOT NULL CHECK (Ocena >= 1 AND Ocena <= 5),
    Komentarz TEXT,
    Data_Dodania TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ID_Transakcji INT NOT NULL,
    ID_Oceniajacego INT NOT NULL,
    FOREIGN KEY (ID_Transakcji) REFERENCES Transakcje(ID_Transakcji) ON DELETE CASCADE,
    FOREIGN KEY (ID_Oceniajacego) REFERENCES Uzytkownicy(ID_Uzytkownika) ON DELETE CASCADE
);

-- Twoje dane testowe (działają bez zmian, data uzupełni się sama)
INSERT INTO Recenzje_Ksiazek (Ocena, Tresc, ID_Ksiazki, ID_Uzytkownika) VALUES
(9, 'Niesamowita książka, przeczytałem w jeden wieczór. Polecam wszystkim fanom gatunku!', 1, 2),
(5, 'Całkiem średnia, spodziewałem się czegoś lepszego po tym autorze.', 2, 1),
(10, 'Absolutne arcydzieło. Zmieniła moje spojrzenie na świat.', 3, 3);

INSERT INTO Oceny_Transakcji (Ocena, Komentarz, ID_Transakcji, ID_Oceniajacego) VALUES
(5, 'Szybka i bezproblemowa wymiana. Książka w idealnym stanie, jak w opisie.', 1, 2),
(4, 'Wymiana udana, chociaż musieliśmy trochę poczekać na dogodny termin.', 2, 1),
(5, 'Wszystko super, polecam tego użytkownika!', 3, 3);