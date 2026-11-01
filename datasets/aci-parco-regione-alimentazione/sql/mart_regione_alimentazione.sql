-- mart_regione_alimentazione.sql: parco autovetture per regione e alimentazione,
-- con quota percentuale sul totale della regione in quell'anno.
--
-- La cilindrata viene collassata: il dettaglio resta nel clean per chi ne ha bisogno.
-- `quota_pct` è calcolata sul totale regionale dell'anno, così le righe di una
-- regione sommano a 100 (salvo arrotondamento).

WITH per_alim AS (
    SELECT
        anno,
        regione,
        alimentazione,
        SUM(veicoli) AS veicoli
    FROM clean_input
    GROUP BY anno, regione, alimentazione
),
tot AS (
    SELECT anno, regione, SUM(veicoli) AS veicoli_totali
    FROM per_alim
    GROUP BY anno, regione
)
SELECT
    a.anno,
    a.regione,
    a.alimentazione,
    a.veicoli,
    t.veicoli_totali,
    ROUND(100.0 * a.veicoli / NULLIF(t.veicoli_totali, 0), 2) AS quota_pct
FROM per_alim a
JOIN tot t ON t.anno = a.anno AND t.regione = a.regione
ORDER BY a.anno, a.regione, a.veicoli DESC
