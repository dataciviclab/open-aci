-- Radiazioni per demolizione di autovetture per comune e classe euro (ACI LOD).
-- Join ISTAT via support external {support.istat_comuni.path}.
-- Join comune + provincia (evita fan-out su omonimi).
-- Solo Comuni.

SELECT
  CAST({year} AS INTEGER) AS anno,
  normalize_string(r.enteTerritoriale) AS comune,
  normalize_string(r.provincia) AS provincia,
  i.codice_istat,
  i.regione,
  i.popolazione_residente,
  normalize_string(r.classeEuro) AS classe_euro,
  cast_bigint(r.demolizioni) AS radiazioni
FROM raw_input r
LEFT JOIN (
  SELECT
    codice_istat,
    normalize_string(denominazione) AS denominazione,
    normalize_string(provincia) AS provincia,
    regione,
    popolazione_residente
  FROM read_parquet('{support.istat_comuni.path}')
) i
  ON normalize_string(r.enteTerritoriale) = i.denominazione
 AND normalize_string(r.provincia) = i.provincia
WHERE r.tipoEnteTerritoriale = 'Comune'
