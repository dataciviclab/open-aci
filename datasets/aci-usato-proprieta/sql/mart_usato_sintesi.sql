-- Sintesi nazionale: totale usato, quota autovetture, quota minivolture sulle AV.
SELECT
  c.anno_riferimento,
  SUM(c.totale) AS totale_usato,
  SUM(c.totale) FILTER (WHERE c.categoria = 'AUTOVETTURE') AS totale_av,
  SUM(c.totale) FILTER (WHERE c.categoria = 'AUTOVETTURE' AND c.minivolture IS NOT NULL)
    / NULLIF(SUM(c.totale) FILTER (WHERE c.categoria = 'AUTOVETTURE'), 0)
    AS quote_minivolture_av
FROM clean_input c
GROUP BY c.anno_riferimento
ORDER BY c.anno_riferimento
