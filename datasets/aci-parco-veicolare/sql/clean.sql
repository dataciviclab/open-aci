-- Autoritratto ACI: stock autovetture per alimentazione al 31/12.
-- Foglio: "4 AV Alimentazione anno immat" (header skip=2).
-- Colonna Totale ha spazio finale nel file Excel ("Totale ").
-- Solo righe alimentazione (no titoli).

SELECT
  CAST({year} AS INTEGER) AS anno_riferimento,
  normalize_string("Unnamed: 0") AS alimentazione,
  TRY_CAST("Totale " AS BIGINT) AS veicoli
FROM raw_input
WHERE normalize_string("Unnamed: 0") IS NOT NULL
  AND UPPER(TRIM("Unnamed: 0")) NOT IN ('TOTALE', 'TOTAL')
  AND TRY_CAST("Totale " AS BIGINT) IS NOT NULL
