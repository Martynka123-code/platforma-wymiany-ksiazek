CREATE OR REPLACE FUNCTION ochrona_ostatniego_admina()
RETURNS TRIGGER AS $$
DECLARE
    id_roli_admin INTEGER;
    liczba_adminow INTEGER;
BEGIN
    SELECT ID_Roli INTO id_roli_admin FROM Role WHERE Nazwa_Roli = 'Admin';

    IF OLD.ID_Roli = id_roli_admin THEN
        SELECT COUNT(*) INTO liczba_adminow FROM Uzytkownicy WHERE ID_Roli = id_roli_admin;
        
        IF liczba_adminow <= 1 THEN
            RAISE EXCEPTION 'Błąd krytyczny: Nie można usunąć użytkownika %. W bazie musi pozostać co najmniej jeden Administrator!', OLD.Login;
        END IF;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ochrona_ostatniego_admina
BEFORE DELETE ON Uzytkownicy
FOR EACH ROW
EXECUTE FUNCTION ochrona_ostatniego_admina();