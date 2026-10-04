-- Totali nazionali per anno, mese e formalità.
SELECT
  anno,
  mese,
  formalita,
  SUM(quantita) AS quantita
FROM clean_input
GROUP BY anno, mese, formalita
ORDER BY anno, mese, formalita
