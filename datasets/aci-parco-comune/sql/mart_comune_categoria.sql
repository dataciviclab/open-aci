-- mart_comune_categoria.sql: parco per comune e categoria, con il totale del
-- comune e la quota della categoria (utile per leggere la composizione locale,
-- es. quanto pesano i motocicli o gli autocarri in un comune).

WITH base AS (
    SELECT
        anno, regione, provincia, comune, codice_istat, categoria_veicolo, veicoli
    FROM clean_input
),
tot AS (
    SELECT anno, regione, provincia, comune, SUM(veicoli) AS veicoli_totali
    FROM base
    GROUP BY anno, regione, provincia, comune
)
SELECT
    b.anno,
    b.regione,
    b.provincia,
    b.comune,
    b.codice_istat,
    b.categoria_veicolo,
    b.veicoli,
    t.veicoli_totali,
    ROUND(100.0 * b.veicoli / NULLIF(t.veicoli_totali, 0), 2) AS quota_pct
FROM base b
JOIN tot t
    ON t.anno = b.anno AND t.regione = b.regione
   AND t.provincia = b.provincia AND t.comune = b.comune
ORDER BY b.anno, b.regione, b.provincia, b.comune, b.veicoli DESC
