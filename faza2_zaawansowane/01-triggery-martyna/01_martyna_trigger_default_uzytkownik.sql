CREATE OR REPLACE FUNCTION ustawienie_domyslnej_roli()
RETURNS TRIGGER AS $$
DECLARE
    id_roli_domyslnej INTEGER;
BEGIN
    IF NEW.ID_Roli IS NULL THEN
        SELECT ID_Roli INTO id_roli_domyslnej FROM Role WHERE Nazwa_Roli = 'Uzytkownik';
        
        NEW.ID_Roli := id_roli_domyslnej;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ustawienie_domyslnej_roli_uzytkownik
BEFORE INSERT ON Uzytkownicy
FOR EACH ROW
EXECUTE FUNCTION ustawienie_domyslnej_roli();