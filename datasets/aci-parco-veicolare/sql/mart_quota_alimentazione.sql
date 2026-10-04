-- Quota di ogni alimentazione sul totale del parco autovetture dell'anno.
WITH tot AS (
  SELECT
    anno_riferimento,
    SUM(veicoli) AS totale
  FROM clean_input
  GROUP BY anno_riferimento
)
SELECT
  c.anno_riferimento,
  c.alimentazione,
  SUM(c.veicoli) AS veicoli,
  CASE
    WHEN t.totale > 0
      THEN SUM(c.veicoli)::DOUBLE / t.totale
    ELSE NULL
  END AS quota_totale
FROM clean_input c
JOIN tot t ON c.anno_riferimento = t.anno_riferimento
GROUP BY c.anno_riferimento, c.alimentazione, t.totale
ORDER BY c.anno_riferimento, veicoli DESC
