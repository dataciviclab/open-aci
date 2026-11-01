-- clean.sql: ACI Autoritratto, foglio "30 AV Provincia soggetto" —
-- autovetture per provincia distinte tra persona fisica e persona giuridica.
--
-- Perché questo dataset esiste: il parco comunale è registrato al domicilio
-- dell'intestatario, e le sedi di noleggio/leasing gonfiano alcuni territori
-- (Trento 58,7% di auto aziendali, Aosta 55,3%, Firenze 35,9%). Qui la
-- distorsione diventa una variabile misurata, non un caveat a parole.
--
-- Trappole della fonte:
--  1. `Regione` è valorizzata solo sulla prima riga del gruppo (celle unite).
--  2. Il foglio mescola province, totali regionali ("Totale"), ripartizioni
--     ("ITALIA NORD-ORIENTALE"), "NON DEFINITO" e "Totale NAZIONALE": senza
--     filtro i totali nazionali raddoppiano (83,4 M invece di 41,8 M).
--  3. Un'intestazione di colonna ripetuta ("AREA GEOGRAFICA") compare tra i dati.

WITH src AS (
    SELECT
        row_number() OVER () AS rn,
        CAST({year} AS INTEGER) AS anno,
        "Regione" AS regione_raw,
        "Provincia" AS provincia_raw,
        "PERSONA FISICA" AS pf,
        "PERSONA GIURIDICA" AS pg,
        "NON DEFINITO" AS nd
    FROM raw_input
),
filled AS (
    SELECT
        anno, rn,
        upper(trim(last_value(regione_raw IGNORE NULLS) OVER (ORDER BY rn))) AS regione,
        upper(trim(CAST(provincia_raw AS VARCHAR))) AS provincia,
        TRY_CAST(pf AS DOUBLE) AS pf_num,
        TRY_CAST(pg AS DOUBLE) AS pg_num,
        TRY_CAST(nd AS DOUBLE) AS nd_num
    FROM src
)
SELECT
    anno,
    regione,
    provincia,
    CAST(COALESCE(pf_num, 0) AS BIGINT) AS auto_persona_fisica,
    CAST(COALESCE(pg_num, 0) AS BIGINT) AS auto_persona_giuridica,
    CAST(COALESCE(nd_num, 0) AS BIGINT) AS auto_non_definito,
    CAST(COALESCE(pf_num, 0) + COALESCE(pg_num, 0) + COALESCE(nd_num, 0) AS BIGINT) AS auto_totali
FROM filled
WHERE regione IS NOT NULL
  AND provincia IS NOT NULL
  AND provincia NOT IN ('TOTALE', 'NON DEFINITO', 'AREA GEOGRAFICA', 'PROVINCIA')
  AND provincia NOT LIKE 'ITALIA%'
  AND (pf_num IS NOT NULL OR pg_num IS NOT NULL)
