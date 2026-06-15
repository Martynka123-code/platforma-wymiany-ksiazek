-- ====================================================================
-- FAZA 3: MECHANIZMY TRANSAKCYJNE I POZIOMY IZOLACJI (OSOBA 3)
-- ====================================================================

BEGIN;


SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


INSERT INTO Transakcje (Status_Transakcji, ID_Oferty_Od, ID_Oferty_Za)
VALUES ('W toku', 3, 5);


COMMIT;
