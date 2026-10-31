-- clean.sql: ACI Autoritratto, foglio "28 AV Provincia anno" —
-- autovetture per provincia e classe di anno di immatricolazione.
--
-- Stesse trappole degli altri fogli provinciali:
--  1. Regione in celle unite → forward-fill.
--  2. Righe di riepilogo (Totale, ripartizioni ITALIA*, NON DEFINITO, intestazione
--     "AREA GEOGRAFICA" ripetuta) da escludere, o i totali raddoppiano.
--
-- Le classi sono quelle pubblicate da ACI (aggregazioni di anni): non si
-- ricostruisce l'anno esatto perché la fonte non lo dà.

WITH src AS (
    SELECT
        row_number() OVER () AS rn,
        CAST({year} AS INTEGER) AS anno,
        "Regione" AS regione_raw,
        "Provincia" AS provincia_raw,
        "FINO AL 2009" AS a_pre2009,
        "2010 - 2012" AS a_2010_2012,
        "2013 - 2015" AS a_2013_2015,
        "2016 - 2017" AS a_2016_2017,
        "2018 - 2019" AS a_2018_2019,
        "2020 - 2021" AS a_2020_2021,
        "2022 - 2023" AS a_2022_2023,
        "2024 - 2025" AS a_2024_2025
    FROM raw_input
),
filled AS (
    SELECT
        anno, rn,
        upper(trim(last_value(regione_raw IGNORE NULLS) OVER (ORDER BY rn))) AS regione,
        upper(trim(CAST(provincia_raw AS VARCHAR))) AS provincia,
        a_pre2009, a_2010_2012, a_2013_2015, a_2016_2017,
        a_2018_2019, a_2020_2021, a_2022_2023, a_2024_2025
    FROM src
),
unp AS (
    UNPIVOT (
        SELECT anno, regione, provincia,
               a_pre2009, a_2010_2012, a_2013_2015, a_2016_2017,
               a_2018_2019, a_2020_2021, a_2022_2023, a_2024_2025
        FROM filled
    )
    ON a_pre2009, a_2010_2012, a_2013_2015, a_2016_2017,
       a_2018_2019, a_2020_2021, a_2022_2023, a_2024_2025
    INTO NAME classe_col VALUE autovetture
)
SELECT
    anno,
    regione,
    provincia,
    CASE classe_col
        WHEN 'a_pre2009' THEN 'fino al 2009'
        WHEN 'a_2010_2012' THEN '2010-2012'
        WHEN 'a_2013_2015' THEN '2013-2015'
        WHEN 'a_2016_2017' THEN '2016-2017'
        WHEN 'a_2018_2019' THEN '2018-2019'
        WHEN 'a_2020_2021' THEN '2020-2021'
        WHEN 'a_2022_2023' THEN '2022-2023'
        ELSE '2024-2025'
    END AS classe_eta,
    CAST(TRY_CAST(autovetture AS DOUBLE) AS BIGINT) AS autovetture
FROM unp
WHERE regione IS NOT NULL
  AND provincia IS NOT NULL
  AND provincia NOT IN ('TOTALE', 'NON DEFINITO', 'AREA GEOGRAFICA', 'PROVINCIA')
  AND provincia NOT LIKE 'ITALIA%'
  AND TRY_CAST(autovetture AS DOUBLE) IS NOT NULL
