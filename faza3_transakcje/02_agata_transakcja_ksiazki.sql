CREATE OR REPLACE PROCEDURE proc_Dodaj_Autora_i_Ksiazke(
    p_imie VARCHAR(100),
    p_nazwisko VARCHAR(100),
    p_tytul VARCHAR(300),
    p_isbn VARCHAR(17),
    p_rok SMALLINT,
    p_id_wydawnictwa INT,
    p_id_kategorii INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_autora INT;
BEGIN

    INSERT INTO Autorzy(Imie, Nazwisko)
    VALUES(p_imie, p_nazwisko)
    RETURNING ID_Autora INTO v_id_autora;

    INSERT INTO Ksiazki(
        Tytul,
        ISBN,
        Rok_Wydania,
        ID_Autora,
        ID_Wydawnictwa,
        ID_Kategorii
    )
    VALUES(
        p_tytul,
        p_isbn,
        p_rok,
        v_id_autora,
        p_id_wydawnictwa,
        p_id_kategorii
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Wystapil blad: %', SQLERRM;
        RAISE;
END;
$$;


-- Użycie
-- CALL proc_Dodaj_Autora_i_Ksiazke(
--     'Terry',
--     'Pratchett',
--     'Kolor magii',
--     '978-83-123-4567-8',
--     1983,
--     1,
--     1
-- );