-- Quota percentuale di ogni classe euro sul totale nazionale dell'anno.
WITH tot AS (
  SELECT
    anno,
    SUM(radiazioni) AS totale
  FROM clean_input
  GROUP BY anno
)
SELECT
  c.anno,
  c.classe_euro,
  SUM(c.radiazioni) AS radiazioni,
  CASE
    WHEN t.totale > 0
      THEN SUM(c.radiazioni)::DOUBLE / t.totale
    ELSE NULL
  END AS quota_totale
FROM clean_input c
JOIN tot t ON c.anno = t.anno
GROUP BY c.anno, c.classe_euro, t.totale
ORDER BY c.anno, c.classe_euro
