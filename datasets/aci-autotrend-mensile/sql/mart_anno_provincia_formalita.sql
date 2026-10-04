-- Totali per ufficio PRA (provincia), anno e formalità.
SELECT
  anno,
  ufficio_pra,
  formalita,
  SUM(quantita) AS quantita
FROM clean_input
GROUP BY anno, ufficio_pra, formalita
ORDER BY anno, ufficio_pra, formalita
