-- mart_provincia_eta.sql: anzianità del parco per provincia.
--
-- Oltre alla quota per classe, due sintesi che servono a leggere il rinnovo:
--   * quota_pre2016_pct  — auto immatricolate prima del 2016 (parco "vecchio")
--   * quota_recente_pct  — auto immatricolate dal 2020 in poi
-- Il confronto tra le due dice se il territorio sta rinnovando il parco o no.

WITH base AS (
    SELECT anno, regione, provincia, classe_eta, autovetture
    FROM clean_input
),
tot AS (
    SELECT anno, regione, provincia, SUM(autovetture) AS autovetture_totali
    FROM base
    GROUP BY anno, regione, provincia
),
quote AS (
    SELECT
        b.anno, b.regione, b.provincia, b.classe_eta, b.autovetture,
        t.autovetture_totali,
        ROUND(100.0 * b.autovetture / NULLIF(t.autovetture_totali, 0), 2) AS quota_pct
    FROM base b
    JOIN tot t
        ON t.anno = b.anno AND t.regione = b.regione AND t.provincia = b.provincia
)
SELECT
    anno, regione, provincia, classe_eta, autovetture, autovetture_totali, quota_pct,
    ROUND(SUM(CASE WHEN classe_eta IN ('fino al 2009', '2010-2012', '2013-2015')
                   THEN quota_pct ELSE 0 END) OVER (PARTITION BY anno, regione, provincia), 2)
        AS quota_pre2016_pct,
    ROUND(SUM(CASE WHEN classe_eta IN ('2020-2021', '2022-2023', '2024-2025')
                   THEN quota_pct ELSE 0 END) OVER (PARTITION BY anno, regione, provincia), 2)
        AS quota_recente_pct
FROM quote
ORDER BY anno, regione, provincia, classe_eta
