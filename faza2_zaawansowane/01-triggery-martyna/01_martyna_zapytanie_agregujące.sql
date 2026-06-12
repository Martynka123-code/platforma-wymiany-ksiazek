SELECT 
    u.ID_Uzytkownika,
    u.Login,
    u.Email,
    COUNT(o.ID_Oferty) AS Laczna_Liczba_Ofert
FROM Uzytkownicy u
LEFT JOIN Oferty_Uzytkownikow o ON u.ID_Uzytkownika = o.ID_Uzytkownika
GROUP BY u.ID_Uzytkownika, u.Login, u.Email
ORDER BY Laczna_Liczba_Ofert DESC, u.ID_Uzytkownika ASC;