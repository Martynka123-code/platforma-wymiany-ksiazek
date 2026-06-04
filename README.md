# Platforma Wymiany Książek

Projekt zespołowy realizowany w ramach laboratorium z przedmiotu **Bazy Dane**. System umożliwia użytkownikom rejestrację, katalogowanie posiadanych zbiorów literackich, wystawianie ofert wymiany oraz realizację i ocenę transakcji barterowych książek.

Baza danych została zaprojektowana i zaimplementowana w systemie zarządzania bazą danych **PostgreSQL (psql)** z zachowaniem zasad trzeciej postaci normalnej (3NF).

---

## Skład Zespołu i Podział Zadań

Projekt został podzielony na 4 niezależne moduły funkcjonalne:

*   **Osoba 1 (Martyna): Moduł Użytkowników**
    *   Implementacja struktury tabel `Role` oraz `Uzytkownicy`.
    *   Wyzwalacz (Trigger) walidujący poprawność adresów e-mail (obecność `@`).
    *   Konfiguracja bezpieczeństwa bazy danych (DCL - uprawnienia dla konta aplikacji).
    *   Agregacje danych z użyciem złączeń do celów statystycznych.
*   **Osoba 2 (Agata): Moduł Katalogu Książek** (Tabele: `Autorzy`, `Wydawnictwa`, `Kategorie`, `Ksiazki`; Widok pełnego katalogu; Trigger modyfikujący wielkość liter tytułów; Transakcje ACID).
*   **Osoba 3 (Damian): Moduł Ofert i Transakcji** (Tabele: `Statusy_Ofert`, `Oferty_Uzytkownikow`, `Transakcje`; Zapytania zagnieżdżone; Trigger automatycznej zmiany statusu oferty; Poziomy izolacji transakcji).
*   **Osoba 4 (Kacper): Moduł Społecznościowy i Dokumentacja** (Tabele: `Oceny_Transakcji`, `Recenzje_Ksiazek`; Widok rankingu; Diagram ERD; Analiza 3NF oraz scalenie dokumentacji końcowej).

---

## Struktura Projektu

Repozytorium zorganizowane jest w sposób odzwierciedlający fazy rozwojowe projektu oraz hierarchię zależności tabel (od słowników po tabele relacji):

```text
platforma-wymiany-ksiazek/
│
├── faza1_struktura/          # Schematy DDL oraz skrypty inicjalizujące dane (DML)
│   ├── 01_schema_uzytkownicy.sql
│   ├── 02_data_uzytkownicy.sql
│   └── ...                   # Pliki pozostałych członków zespołu
│
├── faza2_zaawansowane/       # Widoki, zapytania analityczne, funkcje i wyzwalacze (PL/pgSQL)
│   ├── osoba1_logika.sql
│   └── ...
│
├── faza3_bezpieczenstwo/    # Zarządzanie uprawnieniami (DCL) oraz transakcje zaawansowane
│   ├── osoba1_uprawnienia.sql
│   └── ...
│
├── README.md                 # Dokumentacja główna repozytorium
└── main.sql                  # Scalony, kompletny skrypt instalacyjny bazy danych
```

---

## Porządek Implementacji (Hierarchia Tabel)

Podczas scalania i uruchamiania skryptu głównego `main.sql`, polecenia muszą być wykonywane w ściśle określonej kolejności ze względu na powiązania kluczami obcymi (`FOREIGN KEY`):

1.  **Poziom 0 (Słowniki):** `Role`, `Autorzy`, `Wydawnictwa`, `Kategorie`, `Statusy_Ofert`.
2.  **Poziom 1 (Zależne bezpośrednie):** `Uzytkownicy` *(wymaga tabeli Role)*, `Ksiazki`.
3.  **Poziom 2 (Operacyjne):** `Oferty_Uzytkownikow`.
4.  **Poziom 3 (Transakcyjne i Opinie):** `Transakcje`, `Recenzje_Ksiazek`.
5.  **Poziom 4 (Oceny końcowe):** `Oceny_Transakcji`.

---
