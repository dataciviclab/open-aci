-- Passaggi di proprietà per anno e categoria veicolo.
SELECT
  anno_riferimento,
  categoria,
  minivolture,
  non_minivolture,
  totale
FROM clean_input
ORDER BY anno_riferimento, totale DESC
