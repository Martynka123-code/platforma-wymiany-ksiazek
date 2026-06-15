CREATE OR REPLACE FUNCTION sprawdzenie_poprawnosci_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Email NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Błąd walidacji: Podany adres e-mail (%) jest nieprawidłowy. Musi zawierać znak @!', NEW.Email;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER weryfikacja_email_przed_zapisem
BEFORE INSERT OR UPDATE ON Uzytkownicy
FOR EACH ROW
EXECUTE FUNCTION sprawdzenie_poprawnosci_email();

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

CREATE TRIGGER ochrona_ostatniego_admina_w_bazie
BEFORE DELETE ON Uzytkownicy
FOR EACH ROW
EXECUTE FUNCTION ochrona_ostatniego_admina();


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




SELECT 
    u.ID_Uzytkownika,
    u.Login,
    u.Email,
    COUNT(o.ID_Oferty) AS Laczna_Liczba_Ofert
FROM Uzytkownicy u
LEFT JOIN Oferty_Uzytkownikow o ON u.ID_Uzytkownika = o.ID_Uzytkownika
GROUP BY u.ID_Uzytkownika, u.Login, u.Email
ORDER BY Laczna_Liczba_Ofert DESC, u.ID_Uzytkownika ASC;