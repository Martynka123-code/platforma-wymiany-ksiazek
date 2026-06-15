


-- 1. Statystyki statusów ofert
CREATE VIEW Statystyki_Statusow_Ofert AS
SELECT 
    s.Nazwa AS Status_Oferty, 
    COUNT(o.ID_Oferty) AS Liczba_Przypisanych_Ofert
FROM Statusy_Ofert s
LEFT JOIN Oferty_Uzytkownikow o ON s.ID_Statusu = o.ID_Statusu
GROUP BY s.ID_Statusu, s.Nazwa
ORDER BY Liczba_Przypisanych_Ofert DESC;

-- 2. Rejestr aktywnych transakcji
CREATE VIEW Rejestr_Aktywnych_Transakcji AS
SELECT 
    ID_Transakcji, 
    Data_Wymiany, 
    Status_Transakcji,
    ID_Oferty_Od, 
    ID_Oferty_Za
FROM Transakcje
WHERE Status_Transakcji = 'W toku'
ORDER BY Data_Wymiany ASC;

-- 3. Analiza zaangażowania ofert (z podzapytaniem)
CREATE VIEW Widok_Zaangazowanie_Ofert AS
SELECT 
    o.ID_Oferty,
    o.ID_Uzytkownika,
    o.Opis_Stanu,
    (
        SELECT COUNT(*) 
        FROM Transakcje t 
        WHERE t.ID_Oferty_Od = o.ID_Oferty OR t.ID_Oferty_Za = o.ID_Oferty
    ) AS Liczba_Podejsc_Do_Wymiany
FROM Oferty_Uzytkownikow o
ORDER BY Liczba_Podejsc_Do_Wymiany DESC;


-- ====================================================================
-- FAZA 2: WYZWALACZE (TRIGGERS) I FUNKCJE PL/pgSQL
-- ====================================================================

-- Trigger 1: Automatyczna zmiana statusu oferty na "Wymieniona" po transakcji
CREATE FUNCTION zaktualizuj_status_ofert()
RETURNS TRIGGER AS $$
DECLARE
    v_id_statusu INTEGER;
BEGIN
    SELECT ID_Statusu INTO v_id_statusu FROM Statusy_Ofert WHERE Nazwa = 'Wymieniona';
    UPDATE Oferty_Uzytkownikow
    SET ID_Statusu = v_id_statusu
    WHERE ID_Oferty IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_po_dodaniu_transakcji
AFTER INSERT ON Transakcje
FOR EACH ROW
EXECUTE FUNCTION zaktualizuj_status_ofert();

-- Trigger 2: Zabezpieczenie przed wymianą oferty za samą siebie
CREATE FUNCTION zapobiegaj_wymianie_tej_samej_oferty()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ID_Oferty_Od = NEW.ID_Oferty_Za THEN
        RAISE EXCEPTION 'Błąd logiczny: Oferta oddawana i oczekiwana to ta sama oferta (ID: %)!', NEW.ID_Oferty_Od;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_walidacja_id_ofert
BEFORE INSERT OR UPDATE ON Transakcje
FOR EACH ROW
EXECUTE FUNCTION zapobiegaj_wymianie_tej_samej_oferty();

-- Trigger 3: Blokada podwójnej rezerwacji (Double-booking)
CREATE FUNCTION zapobiegaj_podwojnej_rezerwacji()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Transakcje 
        WHERE Status_Transakcji = 'W toku'
        AND (
            ID_Oferty_Od IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za) 
            OR 
            ID_Oferty_Za IN (NEW.ID_Oferty_Od, NEW.ID_Oferty_Za)
        )
    ) THEN
        RAISE EXCEPTION 'Odmowa: Jedna z ofert bierze już udział w innej aktywnej wymianie.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_blokada_rezerwacji
BEFORE INSERT ON Transakcje
FOR EACH ROW
EXECUTE FUNCTION zapobiegaj_podwojnej_rezerwacji();

-- Trigger 4: Blokada usunięcia zrealizowanej transakcji
CREATE FUNCTION chron_zrealizowane_transakcje()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Status_Transakcji = 'Zrealizowana' THEN
        RAISE EXCEPTION 'Odmowa: Nie można usunąć zrealizowanej transakcji (ID: %)!', OLD.ID_Transakcji;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_blokada_usuniecia_transakcji
BEFORE DELETE ON Transakcje
FOR EACH ROW
EXECUTE FUNCTION chron_zrealizowane_transakcje();


---------------------------------------

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
---------------------------------------
--ZAGNIEŻDŻENIA - 

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




SELECT 
    ID_Transakcji, 
    Status_Transakcji, 
    ID_Oferty_Od, 
    ID_Oferty_Za, 
    Data_Wymiany
FROM Transakcje
WHERE Data_Wymiany = (
    -- Podzapytanie najpierw skanuje całą tabelę i zwraca jedną wartość:
    -- najpóźniejszą (największą) datę wymiany w systemie.
    SELECT MAX(Data_Wymiany) 
    FROM Transakcje
);