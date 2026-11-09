-- =====================================================
-- Week 1: UrbanStyle Sales Tabeli Uurimine
-- Autor: Vaiko Vainola
-- Kuupäev: 2026-11-09
-- Eesmärk: Vastata Toomas Kaski küsimustele sales tabeli kohta
-- Tabelid: sales, products, customers (import: week1_import.sql)
-- =====================================================


-- 1. Mitu rida on sales tabelis kokku?
SELECT COUNT(*) AS kogu_read
FROM sales;
-- Tulemus: 15 234 rida
-- Kommentaar: Lähtepunkt, millega võrrelda unikaalsete arvete arvu.


-- 2. Mitu unikaalset arvet (invoice_id) on?
SELECT COUNT(DISTINCT invoice_id) AS unikaalseid_arveid
FROM sales;
-- Tulemus: 10 118 unikaalset arvet
-- Duplikaatide arv: 15 234 - 10 118 = 5 116 rida (33,6% kõigist ridadest)
-- Kommentaar: Ligikaudu kolmandik müügiridadest on duplikaadid.
-- Kui neid käibe arvutamisel ei eemaldata, on müügitulemus
-- oluliselt üle hinnatud. Investoritele selliste numbritega minna
-- oleks suur risk.


-- 3. Millised müügikanalid on andmetes?
SELECT DISTINCT channel
FROM sales;
-- Tulemus: 2 väärtust - 'online' ja 'pood'
-- Kommentaar: Väärtused on ühtlased (ei esine 'Online', 'ONLINE' vms).
-- NB: kursusematerjal nimetab poemüüki kohati 'store', andmetes on 'pood'.


-- 4. Mitu müüki on summaga 0 või negatiivne?
SELECT COUNT(*) AS kahtlased_summad
FROM sales
WHERE total_price <= 0;
-- Tulemus: 305 rida
-- Kommentaar: Võivad olla tagastused, testkirjed või importimise vead.
-- Nädal 1-s neid ei parandata - küsimus Toomasele: mida need read tähendavad?


-- 5. Kõige suuremad müügid
SELECT sale_id, invoice_id, sale_date, total_price, channel, store_location
FROM sales
ORDER BY total_price DESC
LIMIT 10;
-- Suurim müük: 2170.40 EUR, kuupäev: 2023-07-08 (sale_id 2407, online)
-- Kommentaar: Top 10 summad langevad ühtlaselt (2170 -> ~1859 EUR),
-- ükski rida ei ole teistest kahtlaselt palju suurem.
-- Duplikaadid on näha ka siin: sale_id 2407 ja 8379 esinevad mõlemad
-- kaks korda. Ilma puhastuseta ei saa isegi "top 10 müüki" usaldada.
-- (Täpsem vaade duplikaatidele: päring 9.)


-- 6. Müügid üle 500 EUR
SELECT COUNT(*) AS suured_muugid
FROM sales
WHERE total_price > 500;
-- Tulemus: 2 499 müüki üle 500 EUR (~16% kõigist ridadest)
-- Kommentaar: See arv sisaldab ka duplikaate, seega tegelik
-- suurte müükide arv on väiksem. Täpne arv selgub pärast
-- duplikaatide eemaldamist (Nädal 2).


-- 7. Puuduvad kliendi ID-d müügis
SELECT COUNT(*) - COUNT(customer_id) AS null_kliendid
FROM sales;
-- Tulemus: 1 487 rida ilma kliendi ID-ta (~10% kõigist ridadest)
-- Kommentaar: Neid müüke ei saa siduda kliendiga (oluline lojaalsusanalüüsiks).


-- 8. Puuduvad e-mailid klientide tabelis
SELECT COUNT(*) - COUNT(email) AS puuduvad_emailid
FROM customers;
-- Tulemus: 380 klienti 3 150-st (~12%) on ilma e-mailita
-- Kommentaar: Neile kliendidele ei saa saata turunduskirju -
-- oluline Anna Metsale kampaaniate planeerimisel.


-- 9. Millised read on duplikaadid?
-- Sorteerime invoice_id järgi, et sama arve read satuksid kõrvuti
SELECT sale_id, invoice_id, sale_date, customer_id, total_price
FROM sales
ORDER BY invoice_id, sale_id
LIMIT 30;
-- Tulemus: duplikaadid on kõrvuti nähtavad juba esimestes ridades:
--   sale_id 2 (INV-202301-00002) esineb 2 korda
--   sale_id 3 (INV-202301-00003) esineb 4 korda
-- Kommentaar: Duplikaadid ei ole ainult paarid - üks müük võib
-- esineda ka 3-4 korda.

-- Näide: suurim müük top 10-st
SELECT *
FROM sales
WHERE sale_id = 2407;
-- Tulemus: 2 rida, kuid need EI OLE täpselt identsed:
-- ühel real on customer_id = 2073, teisel puudub (NULL).
-- Ka sale_id 3 puhul erineb üks koopia: unit_price 258.46 vs 221.19.
-- Kommentaar: Osa duplikaate on "peaaegu duplikaadid" - sama müük,
-- aga mõni väli erineb. Neid ei saa eemaldada lihtsalt identsete
-- ridade otsimisega; Nädal 2-s tuleb otsustada, milline koopia jätta.


-- =====================================================
-- KOKKUVÕTE TOOMAS KASELE
-- =====================================================
-- Sales tabelis on 15 234 rida, kuid ainult 10 118 unikaalset arvet.
-- See tähendab, et 5 116 rida (33,6%) on duplikaadid ning praegused
-- müügiraportid näitavad tegelikust suuremat käivet. Sama müük võib
-- esineda 2-4 korda ja koopiad võivad erineda (nt puuduv customer_id
-- või erinev unit_price), seega puhastus vajab reeglit, milline
-- koopia on õige.
-- Lisaks on 305 müüki summaga 0 või vähem, mis vajavad selgitust,
-- 1 487 müügil (~10%) puudub kliendi ID ning 380 kliendil (~12%)
-- puudub e-mail.
--
-- Järgmine samm: Nädal 2-s duplikaatide täpsem tuvastamine ja
-- puhastamise loogika. Enne aruannete koostamist tuleb duplikaadid eemaldada.
-- =====================================================
