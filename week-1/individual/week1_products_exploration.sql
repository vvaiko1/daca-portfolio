-- =====================================================
-- Week 1: UrbanStyle Products Tabeli Uurimine
-- Autor: Vaiko Vainola
-- Kuupäev: 2026-11-11
-- Roll: C - Tooteandmete uurija (Product Data Explorer)
-- Eesmärk: Vastata Toomas Kaski küsimusele - millised tooted on
--          UrbanStyle'i sortimendis ja mis seisus on tooteandmed?
-- Tabel: products (meeskonna Supabase projekt)
-- =====================================================


-- Mitu toodet on kokku?
SELECT COUNT(*) AS toodete_arv FROM products; -- 362

-- Millised veerud ja andmed tabelis on?
SELECT * FROM products LIMIT 10; -- product_id, product_name, category, subcategory, supplier, cost_price, retail_price, eco_certified, created_at

-- Kõik unikaalsed tootekategooriad
SELECT DISTINCT category FROM products; -- 5: aksessuaarid, jalanõusid, laste_riided, meeste_riided, naiste_riided

-- 10 kõige kallimat toodet
SELECT product_name, category, retail_price
FROM products ORDER BY retail_price DESC LIMIT 10;
-- Tulemus: kõige kallim toode 434.08 EUR (jalanõusid)

-- 10 kõige odavamat toodet
SELECT product_name, category, retail_price
FROM products ORDER BY retail_price ASC LIMIT 10;
-- Tulemus: kõige odavam toode 13.53 EUR (aksessuaarid)

-- Naisteriiete tooted hinna järgi
SELECT * FROM products
WHERE category = 'naiste_riided'
ORDER BY retail_price DESC;
-- Tulemus: 70 toodet

-- Puuduvad hinnad
SELECT COUNT(*) - COUNT(retail_price) AS puuduvad_hinnad FROM products;
-- Tulemus: 0

-- Puuduvad kategooriad
SELECT COUNT(*) - COUNT(category) AS puuduvad_kategooriad FROM products;
-- Tulemus: 0

-- Tooted ja hinnavahemik kategooriati
SELECT category, COUNT(*) AS toodete_arv,
       MIN(retail_price) AS min_hind, MAX(retail_price) AS max_hind
FROM products
GROUP BY category
ORDER BY max_hind DESC;
-- Tulemus:
--   jalanõusid     73   58.49  434.08
--   meeste_riided  82   48.85  374.54
--   naiste_riided  70   32.93  351.33
--   aksessuaarid   67   13.53  231.13
--   laste_riided   70   22.70  168.82

-- Naisteriiete tooted üle 50 EUR
SELECT * FROM products
WHERE retail_price > 50 AND category = 'naiste_riided'
ORDER BY retail_price DESC;
-- Tulemus: 67 toodet 70-st


-- =====================================================
-- KOKKUVÕTE
-- =====================================================
-- Products tabelis on 362 toodet ja 9 veergu, mis jagunevad
-- 5 kategooriasse: meeste_riided (82), jalanõusid (73),
-- naiste_riided (70), laste_riided (70) ja aksessuaarid (67).
-- Hinnad jäävad vahemikku 13.53 EUR (aksessuaarid) kuni
-- 434.08 EUR (jalanõud); kõige kallim kategooria on jalanõud,
-- kõige odavam lasteriided.
-- Hinnad ega kategooriad ei puudu ühelgi tootel.
-- Kategooria nimi "jalanõusid" on ebatavaline kirjapilt
-- (oodatav oleks "jalanõud").
--
-- Toomasele: tooteandmed on kolmest tabelist kõige puhtamad ja
-- sobivad analüüsiks; suurim probleem on mujal (sales duplikaadid).
-- =====================================================
