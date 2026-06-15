-- Zwykły użytkownik może czytać i dodawać oceny, ale nie może ich samodzielnie usuwać z bazy (DELETE)
GRANT SELECT, INSERT ON Recenzje_Ksiazek TO uzytkownik_aplikacji;
GRANT SELECT, INSERT ON Oceny_Transakcji TO uzytkownik_aplikacji;
GRANT SELECT ON Statusy_Ofert TO uzytkownik_aplikacji;

-- Administrator systemu ma pełnię praw do Twoich tabel
GRANT ALL PRIVILEGES ON Recenzje_Ksiazek TO administrator_systemu;
GRANT ALL PRIVILEGES ON Oceny_Transakcji TO administrator_systemu;
GRANT ALL PRIVILEGES ON Statusy_Ofert TO administrator_systemu;