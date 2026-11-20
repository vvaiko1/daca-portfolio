-- =====================================================
-- Week 2: UrbanStyle Customers Tabeli Puhastamine
-- Autor: Vaiko Vainola
-- Kuupäev: 2026-11-18
-- Roll: B - Kliendiandmete puhastaja (Customer Data Cleaner)
-- Eesmärk: Leida customers tabelist duplikaadid, NULL väärtused
--          ja ebajärjekindlad linnanimed; puhastada test koopial
--          ja dokumenteerida tulemused Toomas Kaskile.
-- Tabel: customers (meeskonna Supabase projekt)
-- NB: kõik muudatused (UPDATE) on tehtud AINULT test koopial
--     customers_test - originaaltabel customers on puutumata.
-- =====================================================


-- =====================================================
-- SAMM 1: Test koopia
-- =====================================================
DROP TABLE IF EXISTS customers_test;
CREATE TABLE customers_test AS SELECT * FROM customers;
SELECT COUNT(*) AS ridade_arv FROM customers_test;
-- Tulemus: 3150 rida


-- =====================================================
-- SAMM 2: Duplikaatsed e-mailid
-- =====================================================
SELECT email, COUNT(*) AS koopiate_arv
FROM customers_test
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY koopiate_arv DESC;
-- Tulemus: 128 duplikaatset e-maili -> 130 liigset rida,
-- sest 2 e-maili esinevad 3 korda (ülejäänud 2 korda).
-- Koopiatel on sama nimi (erineb ainult suur-/väiketäht või tühik),
-- sama linn ja registreerimiskuupäev -> tõenäoliselt topeltimport.


-- =====================================================
-- SAMM 3: Puuduvad nimed
-- =====================================================
SELECT
    COUNT(*) FILTER (WHERE first_name IS NULL OR first_name = '') AS null_eesnimi,
    COUNT(*) FILTER (WHERE last_name IS NULL OR last_name = '') AS null_perenimi
FROM customers_test;
-- Tulemus: 0 ja 0 - nimed on kõigil klientidel olemas


-- =====================================================
-- SAMM 4: Linnade nimekujud
-- =====================================================
SELECT city, COUNT(*) AS arv
FROM customers_test
GROUP BY city
ORDER BY city;
-- Tulemus: 54 rida = 12 linna kirjutatud 54 eri moel
-- (nt Tallinn, tallinn, TALLINN, 'Tallinn ', ' Tallinn')

-- Mitu klienti on vale kirjapildiga linnaga?
SELECT COUNT(*) AS vale_kirjapildiga
FROM customers_test
WHERE city != INITCAP(TRIM(city));
-- Tulemus: 252 klienti

-- Kas INITCAP töötab täpitähtedega?
SELECT INITCAP(TRIM('pÄrnu'))     AS test1,
       INITCAP(TRIM('  PÄRNU '))  AS test2,
       INITCAP(TRIM('jÕHVI'))     AS test3;
-- Tulemus: Pärnu, Pärnu, Jõhvi - töötab

-- Kaardi vihje: linnad, mis esinevad rohkem kui korra
SELECT city, COUNT(*) FROM customers_test
GROUP BY city HAVING COUNT(*) > 1;


-- =====================================================
-- SAMM 5: Puuduvad kontaktandmed
-- =====================================================
SELECT
    COUNT(*) FILTER (WHERE phone IS NULL OR phone = '') AS null_telefon,
    COUNT(*) FILTER (WHERE email IS NULL OR email = '') AS null_email
FROM customers_test;
-- Tulemus: 0 telefoni puudu, 380 e-maili puudu (12% klientidest)


-- =====================================================
-- EDASIJÕUDNUTE TASE: puhastamine test koopial
-- Muster: kontroll enne -> UPDATE -> kontroll pärast
-- =====================================================

-- 1) Puuduvad eesnimed -> 'Tundmatu'
UPDATE customers_test
SET first_name = 'Tundmatu'
WHERE first_name IS NULL OR first_name = '';
-- Tulemus: muudeti 0 rida, sest eesnimed olid kõigil olemas

-- Kontroll
SELECT
    COUNT(*) FILTER (WHERE first_name IS NULL OR first_name = '') AS veel_puudu,
    COUNT(*) FILTER (WHERE first_name = 'Tundmatu') AS tundmatu
FROM customers_test;
-- Tulemus: 0 ja 0


-- 2) Linnanimed -> INITCAP + TRIM
-- Kontroll enne
SELECT COUNT(*) AS vale_kirjapilt FROM customers_test WHERE city != INITCAP(TRIM(city));
-- Tulemus: 252

UPDATE customers_test
SET city = INITCAP(TRIM(city))
WHERE city != INITCAP(TRIM(city));
-- Tulemus: muudeti 252 rida

-- Kontroll pärast
SELECT COUNT(*) AS vale_kirjapilt FROM customers_test WHERE city != INITCAP(TRIM(city));
-- Tulemus: 0

SELECT city, COUNT(*) AS arv
FROM customers_test
GROUP BY city ORDER BY arv DESC;
-- Tulemus: 12 linna - Tallinn 1238, Tartu 658, Pärnu 346, Narva 177,
-- Viljandi 112, Rakvere 107, Kuressaare 98, Valga 94, Haapsalu 90,
-- Jõhvi 83, Võru 81, Paide 66 (kokku 3150 - ühtegi rida ei kadunud)


-- 3) E-mailid -> väiketähed, tühikuteta
-- Kontroll enne
SELECT COUNT(*) AS vajab_parandust
FROM customers_test
WHERE email != LOWER(TRIM(email));
-- Tulemus: 0 - e-mailid on juba korras

UPDATE customers_test
SET email = LOWER(TRIM(email))
WHERE email != LOWER(TRIM(email));
-- Tulemus: muudeti 0 rida

-- Kontroll: duplikaatsete e-mailide arv ei muutunud
SELECT COUNT(*) FROM (
    SELECT email FROM customers_test
    WHERE email IS NOT NULL
    GROUP BY email HAVING COUNT(*) > 1
) t;
-- Tulemus: 128 (sama mis enne)


-- 4) Telefoninumbrid -> CASE WHEN standardiseerimine (ainult SELECT)
SELECT phone,
    CASE
        WHEN phone LIKE '+372%' THEN phone
        WHEN phone LIKE '372%' THEN '+' || phone
        WHEN LENGTH(phone) = 7 THEN '+372' || phone
        ELSE phone
    END AS standardne_telefon
FROM customers_test
WHERE phone IS NOT NULL
LIMIT 10;
-- Tulemus: standardne_telefon = phone kõigil ridadel

-- Kontroll: mitu numbrit muutuks?
SELECT COUNT(*) AS muutuks
FROM customers_test
WHERE phone NOT LIKE '+372%';
-- Tulemus: 0 - kõik 3150 numbrit on juba +372 formaadis


-- =====================================================
-- LÕPPKONTROLL: originaaltabel on puutumata
-- =====================================================
SELECT
    (SELECT COUNT(DISTINCT city) FROM customers)      AS originaal_linnad,
    (SELECT COUNT(DISTINCT city) FROM customers_test) AS test_linnad;
-- Tulemus: 54 ja 12 - puhastatud on ainult test koopia


-- =====================================================
-- KOKKUVÕTE
-- =====================================================
-- Customers tabelis on 3150 klienti. Leidsin 760 probleemi:
--   - 128 duplikaatset e-maili (130 liigset rida); nimed on samad,
--     seega on tegu topeltimpordi, mitte erinevate klientidega
--   - 380 kliendil (12%) puudub e-mail
--   - 252 kliendi linn on vale kirjapildiga (54 kirjapilti, 12 linna)
-- Nimed ja telefoninumbrid on kõigil olemas ja telefonid ühtses formaadis.
--
-- Test koopias ühtlustasin linnanimed INITCAP(TRIM(city)) abil:
-- 54 kirjapilti -> 12 linna, 252 rida muudetud, ridu ei kadunud.
--
-- Toomasele: linnanimed saab kohe SQL-iga parandada, kuid 380
-- puuduvat e-maili tuleb klientidelt uuesti küsida - vale e-mail
-- oleks halvem kui puuduv. Duplikaatsete klientide eemaldamiseks
-- tuleb enne otsustada, milline kirje jääb alles (nt väikseim ID).
-- =====================================================
