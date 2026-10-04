-- Totali nazionali per anno e formalità.
SELECT
  anno,
  formalita,
  SUM(quantita) AS quantita
FROM clean_input
GROUP BY anno, formalita
ORDER BY anno, formalita
