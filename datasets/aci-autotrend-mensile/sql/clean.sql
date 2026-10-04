-- Auto-Trend ACI: uffici PRA × mese × formalità.
-- ZIP aci.gov.it, include solo il CSV provinciale (Prime*AV*mese-pv).
-- Colonne raw rinominate in clean.read.columns (VARCHAR per QUANTITA').
-- Punti migliaia italiani → remove_dot_thousands.
-- formalita mappata a codici brevi per mart/dashboard.

SELECT
  anno,
  normalize_string(mese) AS mese,
  CASE UPPER(TRIM(mese))
    WHEN 'GENNAIO' THEN 1
    WHEN 'FEBBRAIO' THEN 2
    WHEN 'MARZO' THEN 3
    WHEN 'APRILE' THEN 4
    WHEN 'MAGGIO' THEN 5
    WHEN 'GIUGNO' THEN 6
    WHEN 'LUGLIO' THEN 7
    WHEN 'AGOSTO' THEN 8
    WHEN 'SETTEMBRE' THEN 9
    WHEN 'OTTOBRE' THEN 10
    WHEN 'NOVEMBRE' THEN 11
    WHEN 'DICEMBRE' THEN 12
    ELSE NULL
  END AS mese_num,
  normalize_string(ufficio_pra) AS ufficio_pra,
  CASE
    WHEN UPPER(formalita) LIKE 'PRIME%' THEN 'prime_iscrizioni'
    WHEN UPPER(formalita) LIKE 'TRASFERIMENTI%' THEN 'usato_netto'
    WHEN UPPER(formalita) LIKE 'PASSAGGI%' THEN 'usato_netto'
    WHEN UPPER(formalita) LIKE 'RADIAZIONI%' THEN 'radiazioni'
    ELSE normalize_string(formalita)
  END AS formalita,
  remove_dot_thousands(quantita) AS quantita
FROM raw_input
WHERE anno IS NOT NULL
  AND mese IS NOT NULL
  AND ufficio_pra IS NOT NULL
  AND quantita IS NOT NULL
