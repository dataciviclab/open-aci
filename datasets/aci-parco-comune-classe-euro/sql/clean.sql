-- clean.sql: ACI Autoritratto, foglio "4 AV per Comune " —
-- autovetture per comune e classe ambientale Euro (stock al 31/12).
--
-- Stesse accortezze del parco per categoria: Regione/Provincia sono celle unite
-- (forward-fill), e le righe di riepilogo vanno escluse. Qui il join ISTAT è
-- semplificato: se il comune non si risolve resta con codice_istat NULL.
--
-- Non si usa la colonna TOTALE della fonte: le classi si sommano nel mart e la
-- quadratura è verificata a parte.

WITH src AS (
    SELECT
        row_number() OVER () AS rn,
        CAST({year} AS INTEGER) AS anno,
        "REGIONE" AS regione_raw,
        "PROVINCIA" AS provincia_raw,
        "COMUNE" AS comune_raw,
        "EURO 0" AS e0, "EURO 1" AS e1, "EURO 2" AS e2, "EURO 3" AS e3,
        "EURO 4" AS e4, "EURO 5" AS e5, "EURO 5B" AS e5b,
        "EURO 6" AS e6, "EURO 6A" AS e6a, "EURO 6B" AS e6b,
        "EURO 6C" AS e6c, "EURO 6D" AS e6d, "EURO 6E" AS e6e,
        "Non contemplato" AS non_contemplato,
        "Non definito" AS non_definito
    FROM raw_input
),
filled AS (
    SELECT
        anno, rn,
        upper(trim(last_value(regione_raw IGNORE NULLS) OVER (ORDER BY rn))) AS regione,
        upper(trim(last_value(provincia_raw IGNORE NULLS) OVER (ORDER BY rn))) AS provincia,
        upper(trim(CAST(comune_raw AS VARCHAR))) AS comune,
        e0, e1, e2, e3, e4, e5, e5b, e6, e6a, e6b, e6c, e6d, e6e,
        non_contemplato, non_definito
    FROM src
),
unp AS (
    UNPIVOT (
        SELECT anno, regione, provincia, comune,
               e0, e1, e2, e3, e4, e5, e5b, e6, e6a, e6b, e6c, e6d, e6e,
               non_contemplato, non_definito
        FROM filled
    )
    ON e0, e1, e2, e3, e4, e5, e5b, e6, e6a, e6b, e6c, e6d, e6e,
       non_contemplato, non_definito
    INTO NAME classe_col VALUE autovetture
),
cat AS (
    SELECT
        anno, regione, provincia, comune,
        CASE classe_col
            WHEN 'e0' THEN 'euro 0'
            WHEN 'e1' THEN 'euro 1'
            WHEN 'e2' THEN 'euro 2'
            WHEN 'e3' THEN 'euro 3'
            WHEN 'e4' THEN 'euro 4'
            WHEN 'e5' THEN 'euro 5'
            WHEN 'e5b' THEN 'euro 5b'
            WHEN 'e6' THEN 'euro 6'
            WHEN 'e6a' THEN 'euro 6a'
            WHEN 'e6b' THEN 'euro 6b'
            WHEN 'e6c' THEN 'euro 6c'
            WHEN 'e6d' THEN 'euro 6d'
            WHEN 'e6e' THEN 'euro 6e'
            WHEN 'non_contemplato' THEN 'non contemplato'
            ELSE 'non definito'
        END AS classe_euro,
        TRY_CAST(autovetture AS DOUBLE) AS autovetture_num
    FROM unp
    WHERE regione IS NOT NULL AND comune IS NOT NULL
      AND upper(trim(comune)) NOT IN ('TOTALE', 'NON DEFINITO')
),
istat AS (
    SELECT
        codice_istat,
        regione,
        provincia,
        lower(trim(denominazione)) AS nome_k
    FROM read_parquet('{support.istat_comuni.path}')
),
univoci AS (
    SELECT nome_k, min(codice_istat) AS codice_istat
    FROM istat
    GROUP BY nome_k
    HAVING count(*) = 1
)
SELECT
    c.anno,
    c.regione,
    c.provincia,
    c.comune,
    COALESCE(i.codice_istat, u.codice_istat) AS codice_istat,
    c.classe_euro,
    CAST(c.autovetture_num AS BIGINT) AS autovetture
FROM cat c
LEFT JOIN istat i
    ON lower(trim(i.regione)) = lower(trim(c.regione))
   AND lower(trim(i.provincia)) = lower(trim(c.provincia))
   AND i.nome_k = lower(c.comune)
LEFT JOIN univoci u
    ON u.nome_k = lower(c.comune)
   AND i.codice_istat IS NULL
WHERE c.autovetture_num IS NOT NULL
