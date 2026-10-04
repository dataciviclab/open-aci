-- Totale per regione, anno e classe euro.
SELECT
  anno,
  regione,
  classe_euro,
  SUM(radiazioni) AS radiazioni
FROM clean_input
WHERE regione IS NOT NULL
GROUP BY anno, regione, classe_euro
ORDER BY anno, regione, classe_euro
