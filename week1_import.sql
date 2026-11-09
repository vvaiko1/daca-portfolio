-- =====================================================
-- Week 1: UrbanStyle andmete import Supabase'i
-- Autor: Vaiko Vainola
-- Kuupäev: 2026-11-09
-- Eesmärk: Laadida customers.csv, products.csv ja sales.csv
--          PostgreSQL-i õigete andmetüüpidega
-- =====================================================
-- Miks staging-tabelid?
-- sales.csv failis on 457 kuupäeva kujul DD/MM/YYYY (nt 25/01/2023),
-- ülejäänud kujul YYYY-MM-DD. Otse DATE veergu importides katkeks import.
-- Seetõttu laeti andmed esmalt TEXT-veergudega staging-tabelitesse
-- ja teisendati seejärel õigetesse andmetüüpidesse.
--
-- Andmemuudatused (audit log):
-- 1. sales.sale_date: 457 väärtust teisendati DD/MM/YYYY -> DATE
-- 2. Tühjad väärtused ('') teisendati NULL-iks (NULLIF), et
--    COUNT(*) - COUNT(veerg) annaks õige puuduvate väärtuste arvu
-- 3. Duplikaate EI eemaldatud (Nädal 2 teema)
-- =====================================================


-- -----------------------------------------------------
-- SAMM 1: Staging-tabelid (kõik veerud TEXT)
-- -----------------------------------------------------
CREATE TABLE customers_staging (
  customer_id TEXT, first_name TEXT, last_name TEXT, email TEXT, phone TEXT,
  city TEXT, registration_date TEXT, loyalty_tier TEXT, birth_year TEXT
);
CREATE TABLE products_staging (
  product_id TEXT, product_name TEXT, category TEXT, subcategory TEXT, supplier TEXT,
  cost_price TEXT, retail_price TEXT, eco_certified TEXT, created_at TEXT
);
CREATE TABLE sales_staging (
  sale_id TEXT, invoice_id TEXT, sale_date TEXT, customer_id TEXT, product_id TEXT,
  quantity TEXT, unit_price TEXT, total_price TEXT, channel TEXT,
  store_location TEXT, payment_method TEXT
);
ALTER TABLE customers_staging ENABLE ROW LEVEL SECURITY;
ALTER TABLE products_staging ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_staging ENABLE ROW LEVEL SECURITY;


-- -----------------------------------------------------
-- SAMM 2: CSV import (Supabase Table Editor, mitte SQL)
-- -----------------------------------------------------
-- Iga staging-tabeli jaoks: Insert -> Import data from CSV -> Import
-- customers.csv -> customers_staging
-- products.csv  -> products_staging
-- sales.csv     -> sales_staging


-- -----------------------------------------------------
-- SAMM 3: Lõplikud tabelid õigete andmetüüpidega
-- -----------------------------------------------------

-- customers: tühjad väärtused -> NULL, kuupäev ja aasta õigeks tüübiks
CREATE TABLE customers AS
SELECT
  customer_id::INT                         AS customer_id,
  first_name,
  last_name,
  NULLIF(email, '')                        AS email,
  NULLIF(phone, '')                        AS phone,
  NULLIF(city, '')                         AS city,
  NULLIF(registration_date, '')::DATE      AS registration_date,
  NULLIF(loyalty_tier, '')                 AS loyalty_tier,
  NULLIF(birth_year, '')::INT              AS birth_year
FROM customers_staging;

-- products: hinnad numbriteks, eco_certified tõeväärtuseks
CREATE TABLE products AS
SELECT
  product_id::INT                          AS product_id,
  product_name,
  category,
  subcategory,
  supplier,
  cost_price::NUMERIC(10,2)                AS cost_price,
  retail_price::NUMERIC(10,2)              AS retail_price,
  NULLIF(eco_certified, '')::BOOLEAN       AS eco_certified,
  created_at::DATE                         AS created_at
FROM products_staging;

-- sales: 457 kuupäeva on kujul DD/MM/YYYY -> teisendame
-- NB: sale_id ei ole primaarvõti, sest duplikaatread kordavad ka sale_id-d
CREATE TABLE sales AS
SELECT
  sale_id::INT                             AS sale_id,
  invoice_id,
  CASE
    WHEN sale_date LIKE '__/__/____' THEN TO_DATE(sale_date, 'DD/MM/YYYY')
    ELSE sale_date::DATE
  END                                      AS sale_date,
  NULLIF(customer_id, '')::INT             AS customer_id,
  product_id::INT                          AS product_id,
  quantity::INT                            AS quantity,
  unit_price::NUMERIC(10,2)                AS unit_price,
  total_price::NUMERIC(10,2)               AS total_price,
  channel,
  NULLIF(store_location, '')               AS store_location,
  payment_method
FROM sales_staging;

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;


-- -----------------------------------------------------
-- SAMM 4: Kontroll
-- -----------------------------------------------------
SELECT
  (SELECT COUNT(*) FROM customers) AS customers,  -- oodatud 3150
  (SELECT COUNT(*) FROM products)  AS products,   -- oodatud 362
  (SELECT COUNT(*) FROM sales)     AS sales;      -- oodatud 15234
-- Tulemus: customers = 3150, products = 362, sales = 15234 ✔
