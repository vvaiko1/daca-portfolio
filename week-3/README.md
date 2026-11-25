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
- **Laoandmetes on vigu:** 10 real on laoseis **negatiivne** (kuni −46), 40 real ebareaalselt suur (üle 500, kuni 9 985), kuigi tavaline laoseis on poes kuni 150 ja laos kuni ~500.
- **Kaardi päring näitab laoseisuta tooteid staatusega „OK“** – 12 toodet, millel pole laorida, saavad `NULL <= reorder_point` tõttu vale staatuse.
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

**TOP 10 toodet kogumüügi järgi** (`products INNER JOIN sales`):

| product_name                               | category      | subcategory | müüdud_kordi | kogumüük |
| ------------------------------------------ | ------------- | ----------- | ------------ | -------- |
| Õhuline sünteetiline sporditossud          | jalanõusid    | tossud      | 35           | 27347.04 |
| Trendikas goretex oxfordid                 | jalanõusid    | kingad      | 32           | 23376.15 |
| Praktiline viskoosne jakk                  | naiste_riided | jakid       | 35           | 22188.80 |
| Praktiline džersii seelik                  | naiste_riided | seelikud    | 37           | 22039.98 |
| Boheemlaslik puuvillane tuulejope          | naiste_riided | jakid       | 30           | 21309.96 |
| Õhuline sünteetiline kõrge kontsaga kingad | jalanõusid    | kontsad     | 38           | 21295.56 |
| Praktiline kangast kõrge kontsaga kingad   | jalanõusid    | kontsad     | 37           | 21118.68 |
| Luksuslik villane pahkluu saapad           | jalanõusid    | botased     | 28           | 19704.87 |
| Praktiline merino villane parka            | meeste_riided | jakid       | 30           | 19620.45 |
| Õhuline linane jakk                        | naiste_riided | jakid       | 41           | 19393.29 |

**Müük kategooriate kaupa** (`products LEFT JOIN sales`):

| category      | tooteid | müüke | kogumüük  |
| ------------- | ------- | ----- | --------- |
| jalanõusid    | 73      | 2031  | 774034.75 |
| meeste_riided | 82      | 2266  | 749798.72 |
| naiste_riided | 70      | 2022  | 686464.24 |
| aksessuaarid  | 67      | 1772  | 393035.82 |
| laste_riided  | 70      | 2027  | 305844.45 |

**Laoseis – kõige madalamad read** (`products LEFT JOIN inventory`, kokku 1 412 rida; siin esimesed 17):

| product_name                          | category      | location | quantity_available | reorder_point | staatus      |
| ------------------------------------- | ------------- | -------- | ------------------ | ------------- | ------------ |
| Õhuline polüester cargo püksid        | meeste_riided | ladu     | -46                | 47            | TELLI JUURDE |
| Elegantne tweed bleiser               | meeste_riided | tartu    | -42                | 29            | TELLI JUURDE |
| Õhuline villane sõrmus                | aksessuaarid  | pärnu    | -25                | 34            | TELLI JUURDE |
| Minimalistlik puuvillane tuunika      | naiste_riided | pärnu    | -24                | 42            | TELLI JUURDE |
| Vintage džersii tuunika               | naiste_riided | tartu    | -23                | 48            | TELLI JUURDE |
| Mugav merino villane dressipluus      | naiste_riided | pärnu    | -22                | 43            | TELLI JUURDE |
| Mugav puuvillane suvekleit            | laste_riided  | tartu    | -22                | 22            | TELLI JUURDE |
| Elegantne siidine müts                | aksessuaarid  | ladu     | -19                | 50            | TELLI JUURDE |
| Soe satiinne pluus                    | naiste_riided | pärnu    | -16                | 33            | TELLI JUURDE |
| Elegantne orgaaniline tuulejope       | laste_riided  | tartu    | -7                 | 15            | TELLI JUURDE |
| Luksuslik sünteetiline nahk sandaalid | jalanõusid    | tartu    | 0                  | 35            | TELLI JUURDE |
| Trendikas goretex chelsea botased     | jalanõusid    | pärnu    | 0                  | 13            | TELLI JUURDE |
| Sportlik džersii ülikond              | meeste_riided | pärnu    | 0                  | 45            | TELLI JUURDE |
| Soe merino villane topik              | naiste_riided | tallinn  | 0                  | 14            | TELLI JUURDE |
| Elegantne puuvillane body             | laste_riided  | pärnu    | 0                  | 42            | TELLI JUURDE |
| Trendikas fliisist tuulejope          | laste_riided  | pärnu    | 0                  | 20            | TELLI JUURDE |
| Boheemlaslik klaasist kaelakee        | aksessuaarid  | pärnu    | 0                  | 36            | TELLI JUURDE |

Nimekirja **lõpus** on 12 laoseisuta toodet (`location`, `quantity_available` ja `reorder_point` = NULL) staatusega **„OK“** – see on kaardi CASE-lause puudus.

**Tõend, et edasijõudnute päringu 0 rida on õige** (müümata tooted ilma laoseisu filtrita):

| product_id | product_name                      | quantity_available |
| ---------- | --------------------------------- | ------------------ |
| 1351       | Vintage nahkne tossud             | null               |
| 1352       | Moodne villane nahk sandaalid     | null               |
| 1353       | Minimalistlik kashmiir bleiser    | null               |
| 1354       | Praktiline trikoo sukkpüksid      | null               |
| 1355       | Kerge siidine nahkkindad          | null               |
| 1356       | Elegantne keraamiline rahakott    | null               |
| 1357       | Stiilne puust müts                | null               |
| 1358       | Luksuslik keraamiline elastne vöö | null               |
| 1359       | Moodne keraamiline sall           | null               |
| 1360       | Stiilne orgaaniline pidžaama      | null               |
| 1361       | Klassikaline kashmiir pusa        | null               |
| 1362       | Luksuslik teksane polo särk       | null               |

Kõik 12 müümata toodet on ID-dega 1351–1362 (nädal 1 duplikaatkoopiad) ja neil pole laoseisu – seega pole müümata kaupa laos ega raha kinni.

## Inventuuri soovitused Annale ja Toomasele

1. **Eemaldada 12 duplikaattoodet kataloogist** – need on andmeviga, mitte müümata kaup; allahindlus ei aitaks.
2. **Tellida kohe juurde 7 otsas olevat toodet** ja planeerida tellimus ülejäänud 224 tellimispunktis olevale reale.
3. **Kontrollida laoandmed üle** – 10 negatiivset ja 40 ebareaalselt suurt laoseisu viitavad sisestusvigadele; enne tellimisotsuseid tuleks need read inventuuriga kinnitada.
4. **Hoida bestsellerite laoseis** – suurim müügitulu tuleb kallitest jalanõudest, seega võib nende otsasaamine maksta kõige rohkem.

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
