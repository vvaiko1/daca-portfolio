# Nädal 1: UrbanStyle andmete uurimine (SQL põhitõed)

## Ülesanne

IT direktor Toomas Kask avastas, et UrbanStyle'i müügitabelis võib olla tuhandeid duplikaate. Enne andmete parandamist tuli olukord kaardistada: kui suur on probleem ja milliseid muid andmekvaliteedi küsimusi tabelites leidub.

Nädal koosnes kahest osast:
1. **Iseseisev töö** – sales tabeli uurimine ja kõigi tabelite import Supabase'i
2. **Grupitöö** – meeskonnaga terve andmestiku kaardistamine; minu roll oli **C: tooteandmete uurija** (products tabel)

## Kasutatud tööriistad

- PostgreSQL (Supabase)
- SQL: `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT`, `COUNT`, `MIN`/`MAX`, `GROUP BY`

## Failid

| Fail | Sisu |
|------|------|
| [week1_import.sql](week1_import.sql) | CSV failide import Supabase'i staging-tabelite kaudu |
| [week1_sales_exploration.sql](week1_sales_exploration.sql) | Sales tabeli uurimispäringud, tulemused ja kommentaarid |
| [week1_products_exploration.sql](week1_products_exploration.sql) | Grupitöö: products tabeli uurimispäringud ja kokkuvõte |
| [week1_products_screenshot.png](week1_products_screenshot.png) | Products päringute tulemused |

## Peamised leiud – sales

- **5 116 duplikaatrida (33,6%)** – sales tabelis on 15 234 rida, kuid ainult 10 118 unikaalset arvet. Praegused müügiraportid näitavad tegelikust suuremat käivet.
- **305 müüki summaga 0 või vähem** – võivad olla tagastused, testkirjed või vead; vajavad Toomase selgitust.
- **1 487 müügil (~10%) puudub kliendi ID** – neid ei saa siduda kliendiga.
- **380 kliendil (~12%) puudub e-mail** – neile ei saa saata turunduskirju.
- **457 kuupäeva vales formaadis** (DD/MM/YYYY) – teisendati impordi käigus.

## Peamised leiud – products (grupitöö, roll C)

- **362 toodet ja 9 veergu**, mis jagunevad 5 kategooriasse: meeste_riided (82), jalanõusid (73), naiste_riided (70), laste_riided (70) ja aksessuaarid (67).
- **Hinnad 13.53 € kuni 434.08 €** – kõige kallim kategooria on jalanõud, kõige odavam lasteriided.
- **Hinnad ega kategooriad ei puudu ühelgi tootel** – products on kolmest tabelist kõige puhtam.
- Kategooria nimi **"jalanõusid"** on ebatavaline kirjapilt.

## Mis üllatas

Duplikaadid on nähtavad isegi lihtsas "top 10 müüki" päringus. Lisaks selgus, et sama müük võib esineda 2–4 korda ja koopiad ei ole alati identsed: näiteks ühel koopial puudub `customer_id` või on erinev `unit_price`. Seega ei piisa puhastamisel identsete ridade eemaldamisest – tuleb otsustada, milline koopia on õige.

## Meeskonna töö

Meeskond **UrbanStyle-ladu** koondas kõigi rollide tulemused ühiseks andmemaastikuks (Data Landscape):
- [Meeskonna ühine väljund](https://docs.google.com/presentation/d/1cDonL61pHiuUrU8fz3REgoIoUOWszs03UYn5mlqV41A/edit?slide=id.p1#slide=id.p1)
- [Meeskonna repo](https://github.com/vvaiko1/UrbanStyle-ladu)

Meeskonna peamine järeldus: 40% klientidest puudub lojaalsustase ning duplikaate on nii klientide kui ka müügi tabelis. Soovitus Toomasele: eemaldada duplikaadid enne raporteid ning analüüsida veebi- ja poemüüki eraldi.

## Mida õppisin

- Alati kontrolli ridade arvu enne analüüsi – vale import muudab kõik järgmised järeldused valeks.
- `NULL` ei ole alati viga: puuduv `store_location` tähendab online-ostu.
- Tekstiväärtused vajavad ühtlustamist – 12 linna on andmetes kirjutatud 54 erineval viisil.

## Kuidas käivitada

1. Loo Supabase projektis staging-tabelid ja impordi CSV failid (`week1_import.sql`, sammud 1–2).
2. Loo lõplikud tabelid õigete andmetüüpidega (`week1_import.sql`, samm 3).
3. Kontrolli ridade arvu (samm 4): customers 3150, products 362, sales 15234.
4. Käivita päringud failidest `week1_sales_exploration.sql` ja `week1_products_exploration.sql` ükshaaval Supabase SQL Editoris.

## Järgmine samm

Nädal 2: duplikaatide täpne tuvastamine ja eemaldamine, NULL väärtuste käsitlemine.
