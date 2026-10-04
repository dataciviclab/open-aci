-- Serie mensile ordinata (mese_num già in clean).
SELECT
  anno,
  mese_num,
  mese,
  formalita,
  SUM(quantita) AS quantita
FROM clean_input
WHERE mese_num IS NOT NULL
GROUP BY anno, mese_num, mese, formalita
ORDER BY anno, mese_num, formalita
