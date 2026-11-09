# Nädal 1: UrbanStyle Sales Tabeli Uurimine

## Ülesanne

IT direktor Toomas Kask avastas, et UrbanStyle'i müügitabelis võib olla tuhandeid duplikaate. Enne andmete parandamist tuli olukord kaardistada: kui suur on probleem ja milliseid muid andmekvaliteedi küsimusi tabelites leidub.

## Kasutatud tööriistad

- PostgreSQL (Supabase)
- SQL: `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT`, `COUNT`

## Failid

| Fail | Sisu |
|------|------|
| [week1_import.sql](week1_import.sql) | CSV failide import Supabase'i staging-tabelite kaudu |
| [week1_sales_exploration.sql](week1_sales_exploration.sql) | Uurimispäringud, tulemused ja kommentaarid |

## Peamised leiud

- **5 116 duplikaatrida (33,6%)** – sales tabelis on 15 234 rida, kuid ainult 10 118 unikaalset arvet. Praegused müügiraportid näitavad tegelikust suuremat käivet.
- **305 müüki summaga 0 või vähem** – võivad olla tagastused, testkirjed või vead; vajavad Toomase selgitust.
- **1 487 müügil (~10%) puudub kliendi ID** – neid ei saa siduda kliendiga.
- **380 kliendil (~12%) puudub e-mail** – neile ei saa saata turunduskirju.
- **457 kuupäeva vales formaadis** (DD/MM/YYYY) – teisendati impordi käigus.

## Mis üllatas

Duplikaadid on nähtavad isegi lihtsas "top 10 müüki" päringus – sama müük esineb kaks korda. See näitas, et ilma puhastuseta ei saa usaldada ühtegi müüginumbrit.

## Kuidas käivitada

1. Loo Supabase projektis staging-tabelid ja impordi CSV failid (`week1_import.sql`, sammud 1–2).
2. Loo lõplikud tabelid õigete andmetüüpidega (`week1_import.sql`, samm 3).
3. Kontrolli ridade arvu (samm 4): customers 3150, products 362, sales 15234.
4. Käivita päringud failist `week1_sales_exploration.sql` ükshaaval Supabase SQL Editoris.

## Järgmine samm

Nädal 2: duplikaatide täpne tuvastamine ja eemaldamine, NULL väärtuste käsitlemine.
