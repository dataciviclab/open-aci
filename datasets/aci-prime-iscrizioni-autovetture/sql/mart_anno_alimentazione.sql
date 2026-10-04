-- Totale nazionale per anno e alimentazione.
SELECT
  anno,
  alimentazione,
  SUM(prime_iscrizioni) AS prime_iscrizioni,
  COUNT(DISTINCT comune) AS n_comuni
FROM clean_input
GROUP BY anno, alimentazione
ORDER BY anno, alimentazione
