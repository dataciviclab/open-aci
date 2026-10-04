-- Stock nazionale autovetture per anno e alimentazione.
SELECT
  anno_riferimento,
  alimentazione,
  SUM(veicoli) AS veicoli
FROM clean_input
GROUP BY anno_riferimento, alimentazione
ORDER BY anno_riferimento, veicoli DESC
