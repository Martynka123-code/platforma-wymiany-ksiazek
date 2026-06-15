CREATE OR REPLACE VIEW Ranking_Ksiazek AS
SELECT 
    k.Tytul, 
    a.Nazwisko AS Autor, 
    ROUND(AVG(r.Wartosc), 2) AS Srednia_Ocena,
    COUNT(r.ID_Recenzji) AS Liczba_Glosow
FROM 
    Ksiazki k
JOIN Autorzy a ON k.ID_Autora = a.ID_Autora
JOIN Recenzje_Ksiazek r ON k.ID_Ksiazki = r.ID_Ksiazki
GROUP BY 
    k.Tytul, a.Nazwisko
ORDER BY 
    Srednia_Ocena DESC;


-- 2. WYZWALACZ (TRIGGER) - Sprawdza logiczną spójność transakcji przed wystawieniem oceny
CREATE OR REPLACE FUNCTION walidacja_oceny_transakcji()
RETURNS TRIGGER AS $$
DECLARE
    aktualny_status VARCHAR(50);
BEGIN
    -- Pobieramy status transakcji z tabeli tworzonej przez Osobę 3
    SELECT Status_Transakcji INTO aktualny_status
    FROM Transakcje
    WHERE ID_Transakcji = NEW.ID_Transakcji;

    -- Jeśli transakcja nie jest zakończona sukcesem, blokujemy dodanie oceny
    IF aktualny_status != 'Zakończona' THEN
        RAISE EXCEPTION 'Nie można ocenić transakcji, która nie została jeszcze ostatecznie zakończona!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRG_Zablokuj_Przedwczesna_Ocene
BEFORE INSERT ON Oceny_Transakcji
FOR EACH ROW
EXECUTE FUNCTION walidacja_oceny_transakcji();


-- FUNKCJA: Sprawdza, czy użytkownik recenzował już tę książkę
CREATE OR REPLACE FUNCTION sprawdz_podwojna_recenzje()
RETURNS TRIGGER AS $$
DECLARE
    ile_recenzji INT;
BEGIN
    -- Liczymy, czy w bazie jest już recenzja tego użytkownika dla tej konkretnej książki
    SELECT COUNT(*) INTO ile_recenzji
    FROM Recenzje_Ksiazek
    WHERE ID_Ksiazki = NEW.ID_Ksiazki 
      AND ID_Uzytkownika = NEW.ID_Uzytkownika;

    -- Jeśli funkcja znajdzie już jakiś wpis (wynik większy niż 0), rzucamy błąd
    IF ile_recenzji > 0 THEN
        RAISE EXCEPTION 'Błąd: Ten użytkownik dodał już recenzję dla tej książki!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- WYZWALACZ: Uruchamia się przed każdym dodaniem nowej recenzji
CREATE TRIGGER TRG_Blokuj_Podwojna_Recenzje
BEFORE INSERT ON Recenzje_Ksiazek
FOR EACH ROW
EXECUTE FUNCTION sprawdz_podwojna_recenzje();
