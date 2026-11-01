-- mart_italia_alimentazione.sql: fotografia nazionale per alimentazione e anno.
--
-- Il toolkit genera i mart per singolo anno (out/data/mart/<slug>/<anno>/),
-- quindi qui non si calcolano variazioni rispetto all'anno precedente: un LAG
-- su più anni restituirebbe sempre NULL. Il confronto temporale si fa a valle,
-- unendo le partizioni annuali.

WITH per_alim AS (
    SELECT
        anno,
        alimentazione,
        SUM(veicoli) AS veicoli
    FROM clean_input
    GROUP BY anno, alimentazione
),
tot AS (
    SELECT anno, SUM(veicoli) AS veicoli_totali
    FROM per_alim
    GROUP BY anno
)
SELECT
    a.anno,
    a.alimentazione,
    a.veicoli,
    t.veicoli_totali,
    ROUND(100.0 * a.veicoli / NULLIF(t.veicoli_totali, 0), 2) AS quota_pct
FROM per_alim a
JOIN tot t ON t.anno = a.anno
ORDER BY a.anno, a.veicoli DESC
