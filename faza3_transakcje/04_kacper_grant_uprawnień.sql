-- Zwykły użytkownik może czytać i dodawać oceny, ale nie może ich samodzielnie usuwać z bazy (DELETE)
GRANT SELECT, INSERT ON Recenzje_Ksiazek TO Aplikacja_Konto;
GRANT SELECT, INSERT ON Oceny_Transakcji TO Aplikacja_Konto;
GRANT SELECT ON Statusy_Ofert TO Aplikacja_Konto;

-- Administrator systemu ma pełnię praw do Twoich tabel
GRANT ALL PRIVILEGES ON Recenzje_Ksiazek TO Administrator_Konto;
GRANT ALL PRIVILEGES ON Oceny_Transakcji TO Administrator_Konto;
GRANT ALL PRIVILEGES ON Statusy_Ofert TO Administrator_Konto;