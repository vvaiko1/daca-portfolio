# Nädal 3: Tabelite ühendamine (SQL JOIN-id)

## Ülesanne

Turundusjuht Anna Mets vaatas puhastatud müügitabelit ja ütles: *„Ma näen ainult numbreid – customer_id, product_id, summasid. Ma tahan teada: KES on meie parimad kliendid? MIDA nad ostavad? Mis ei müü?“*

Vastused on olemas, aga eri tabelites: kliendi nimi on `customers` tabelis, toote nimi `products` tabelis, müügid `sales` tabelis ja laoseis `inventory` tabelis. Nädala teema oli need JOIN-ide abil kokku panna.

Nädal koosnes kahest osast:
1. **Iseseisev töö** – W2 puhastuse viimine originaaltabelitesse ning töövihiku harjutused: `INNER JOIN`, `LEFT JOIN` + `IS NULL`, `RIGHT JOIN` ja kolme tabeli ühendamine
2. **Grupitöö** – iga liige vastas ühele Anna küsimusele; minu roll oli **C: müümata toodete ja inventuuri analüüs** (products + sales + inventory)

## Kasutatud tööriistad

- PostgreSQL (Supabase)
- SQL: `LEFT JOIN … WHERE … IS NULL`, `INNER JOIN`, kolme tabeli JOIN, `GROUP BY`, `COUNT`, `SUM`, `CASE WHEN`

## Failid

| Fail | Sisu |
|------|------|
| [week3_roll_c_tooted_inventuur.sql](individual/week3_roll_c_tooted_inventuur.sql) | Rolli C päringud koos tulemuste ja inventuuri soovitustega |

## Peamised leiud – tooted + inventuur (roll C)

- **12 toodet pole kunagi müüdud – aga need ei ole ebapopulaarsed tooted.** Kõik 12 on nädal 1 leitud duplikaatkirjed (ID 1351–1362): sama toode on kataloogis kaks korda ja kõik müügid viitavad originaalile. Neil puudub ka laoseis.
- **Kinni olevat raha müümata toodetes ei ole** – müümata toodet laos ei leidu (edasijõudnute päring: 0 rida, kontrollitud).
- **231 toote-asukoha real on laoseis tellimispunktis või alla selle**, neist **7 on täiesti otsas**.
- **Bestseller on kataloogi kalleim toode:** Õhuline sünteetiline sporditossud (434,08 €) – 35 müüki, 27 347,04 €.
- **Kõige edukam kategooria on jalanõud** (774 035 €); lasteriietel on sama palju müüke kui teistel, kuid kõige väiksem müügitulu (305 844 €) madalamate hindade tõttu.

## Tulemused

**Müümata tooted** (`products LEFT JOIN sales … WHERE s.sale_id IS NULL`):

| product_name                      | category      | subcategory | retail_price |
| --------------------------------- | ------------- | ----------- | ------------ |
| Vintage nahkne tossud             | jalanõusid    | tossud      | 179.95       |
| Luksuslik keraamiline elastne vöö | aksessuaarid  | vööd        | 149.55       |
| Moodne keraamiline sall           | aksessuaarid  | sallid      | 147.16       |
| Stiilne puust müts                | aksessuaarid  | mütsid      | 205.89       |
| Kerge siidine nahkkindad          | aksessuaarid  | kindad      | 219.83       |
| Klassikaline kashmiir pusa        | naiste_riided | pusad       | 225.81       |
| Luksuslik teksane polo särk       | meeste_riided | särgid      | 347.84       |
| Minimalistlik kashmiir bleiser    | naiste_riided | jakid       | 185.46       |
| Praktiline trikoo sukkpüksid      | laste_riided  | trikotaaž   | 24.54        |
| Elegantne keraamiline rahakott    | aksessuaarid  | kotid       | 155.84       |
| Moodne villane nahk sandaalid     | jalanõusid    | sandaalid   | 368.67       |
| Stiilne orgaaniline pidžaama      | laste_riided  | komplektid  | 106.82       |

**Müük kategooriate kaupa:**

| Kategooria | Kogumüük |
|---|---|
| jalanõusid | 774 034,75 € |
| meeste_riided | 749 798,72 € |
| naiste_riided | 686 464,24 € |
| aksessuaarid | 393 035,82 € |
| laste_riided | 305 844,45 € |

<!-- TOP 10 TOOTED: kleebi siia Supabase'i "Copy as Markdown" tulemus -->

## Inventuuri soovitused Annale ja Toomasele

1. **Eemaldada 12 duplikaattoodet kataloogist** – need on andmeviga, mitte müümata kaup; allahindlus ei aitaks.
2. **Tellida kohe juurde 7 otsas olevat toodet** ja planeerida tellimus ülejäänud 224 tellimispunktis olevale reale.
3. **Hoida bestsellerite laoseis** – suurim müügitulu tuleb kallitest jalanõudest, seega võib nende otsasaamine maksta kõige rohkem.

## Iseseisev töö – olulisemad tulemused

- **Samm 0: W2 puhastus originaaltabelitesse.** Enne muutmist tegin varukoopia (`sales_backup`), lisasin rea-tunnuse `id` ja kontrollisin enne kustutamist, mitu rida kaob: 15 234 → **10 118** müügirida, linnanimed 54 → **12**.
- **599 klienti pole kunagi ostnud** (`customers LEFT JOIN sales`), **2 551 on ostnud** – kokku 3 150. Neist 599-st **150 on duplikaatkliendid** (nädal 2 leitud topeltimport), seega tegelikult kadunud kliente on umbes 449.
- **INNER JOIN jättis välja 988 külalisostu** (puuduv `customer_id`) – 10 118 müügist ühendus kliendiga 9 130.
- **Linn + kategooria:** Tallinnas müüb enim jalanõusid, Tartus meesteriideid.

## Mida õppisin

- **JOIN-i tüüp otsustab, millise loo andmed räägivad** – INNER JOIN näitab ainult vastetega ridu, LEFT JOIN + `IS NULL` leiab puuduvad seosed.
- **Kontrolli ridade arvu** enne ja pärast JOIN-i – nii näeb kohe, kas mõni rida kadus või paljunes.
- **Andmete puhastamine mõjutab JOIN-i tulemusi** – „müümata“ tooted ja osa „kadunud“ kliente osutusid duplikaatkirjeteks.
- **0 rida võib olla õige vastus** – aga see tuleb tõestada sama päringuga ilma viimase filtrita.

## Meeskonna töö

- [Meeskonna repo](https://github.com/vvaiko1/UrbanStyle-ladu)

## AI kasutamine

Kasutasin AI-d JOIN-päringute loogika ja ON-tingimuste kontrollimiseks ning oodatavate tulemuste võrdlemiseks. Kõik päringud käivitasin ise Supabase SQL Editoris ja kontrollisin ridade arvu.

## Kuidas käivitada

1. Eeldus: `sales`, `customers` ja `products` on imporditud ([nädal 1](../week-1/)) ja puhastatud (sales ~10 118 rida, 12 linna).
2. Impordi `inventory.csv` tabelisse `inventory` (numbriveerud tüübiga `int`, `last_updated` tüübiga `date`) – kontroll: 1 400 rida.
3. Käivita [week3_roll_c_tooted_inventuur.sql](individual/week3_roll_c_tooted_inventuur.sql) päringud ükshaaval ülevalt alla.

## Järgmine samm

Nädal 4: koondamine – `GROUP BY`, `HAVING`, CTE-d. Selle nädala JOIN-päringud on järgmise nädala analüüside ehitusplokid.
