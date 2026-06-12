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