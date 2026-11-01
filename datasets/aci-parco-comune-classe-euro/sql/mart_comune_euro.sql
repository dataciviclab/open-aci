-- mart_comune_euro.sql: autovetture per comune e classe Euro, con quota e
-- raggruppamento per età del parco. Le classi fini (6A..6E, 5B) restano, ma si
-- aggiunge `fascia_euro` perché è quella che serve per leggere l'impatto
-- ambientale: Euro 0-3 (vecchio), Euro 4-5 (medio), Euro 6 (recente).

WITH base AS (
    SELECT anno, regione, provincia, comune, codice_istat, classe_euro, autovetture
    FROM clean_input
),
tot AS (
    SELECT anno, regione, provincia, comune, SUM(autovetture) AS autovetture_totali
    FROM base
    GROUP BY anno, regione, provincia, comune
)
SELECT
    b.anno,
    b.regione,
    b.provincia,
    b.comune,
    b.codice_istat,
    b.classe_euro,
    CASE
        WHEN b.classe_euro IN ('euro 0', 'euro 1', 'euro 2', 'euro 3') THEN 'euro 0-3'
        WHEN b.classe_euro IN ('euro 4', 'euro 5', 'euro 5b') THEN 'euro 4-5'
        WHEN b.classe_euro LIKE 'euro 6%' THEN 'euro 6'
        ELSE 'non classificato'
    END AS fascia_euro,
    b.autovetture,
    t.autovetture_totali,
    ROUND(100.0 * b.autovetture / NULLIF(t.autovetture_totali, 0), 2) AS quota_pct
FROM base b
JOIN tot t
    ON t.anno = b.anno AND t.regione = b.regione
   AND t.provincia = b.provincia AND t.comune = b.comune
ORDER BY b.anno, b.regione, b.provincia, b.comune, b.classe_euro
