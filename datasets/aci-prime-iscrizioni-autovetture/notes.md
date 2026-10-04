# aci_prime_iscrizioni_autovetture

Prime iscrizioni di autovetture nuove per comune e tipo di alimentazione, 2017–2025.

## Fonte

- ACI — Automobile Club Italia, via [dati.gov.it](https://www.dati.gov.it/view-dataset?organization=aci) / [lod.aci.it](http://lod.aci.it/)
- CSV tidy, CC-BY 4.0
- Una fonte HTTP per anno (`raw.sources[].year`) — i nomi file ACI cambiano tra gli anni

## Schema clean

| Colonna | Tipo | Note |
|---|---|---|
| anno | INTEGER | anno di riferimento |
| comune | VARCHAR | solo `tipoEnteTerritoriale = 'Comune'` |
| provincia | VARCHAR | da ISTAT |
| codice_istat | VARCHAR | da ISTAT (join per denominazione) |
| regione | VARCHAR | da ISTAT |
| popolazione_residente | INTEGER | da ISTAT |
| alimentazione | VARCHAR | Benzina, Gasolio, Elettrica, Ibrido BE/GE, GPL, … |
| prime_iscrizioni | BIGINT | immatricolazioni nuove |

## Join ISTAT

Support external GCS (`istat_elenco_comuni` snapshot 2026, URI senza `{year}`).
Placeholder: `{support.istat_comuni.path}`.
Join **comune + provincia** (non solo denominazione): evita fan-out su omonimi
(Castro, Samone, Peglio, San Teodoro…). Match ISTAT ~93% dei comuni ACI.
Primary key include la provincia: i comuni omonimi in province diverse sono righe distinte.

## Mart

- `mart_anno_alimentazione` — totale nazionale per anno × alimentazione
- `mart_regione_alimentazione` — totale per regione × anno × alimentazione
- `mart_quota_alimentazione` — quota sul totale nazionale

## Note

- Duplicato funzionale (ma più ricco) del published DI `aci_prime_iscrizioni_autovetture` (solo comune+alimentazione 2017–2024, senza ISTAT)
- In questo repo autonomo teniamo la serie completa 2017–2025 con arricchimento territoriale
