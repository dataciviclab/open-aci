# aci_radiazioni_classe_euro

Radiazioni per demolizione di autovetture per comune e classe euro, 2017–2025.

## Fonte

- ACI — Automobile Club Italia, via dati.gov.it / lod.aci.it
- CSV tidy, CC-BY 4.0
- Una fonte HTTP per anno (`raw.sources[].year`)

## Schema clean

| Colonna | Tipo | Note |
|---|---|---|
| anno | INTEGER | anno di riferimento |
| comune | VARCHAR | solo Comuni |
| provincia / codice_istat / regione / popolazione_residente | — | da ISTAT |
| classe_euro | VARCHAR | Euro 0…Euro 6, “Euro non disponibile” |
| radiazioni | BIGINT | demolizioni / cessazioni dalla circolazione |

## Mart

- `mart_anno_classe_euro` — totale nazionale per anno × classe euro
- `mart_regione_classe_euro` — totale per regione × anno × classe euro
- `mart_quota_classe_euro` — quota sul totale nazionale

## Domanda guida

Quante auto vecchie escono dal parco, e come cambia la composizione per classe euro? Complementare alle prime iscrizioni (flusso in entrata vs uscita).
