-- clean.sql: ACI Annuario statistico, Tab.III.16 —
-- parco autovetture per regione, alimentazione e classe di cilindrata (stock al 31/12).
--
-- Tre accortezze obbligate dalla fonte:
--  1. `Regione` è valorizzata solo sulla prima riga del gruppo (celle unite):
--     va riportata in avanti con last_value IGNORE NULLS, altrimenti si perdono
--     tutte le alimentazioni tranne la prima.
--  2. Le etichette dell'alimentazione cambiano tra edizioni ("Benzina e GPL" nel
--     2021-22, "Benzina e Gas Liquido" nel 2023): normalizzate qui, non nei mart.
--  3. La riga "Totale complessivo" (presente solo in alcune edizioni) è una riga
--     di totale, non un'alimentazione: va esclusa, altrimenti doppio conteggio.
--
-- Il totale di riga (colonna TOTALE) NON viene usato: le classi si sommano nei
-- mart e la quadratura è verificata a parte (vedi notes.md).

WITH src AS (
    SELECT
        row_number() OVER () AS rn,
        CAST({year} AS INTEGER) AS anno,
        "Regione" AS regione_raw,
        "Alimentazione" AS alimentazione_raw,
        "FINO A 800" AS c_800,
        "801 - 1200" AS c_801_1200,
        "1201 - 1600" AS c_1201_1600,
        "1601 - 1800" AS c_1601_1800,
        "1801 - 2000" AS c_1801_2000,
        "2001 - 2500" AS c_2001_2500,
        "2501 - 3000" AS c_2501_3000,
        "OLTRE 3000" AS c_oltre_3000,
        "NON DEFINITO" AS c_non_definito
    FROM raw_input
),
filled AS (
    SELECT
        anno,
        rn,
        upper(trim(last_value(regione_raw IGNORE NULLS) OVER (ORDER BY rn))) AS regione,
        upper(trim(CAST(alimentazione_raw AS VARCHAR))) AS alimentazione_raw,
        c_800, c_801_1200, c_1201_1600, c_1601_1800, c_1801_2000,
        c_2001_2500, c_2501_3000, c_oltre_3000, c_non_definito
    FROM src
),
unp AS (
    UNPIVOT (
        SELECT
            anno, rn, regione, alimentazione_raw,
            c_800, c_801_1200, c_1201_1600, c_1601_1800, c_1801_2000,
            c_2001_2500, c_2501_3000, c_oltre_3000, c_non_definito
        FROM filled
    )
    ON c_800, c_801_1200, c_1201_1600, c_1601_1800, c_1801_2000,
       c_2001_2500, c_2501_3000, c_oltre_3000, c_non_definito
    INTO NAME classe_col VALUE veicoli
),
long AS (
    SELECT
        anno,
        regione,
        CASE alimentazione_raw
            WHEN 'BENZINA' THEN 'benzina'
            WHEN 'GASOLIO' THEN 'gasolio'
            WHEN 'BENZINA E GPL' THEN 'benzina_gpl'
            WHEN 'BENZINA E GAS LIQUIDO' THEN 'benzina_gpl'
            WHEN 'BENZINA E METANO' THEN 'benzina_metano'
            WHEN 'METANO' THEN 'metano'
            WHEN 'ELETTRICITA' THEN 'elettrico'
            WHEN 'IBRIDO BENZINA' THEN 'ibrido_benzina'
            WHEN 'IBRIDO GASOLIO' THEN 'ibrido_gasolio'
            WHEN 'ALTRE' THEN 'altro'
            WHEN 'NON DEFINITO' THEN 'non_definito'
            ELSE lower(trim(alimentazione_raw))
        END AS alimentazione,
        CASE classe_col
            WHEN 'c_800' THEN 'fino a 800'
            WHEN 'c_801_1200' THEN '801-1200'
            WHEN 'c_1201_1600' THEN '1201-1600'
            WHEN 'c_1601_1800' THEN '1601-1800'
            WHEN 'c_1801_2000' THEN '1801-2000'
            WHEN 'c_2001_2500' THEN '2001-2500'
            WHEN 'c_2501_3000' THEN '2501-3000'
            WHEN 'c_oltre_3000' THEN 'oltre 3000'
            ELSE 'non definito'
        END AS classe_cilindrata,
        TRY_CAST(veicoli AS DOUBLE) AS veicoli_num
    FROM unp
    WHERE regione IS NOT NULL
      -- "ITALIA" e "NON DEFINITO" sono righe di riepilogo dentro lo stesso foglio:
      -- se restano, i totali nazionali raddoppiano. Il totale Italia si ricava
      -- sommando le regioni nel mart.
      AND regione NOT IN ('ITALIA', 'NON DEFINITO')
      AND alimentazione_raw IS NOT NULL
      AND alimentazione_raw NOT LIKE 'TOTALE%'
)
SELECT
    anno,
    regione,
    alimentazione,
    classe_cilindrata,
    CAST(veicoli_num AS BIGINT) AS veicoli
FROM long
WHERE veicoli_num IS NOT NULL
