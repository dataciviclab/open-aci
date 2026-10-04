-- Autoritratto ACI: passaggi di proprietà (usato) per categoria veicolo.
-- Foglio "1" (Specifiche: nazionale, trasferimenti per classe + minivolture).
-- Colonna Totale ha spazio finale nel file Excel ("Totale ").

SELECT
  CAST({year} AS INTEGER) AS anno_riferimento,
  normalize_string(categoria) AS categoria,
  TRY_CAST(minivolture AS BIGINT) AS minivolture,
  TRY_CAST("Non minivolture" AS BIGINT) AS non_minivolture,
  TRY_CAST("Totale " AS BIGINT) AS totale
FROM raw_input
WHERE normalize_string(categoria) IS NOT NULL
  AND UPPER(TRIM(categoria)) NOT LIKE 'TOTALE%'
  AND TRY_CAST("Totale " AS BIGINT) IS NOT NULL
