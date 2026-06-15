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


CREATE OR REPLACE PROCEDURE proc_Dodaj_Recenzje(
    p_ocena INT,
    p_tresc TEXT,
    p_id_ksiazki INT,
    p_id_uzytkownika INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Recenzje_Ksiazek(
        Wartosc,
        Tresc,
        ID_Ksiazki,
        ID_Uzytkownika
    )
    VALUES(
        p_ocena,
        p_tresc,
        p_id_ksiazki,
        p_id_uzytkownika
    );
END;
$$;


-- Użycie
-- CALL proc_Dodaj_Recenzje(
--     10,
--     'Świetna książka',
--     1,
--     1
-- );




CREATE OR REPLACE PROCEDURE proc_Zmien_Status_Oferty(
    p_id_oferty INT,
    p_id_statusu INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Oferty_Uzytkownikow
    SET ID_Statusu = p_id_statusu
    WHERE ID_Oferty = p_id_oferty;
END;
$$;

-- Użycie
-- CALL proc_Zmien_Status_Oferty(1, 2);



CREATE OR REPLACE PROCEDURE proc_Dodaj_Uzytkownika(
    p_login VARCHAR(50),
    p_haslo VARCHAR(255),
    p_email VARCHAR(100),
    p_id_roli INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Uzytkownicy(
        Login,
        Haslo,
        Email,
        ID_Roli
    )
    VALUES(
        p_login,
        p_haslo,
        p_email,
        p_id_roli
    );
END;
$$;

-- Użycie
-- CALL proc_Dodaj_Uzytkownika(
--     'nowy_user',
--     'tajnehaslo',
--     'nowy@wp.pl',
--     2
-- );



CREATE OR REPLACE PROCEDURE proc_Usun_Recenzje(
    p_id_recenzji INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Recenzje_Ksiazek
    WHERE ID_Recenzji = p_id_recenzji;
END;
$$;


-- Użycie
-- CALL proc_Usun_Recenzje(1);



CREATE OR REPLACE PROCEDURE proc_Utworz_Transakcje(
    p_id_oferty_od INT,
    p_id_oferty_za INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Transakcje(
        Status_Transakcji,
        ID_Oferty_Od,
        ID_Oferty_Za
    )
    VALUES(
        'W toku',
        p_id_oferty_od,
        p_id_oferty_za
    );
END;
$$;


-- Użycie
-- CALL proc_Utworz_Transakcje(1, 2);



CREATE OR REPLACE PROCEDURE proc_Zmien_Role_Uzytkownika(
    p_id_uzytkownika INT,
    p_id_nowej_roli INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Uzytkownicy
    SET ID_Roli = p_id_nowej_roli
    WHERE ID_Uzytkownika = p_id_uzytkownika;
END;
$$;


-- Użycie
-- CALL proc_Zmien_Role_Uzytkownika(1, 1);