-- Totale per regione, anno e alimentazione.
SELECT
  anno,
  regione,
  alimentazione,
  SUM(prime_iscrizioni) AS prime_iscrizioni
FROM clean_input
WHERE regione IS NOT NULL
GROUP BY anno, regione, alimentazione
ORDER BY anno, regione, alimentazione
