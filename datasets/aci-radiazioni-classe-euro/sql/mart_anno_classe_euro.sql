-- Totale nazionale per anno e classe euro.
SELECT
  anno,
  classe_euro,
  SUM(radiazioni) AS radiazioni,
  COUNT(DISTINCT comune) AS n_comuni
FROM clean_input
GROUP BY anno, classe_euro
ORDER BY anno, classe_euro
