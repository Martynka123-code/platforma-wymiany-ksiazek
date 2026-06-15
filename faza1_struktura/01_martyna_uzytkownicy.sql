CREATE TABLE Role (
    ID_Roli SERIAL PRIMARY KEY,
    Nazwa_Roli VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Uzytkownicy (
    ID_Uzytkownika SERIAL PRIMARY KEY,
    Login VARCHAR(50) NOT NULL UNIQUE,
    Haslo VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Data_Rejestracji TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ID_Roli INTEGER NOT NULL,
    CONSTRAINT fk_uzytkownicy_role FOREIGN KEY (ID_Roli) REFERENCES Role(ID_Roli)
);

INSERT INTO Role (Nazwa_Roli) VALUES 
    ('Admin'), 
    ('Uzytkownik');

INSERT INTO Uzytkownicy (Login, Haslo, Email, ID_Roli) VALUES
    ('ksiazkowymol1', 'haslo123', 'ksiazkowyMol1@wp.pl', 2),
    ('KasiaKsiążkowa', 'Reksio123!', 'kasiak@gmail.com', 2),
    ('Fantastic_lover', 'TrudneHaslo987', 'lover@gmail.com', 2),
    ('Bookworm123', 'Haslo456', 'bookworm123@gmail.com', 2),
    ('admin', 'RootPassword2026', 'tomek.admin@gmail.com', 1);
