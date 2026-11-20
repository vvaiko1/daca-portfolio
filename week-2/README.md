# Nädal 2: UrbanStyle andmete puhastamine (SQL)

## Ülesanne

Nädal 1 näitas, et UrbanStyle'i andmetes on tuhandeid duplikaate, puuduvaid väärtusi ja ebaühtlaseid kirjapilte. CEO Kristi Tamm vajab juhatuse koosolekuks puhtaid numbreid ja IT direktor Toomas Kask andis reegli: **test koopia kõigepealt, siis puhasta, siis kontrolli, siis dokumenteeri.**

Nädal koosnes kahest osast:
1. **Iseseisev töö** – töövihiku harjutused: duplikaadid (`GROUP BY` + `HAVING`, `ROW_NUMBER()`), NULL väärtused (`IS NULL`, `COALESCE`) ja formaadid (`TRIM`, `INITCAP`, `TO_CHAR`)
2. **Grupitöö** – iga liige puhastas ühte andmedomeeni; minu roll oli **B: kliendiandmete puhastaja** (customers tabel)

## Kasutatud tööriistad

- PostgreSQL (Supabase)
- SQL: `GROUP BY` + `HAVING`, `COUNT(*) FILTER`, `IS NULL`, `TRIM`, `INITCAP`, `LOWER`, `CASE WHEN`, `UPDATE`, `CREATE TABLE … AS SELECT`

## Failid

| Fail | Sisu |
|------|------|
| [week2_customers_cleaning.sql](individual/week2_customers_cleaning.sql) | Kliendiandmete puhastamisskript koos tulemuste ja kokkuvõttega |
| [week2_customers_report.md](individual/week2_customers_report.md) | Puhastamisraport: leitud probleemid ja enne/pärast tabel |

## Peamised leiud – customers (roll B)

- **760 probleemi 3 150 kliendi kohta.**
- **380 kliendil (12%) puudub e-mail** – iga kaheksandale kliendile ei saa e-kirja saata.
- **128 duplikaatset e-maili** (130 liigset rida) – nimed on samad, erineb ainult kirjapilt, seega on tegu topeltimpordiga.
- **12 linna on kirjutatud 54 eri moodi** (252 klienti) – test koopias ühtlustasin need `INITCAP(TRIM(city))` abil 12 linnaks.
- Nimed ja telefoninumbrid on kõigil olemas; telefonid on ühtses `+372` formaadis.

## Iseseisev töö – olulisemad numbrid

- Sales tabelis on 15 234 rida, kuid ainult 10 118 unikaalset müüki – **duplikaatidega käive 4,37 M €, ilma nendeta 2,91 M €** (vahe 1,47 M €).
- 50 müügi kuupäev on pärast andmete eeldatavat lõppu (28.02.2025).

## Mis üllatas

Et duplikaatsed kliendid ei ole erinevad inimesed, vaid sama kirje uuesti imporditud – sama linn, sama registreerimiskuupäev, ainult nimi on kirjutatud teise suur-/väiketähega. Ja et kolmandik müügikäibest on tegelikult duplikaadid.

## Meeskonna töö

Meeskond **UrbanStyle-ladu** (rollid A – müük, B – kliendid, C – tooted) koondas tulemused ühiseks andmekvaliteedi koondraportiks:
- [Meeskonna ühine esitlus](https://docs.google.com/presentation/d/1SqgwirUYRVrINoIISpwbw5F_c36T5BGmVnEWv5necPE/edit)
- [Meeskonna nädala 2 README](https://github.com/vvaiko1/UrbanStyle-ladu/tree/main/week-2)

Meeskonna peamine järeldus: müügi- ja kliendiandmed vajavad korrastamist, enne kui juhtkond ja investorid saavad nende põhjal otsuseid teha – kolmandik käibest on duplikaadid.

## Mida õppisin

- **Test koopia enne muutmist** – `CREATE TABLE … AS SELECT`; originaal jääb puutumata ja vea korral saab koopia uuesti luua.
- **Kontrolli enne ja pärast** – Supabase ei näita, mitu rida `UPDATE` muutis, seega loen probleemid enne ja pärast muudatust kokku.
- **0 on ka tulemus** – kontroll, mis midagi ei leia, kinnitab, et reegel andmetes kehtib.
- **Duplikaadi definitsioon on otsus** – e-maili, nime või ID järgi otsides saab erinevaid vastuseid.

## Kuidas käivitada

1. Ava Supabase projektis SQL Editor (eeldab, et `customers` tabel on imporditud – vt [nädal 1](../week-1/)).
2. Käivita [week2_customers_cleaning.sql](individual/week2_customers_cleaning.sql) päringud ükshaaval ülevalt alla.
3. Kõik `UPDATE` laused muudavad ainult test koopiat `customers_test`; viimane päring kontrollib, et originaal on puutumata (54 vs 12 linna).

## Järgmine samm

Nädal 3: JOIN-id – tabelite ühendamine. Enne seda tuleb valideeritud puhastus viia originaaltabelitesse (W3 töövihiku „Samm 0“).
