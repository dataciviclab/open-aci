-- Prime iscrizioni autovetture per comune e alimentazione (ACI LOD).
-- Join ISTAT via support external {support.istat_comuni.path}.
-- Join comune + provincia (evita fan-out su omonimi tipo Castro/Samone).
-- Solo Comuni.

SELECT
  CAST({year} AS INTEGER) AS anno,
  normalize_string(r.enteTerritoriale) AS comune,
  normalize_string(r.provincia) AS provincia,
  i.codice_istat,
  i.regione,
  i.popolazione_residente,
  normalize_string(r.alimentazione) AS alimentazione,
  cast_bigint(r.primeIscrizioni) AS prime_iscrizioni
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
