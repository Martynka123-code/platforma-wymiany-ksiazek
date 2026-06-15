CREATE USER Aplikacja_Konto WITH PASSWORD 'SilneHasloAplikacji2026!';

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO Aplikacja_Konto;

-- 3. Jawne odebranie uprawnienia DELETE (usuwanie) na wszystkich tabelach,
-- aby aplikacja nie miała fizycznej możliwości skasowania danych z bazy
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM Aplikacja_Konto;

-- 4. Nadanie uprawnień do sekwencji (Ważne dla pól typu SERIAL)
-- Aplikacja musi mieć możliwość pobierania kolejnych numerów ID (np. ID_Uzytkownika)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO Aplikacja_Konto;