-- Tworzenie ról systemowych (Dodano Administratora)
DROP ROLE IF EXISTS Aplikacja_Konto;
DROP ROLE IF EXISTS Administrator_Konto;

CREATE ROLE Aplikacja_Konto LOGIN PASSWORD 'SilneHasloAplikacji2026!';
CREATE ROLE Administrator_Konto LOGIN PASSWORD 'SuperAdmin2026!';

-- Uprawnienia dla Aplikacji (Kod Martyny)
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO Aplikacja_Konto;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM Aplikacja_Konto;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO Aplikacja_Konto;