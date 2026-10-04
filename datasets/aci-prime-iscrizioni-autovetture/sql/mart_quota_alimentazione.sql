-- Quota percentuale di ogni alimentazione sul totale nazionale dell'anno.
WITH tot AS (
  SELECT
    anno,
    SUM(prime_iscrizioni) AS totale
  FROM clean_input
  GROUP BY anno
)
SELECT
  c.anno,
  c.alimentazione,
  SUM(c.prime_iscrizioni) AS prime_iscrizioni,
  CASE
    WHEN t.totale > 0
      THEN SUM(c.prime_iscrizioni)::DOUBLE / t.totale
    ELSE NULL
  END AS quota_totale
FROM clean_input c
JOIN tot t ON c.anno = t.anno
GROUP BY c.anno, c.alimentazione, t.totale
ORDER BY c.anno, c.alimentazione
