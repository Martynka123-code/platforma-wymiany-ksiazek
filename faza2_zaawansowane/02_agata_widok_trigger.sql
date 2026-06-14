CREATE OR REPLACE VIEW v_Ksiazki_Szczegoly AS
SELECT
    k.ID_Ksiazki,
    k.Tytul,
    k.ISBN,
    k.Rok_Wydania,
    a.Imie || ' ' || a.Nazwisko AS Autor,
    w.Nazwa AS Wydawnictwo,
    kat.Nazwa AS Kategoria
FROM Ksiazki k
JOIN Autorzy a
    ON k.ID_Autora = a.ID_Autora
JOIN Wydawnictwa w
    ON k.ID_Wydawnictwa = w.ID_Wydawnictwa
JOIN Kategorie kat
    ON k.ID_Kategorii = kat.ID_Kategorii;


CREATE OR REPLACE VIEW v_Autorzy_Statystyki AS
SELECT
    a.ID_Autora,
    a.Imie,
    a.Nazwisko,
    COUNT(k.ID_Ksiazki) AS Liczba_Ksiazek
FROM Autorzy a
LEFT JOIN Ksiazki k
    ON a.ID_Autora = k.ID_Autora
GROUP BY
    a.ID_Autora,
    a.Imie,
    a.Nazwisko;


CREATE OR REPLACE VIEW v_Kategorie_Statystyki AS
SELECT
    kat.ID_Kategorii,
    kat.Nazwa,
    COUNT(k.ID_Ksiazki) AS Liczba_Ksiazek
FROM Kategorie kat
LEFT JOIN Ksiazki k
    ON kat.ID_Kategorii = k.ID_Kategorii
GROUP BY
    kat.ID_Kategorii,
    kat.Nazwa;



CREATE OR REPLACE FUNCTION fn_Liczba_Ksiazek_Autora(
    p_id_autora INT
)
RETURNS INT AS
$$
DECLARE
    v_liczba INT;
BEGIN

    SELECT COUNT(*)
    INTO v_liczba
    FROM Ksiazki
    WHERE ID_Autora = p_id_autora;

    RETURN v_liczba;

END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_Ustaw_Rok()
RETURNS TRIGGER AS
$$
BEGIN

    IF NEW.Rok_Wydania IS NULL THEN
        NEW.Rok_Wydania := EXTRACT(YEAR FROM CURRENT_DATE);
    END IF;

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_Ustaw_Rok
BEFORE INSERT ON Ksiazki
FOR EACH ROW
EXECUTE FUNCTION fn_Ustaw_Rok();


CREATE OR REPLACE FUNCTION fn_Blokuj_Usuniecie_Autora()
RETURNS TRIGGER AS
$$
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Ksiazki
        WHERE ID_Autora = OLD.ID_Autora
    )
    THEN
        RAISE EXCEPTION
        'Nie można usunąć autora posiadającego książki.';
    END IF;

    RETURN OLD;

END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_Blokuj_Usuniecie_Autora
BEFORE DELETE ON Autorzy
FOR EACH ROW
EXECUTE FUNCTION fn_Blokuj_Usuniecie_Autora();


CREATE OR REPLACE FUNCTION fn_Upper_Tytul()
RETURNS TRIGGER AS
$$
BEGIN

    NEW.Tytul := UPPER(NEW.Tytul);

    RETURN NEW;

END;
$$
LANGUAGE plpgsql;


CREATE TRIGGER trg_Upper_Tytul
BEFORE INSERT ON Ksiazki
FOR EACH ROW
EXECUTE FUNCTION fn_Upper_Tytul();