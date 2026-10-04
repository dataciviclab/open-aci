# open-ACI — Il parco auto italiano, aperto e interrogabile

[![check](https://github.com/dataciviclab/open-aci/actions/workflows/check.yml/badge.svg)](https://github.com/dataciviclab/open-aci/actions/workflows/check.yml)
[![pipeline](https://github.com/dataciviclab/open-aci/actions/workflows/pipeline.yml/badge.svg)](https://github.com/dataciviclab/open-aci/actions/workflows/pipeline.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Quante auto nuove elettriche vengono immatricolate nel tuo comune? E quante vecchie escono dal parco — e quante cambiano proprietario?**

open-ACI raccoglie i dati pubblici dell’Automobile Club Italia sul parco veicolare e li rende leggibili: flussi comunali, mercato mensile provinciale, stock per alimentazione e passaggi di proprietà (usato).

## Perché questi dati

Il PRA è la fonte primaria del parco auto italiano. ACI la pubblica in open data, ma in pezzi sparsi (CSV comunali, ZIP mensili, Excel multi-foglio). Qui i dataset sono puliti, arricchiti e pronti per domande civiche sulla transizione energetica, il rinnovo del parco e il mercato dell’usato.

## Cosa contengono

| | |
|---|---|
| **Fonte** | ACI — Automobile Club Italia · [lod.aci.it](http://lod.aci.it/) · [aci.gov.it](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/) |
| **Licenza** | CC-BY 4.0 (dati) · MIT (codice di questo repo) |
| **Dataset** | 5 serie |
| **Periodo** | 2017–2025 (comunale LOD) · 2019–2025 (mensile provinciale) · 2024–2025 (stock / usato) |
| **Granularità** | Comune · Provincia (ufficio PRA) · Nazionale |

| Dataset | Cosa misura | Anni | Granularità |
|---|---|---|---|
| `aci_prime_iscrizioni_autovetture` | Immatricolazioni nuove per alimentazione | 2017–2025 | Comune |
| `aci_radiazioni_classe_euro` | Radiazioni per demolizione per classe euro | 2017–2025 | Comune |
| `aci_autotrend_mensile` | Prime iscrizioni, usato netto, radiazioni | 2019–2025 | Provincia × mese |
| `aci_parco_veicolare` | Stock autovetture per alimentazione (31/12) | 2024–2025 | Nazionale |
| `aci_usato_proprieta` | Passaggi di proprietà e minivolture | 2024–2025 | Nazionale × categoria |

I dataset comunali sono arricchiti con codice ISTAT, regione e popolazione.

## Esempi di domande

- **Quante auto elettriche si immatricolano nel mio comune?** E quante ibride?
- **Come cambia la quota di elettrico tra regioni negli ultimi anni?**
- **Quante auto vengono demolite, e di quale classe euro?**
- **Come gira il mercato auto mese per mese in provincia?**
- **Quante auto elettriche ci sono già in circolazione, non solo quelle nuove?**
- **Quante auto usate cambiano proprietario, e quante sono minivolture?**

## Come accedere

### 1. DuckDB (locale o remoto)

```sql
-- Esempio: quota elettrica sulle prime iscrizioni per anno
SELECT anno, SUM(prime_iscrizioni) AS ev
FROM read_parquet('out/data/mart/aci_prime_iscrizioni_autovetture/mart_anno_alimentazione.parquet')
WHERE alimentazione = 'Elettrica'
GROUP BY anno ORDER BY anno;
```

Dopo un run locale (`make run`), i parquet sono in `out/data/clean/` e `out/data/mart/`.

### 2. Parquet / GCS

Quando il repo è sincronizzato sul bucket del Lab, i clean/mart sono leggibili da `gs://dataciviclab-clean/` con lo slug del dataset (stesso pattern di open-siope).

### 3. MCP del Lab

I dataset esposti nel catalogo Lab sono interrogabili da agenti e CLI via toolkit MCP (`toolkit_find`, `toolkit_layer`, `toolkit_registry_show`).

## Approfondimenti

- [Discussions di questo repo](https://github.com/dataciviclab/open-aci/discussions) — domande e spunti
- [DataCivicLab](https://github.com/dataciviclab/dataciviclab) — analisi e findings del Lab
- Fonte ACI: [Open Data istituzionale](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/) · [Linked Open Data](http://lod.aci.it/)

## Partecipa

- **Hai una domanda sui dati?** Apri una [Discussion](https://github.com/dataciviclab/open-aci/discussions/new)
- **Hai trovato un errore o vuoi estendere una serie?** Apri un’[Issue](https://github.com/dataciviclab/open-aci/issues)
- **Contributi tecnici:** vedi [CONTRIBUTING.md](CONTRIBUTING.md) — pipeline con `toolkit`, test contract, standard DataCivicLab

Licenza del codice: [MIT](LICENSE).  
Questo progetto fa parte di [DataCivicLab](https://github.com/dataciviclab).
