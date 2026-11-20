# Puhastamisraport: customers tabel

**Autor:** Vaiko Vainola · **Roll:** B – Kliendiandmete puhastaja · **Kuupäev:** 18.11.2026
**Tabel:** `customers` (3 150 klienti) · **Test koopia:** `customers_test`

## Lühidalt

**Iga kaheksandale kliendile ei saa praegu e-kirja saata** – 380 kliendil puudub e-mail. Lisaks on 128 e-maili topelt ja 12 linna on kirjutatud 54 eri moodi. Kokku leidsin **760 probleemi**. Linnanimed sain test koopias korda; originaaltabel on puutumata.

## Leitud probleemid

| Kategooria | Leitud | Kirjeldus |
|---|---|---|
| Duplikaatsed e-mailid | **128** (130 liigset rida) | Sama e-mail mitmel kliendil; 2 e-maili esinevad 3 korda |
| NULL eesnimi | 0 | Eesnimi kõigil olemas |
| NULL perenimi | 0 | Perenimi kõigil olemas |
| Ebajärjekindlad linnanimed | **252** klienti | 12 linna 54 kirjapildis (nt `tallinn`, `TALLINN`, `Tallinn␣`) |
| NULL telefon | 0 | Kõik numbrid olemas, ühtses `+372` formaadis |
| NULL e-mail | **380** (12%) | Puudub kõigis linnades 10–17% klientidest |
| **KOKKU** | **760** | 128 + 252 + 380 |

## Enne ja pärast (test koopial)

| Kontroll | Enne | Pärast | Muudetud ridu |
|---|---|---|---|
| Ridu kokku | 3 150 | 3 150 | ühtegi ei kustutatud |
| Erinevaid linnakirjapilte | 54 | **12** | 252 |
| Vale kirjapildiga linnu | 252 | **0** | 252 |
| NULL eesnimed | 0 | 0 | 0 |
| E-mailid vales formaadis | 0 | 0 | 0 |
| Telefonid vales formaadis | 0 | 0 | 0 |
| Duplikaatseid e-maile | 128 | 128 | – (dokumenteeritud, mitte kustutatud) |

Lõppkontroll: originaaltabelis `customers` on endiselt 54 linnakirjapilti, test koopias 12 – puhastus on tehtud ainult koopial.

## Tähelepanekud

- **Duplikaadid on topeltimport, mitte uued kliendid.** Koopiatel on sama nimi (erineb ainult suur-/väiketäht või tühik, nt „Tiit Toom“ vs „tiit Toom“), sama linn ja registreerimiskuupäev, kuid uus ID.
- **Puuduvad e-mailid ei ole ühe poe probleem** – neid on kõigis 12 linnas 10–17% klientidest.
- **INITCAP töötab ka täpitähtedega:** `'pÄrnu'` → `'Pärnu'`, `'jÕHVI'` → `'Jõhvi'`.
- **0 on ka vastus.** Nimede, telefonide ja e-mailide vormingu kontrollid ei leidnud probleeme – see tähendab, et need reeglid andmestikus kehtivad.

## Soovitus Toomasele

1. **Linnanimed** – rakendada `INITCAP(TRIM(city))` ka originaaltabelile (test koopias kontrollitud, 252 rida).
2. **Puuduvad e-mailid** – küsida klientidelt uuesti; mitte asendada väljamõeldud väärtusega, sest vale e-mail on halvem kui puuduv.
3. **Duplikaatsed kliendid** – enne kustutamist otsustada, milline kirje jääb alles (nt väikseima ID-ga), ja kontrollida, kas koopiatele viitavad müügid.
4. **Ennetus** – andmesisestuses kohustuslik e-mail ja unikaalsuse kontroll, et topeltimport ei korduks.

## Kasutatud SQL

`GROUP BY` + `HAVING COUNT(*) > 1`, `COUNT(*) FILTER (WHERE …)`, `IS NULL`, `TRIM`, `INITCAP`, `LOWER`, `CASE WHEN`, `UPDATE` (ainult test koopial), `CREATE TABLE … AS SELECT`.

Kõik päringud koos tulemustega: [week2_customers_cleaning.sql](week2_customers_cleaning.sql)
