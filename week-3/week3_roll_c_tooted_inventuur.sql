-- =====================================================
-- Week 3: UrbanStyle Tooted + Inventuur (LEFT JOIN)
-- Autor: Vaiko Vainola
-- Kuupäev: 2026-11-25
-- Roll: C - Müümata toodete ja inventuuri analüüs
-- Eesmärk: Leida müümata ja enim müüdud tooted, analüüsida
--          kategooriaid ja laoseisu ning koostada inventuuri
--          soovitused Annale ja Toomasele.
-- Tabelid: products, sales, inventory
-- NB: sales on puhastatud (W3 Samm 0: duplikaadid eemaldatud,
--     10 118 rida).
-- =====================================================


-- =====================================================
-- EELKONTROLL: inventory tabel on imporditud
-- =====================================================
SELECT COUNT(*) FROM inventory;
-- Tulemus: 1400 rida (350 toodet x 4 asukohta)


-- =====================================================
-- SAMM 2: Tooted, mida pole kunagi müüdud
-- =====================================================
SELECT
    p.product_name,
    p.category,
    p.subcategory,
    p.retail_price,
    s.sale_id
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL;
-- Tulemus: 12 toodet (5 aksessuaarid, 2 jalanõusid, 2 naiste_riided,
-- 2 laste_riided, 1 meeste_riided) - kõik on W1 leitud duplikaattooted


-- =====================================================
-- SAMM 3: Müümata tooted kokku
-- =====================================================
SELECT COUNT(*) AS müümata_tooteid
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
WHERE s.sale_id IS NULL;
-- Tulemus: 12 toodet - kõik on W1 duplikaatkoopiad (ID 1351-1362)


-- =====================================================
-- SAMM 4: Enim müüdud tooted (TOP 10 kogumüügi järgi)
-- =====================================================
SELECT
    p.product_name,
    p.category,
    p.subcategory,
    COUNT(s.sale_id) AS müüdud_kordi,
    SUM(s.total_price) AS kogumüük
FROM products p
INNER JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name, p.category, p.subcategory
ORDER BY kogumüük DESC
LIMIT 10;
-- Tulemus: #1 Õhuline sünteetiline sporditossud - 35 müüki, 27 347,04 €


-- =====================================================
-- SAMM 5: Analüüs kategooriate kaupa
-- =====================================================
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) AS tooteid,
    COUNT(s.sale_id) AS müüke,
    SUM(s.total_price) AS kogumüük
FROM products p
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY kogumüük DESC;
-- Tulemus:
--   jalanõusid      774 034,75 €
--   meeste_riided   749 798,72 €
--   naiste_riided   686 464,24 €
--   aksessuaarid    393 035,82 €
--   laste_riided    305 844,45 €
--   (müüke kokku 10 118)


-- =====================================================
-- SAMM 6: Ühenda inventuuriga - millised tooted on laos?
-- =====================================================
SELECT
    p.product_name,
    p.category,
    i.location,
    i.quantity_available,
    i.reorder_point,
    CASE
        WHEN i.quantity_available <= i.reorder_point THEN 'TELLI JUURDE'
        ELSE 'OK'
    END AS staatus
FROM products p
LEFT JOIN inventory i ON p.product_id = i.product_id
ORDER BY i.quantity_available ASC;
-- Tulemus: 1412 rida (1400 laorida + 12 laoseisuta toodet)
--   - 231 TELLI JUURDE, neist 10 NEGATIIVSE laoseisuga (-46 ... -7)
--     ja 7 laoseisuga 0
--   - 40 rida ebareaalselt suure laoseisuga (üle 500, max 9985);
--     tavaline laoseis on poes kuni 150, laos kuni ~500
--   - 12 laoseisuta toodet (ID 1351-1362) on nimekirja lõpus
--     staatusega 'OK', sest NULL <= reorder_point ei ole tõene


-- =====================================================
-- EDASIJÕUDNUTE TASE: laos, aga pole kunagi müüdud
-- (topelt kahju: laoseis + müümata)
-- =====================================================
SELECT
    p.product_name,
    p.category,
    p.retail_price,
    i.quantity_available,
    (p.retail_price * i.quantity_available) AS kinni_olev_raha
FROM products p
LEFT JOIN sales s     ON p.product_id = s.product_id
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE s.sale_id IS NULL
  AND i.quantity_available > 0
ORDER BY kinni_olev_raha DESC;
-- Tulemus: 0 rida - müümata tooteid laos ei ole, raha pole kinni

-- Tõend, et 0 on õige (sama päring ilma laoseisu filtrita)
SELECT
    p.product_id,
    p.product_name,
    i.quantity_available
FROM products p
LEFT JOIN sales s     ON p.product_id = s.product_id
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE s.sale_id IS NULL;
-- Tulemus: 12 rida, quantity_available = NULL kõigil -> laos neid pole


-- =====================================================
-- SAMM 8: INVENTUURI SOOVITUSED (Annale ja Toomasele)
-- =====================================================
-- 1. Müümata tooted: 12 toodet pole kunagi müüdud, kuid need ei ole
--    ebapopulaarsed tooted - need on W1 leitud duplikaatkirjed
--    (ID 1351-1362), millel puudub ka laoseis. Soovitus: eemaldada
--    kataloogist kui andmeviga, mitte allahinnata.
-- 2. Juurde tellimine: 231 toote-asukoha real on laoseis tellimispunktis
--    või alla selle, neist 7 on täiesti otsas - need tuleks kohe
--    juurde tellida.
-- 3. Laoandmete kvaliteet: 10 real on laoseis negatiivne (võimatu) ja
--    40 real ebareaalselt suur (kuni 9985) - enne tellimisotsuseid
--    tuleks need read inventuuriga üle kontrollida.
-- 4. Kategooriad: kõige edukam on jalanõud (774 035 €), kõige väiksema
--    müügituluga lasteriided (305 844 €), kuigi müükide arv on teiste
--    kategooriatega sarnane - lasteriiete hinnad on madalamad.
-- 5. Bestseller: Õhuline sünteetiline sporditossud (27 347 €) - see on
--    kataloogi kalleim toode (434,08 €), seega tasub ka kallis toode
--    hoida hästi laos.
-- 6. Kinni olevat raha müümata toodetes ei ole (edasijõudnute päring: 0).
-- =====================================================
