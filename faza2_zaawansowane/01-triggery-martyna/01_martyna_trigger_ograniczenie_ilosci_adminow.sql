CREATE OR REPLACE FUNCTION limit_administratorow()
RETURNS TRIGGER AS $$
DECLARE
    id_roli_admin INTEGER;
    liczba_adminow INTEGER;
BEGIN
    SELECT ID_Roli INTO id_roli_admin FROM Role WHERE Nazwa_Roli = 'Admin';

    IF NEW.ID_Roli = id_roli_admin THEN
        SELECT COUNT(*) INTO liczba_adminow FROM Uzytkownicy WHERE ID_Roli = id_roli_admin;
        
        IF liczba_adminow >= 3 THEN
            RAISE EXCEPTION 'Odmowa dostępu: Osiągnięto maksymalny limit (3) kont administratorów w systemie.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ograniczenie_ilosci_adminow
BEFORE INSERT OR UPDATE ON Uzytkownicy
FOR EACH ROW
EXECUTE FUNCTION limit_administratorow();