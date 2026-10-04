# open-ACI — Il parco auto italiano, aperto e interrogabile

**Quante auto nuove elettriche vengono immatricolate nel tuo comune? E quante vecchie escono dal parco?**

open-ACI pulisce i dati pubblici dell'Automobile Club Italia (PRA) su prime iscrizioni e radiazioni per demolizione, a livello comunale.

## Cosa contiene

| | |
|---|---|
| **Fonte** | ACI — Automobile Club Italia (lod.aci.it / dati.gov.it), CC-BY 4.0 |
| **Periodo** | 2017 — 2025 (LOD) · 2020–2021, 2024–2025 (Auto-Trend CSV) |
| **Granularità** | Comune (solo enti territoriali di tipo Comune) |
| **Dataset** | `aci_prime_iscrizioni_autovetture` · `aci_radiazioni_classe_euro` · `aci_autotrend_mensile` · `aci_parco_veicolare` · `aci_usato_proprieta` |
| **Arricchimento** | Codice ISTAT, regione, popolazione (support ISTAT Lab) |

## Esempi di domande

- **Quante auto elettriche si immatricolano nel mio comune?** E quante ibride?
- **Come cambia la quota di elettrico tra regioni?**
- **Quante auto vengono demolite, e di quale classe euro?**
- **Come gira il mercato auto mese per mese in provincia?** (Auto-Trend)
- **Il rinnovo del parco è omogeneo sul territorio?**

## Struttura del repo

```
datasets/<slug>/     dataset.yml + sql/clean.sql + sql/mart_*.sql
registry/            artifact registry
dashboard/           Streamlit (lab-connectors + DuckDB)
tests/               contract test struttura repo
out/                 output pipeline (non versionato)
_legacy/             esperimento storico (non parte del contratto)
```

Archetipo **Dataset** (ADR-001). Non è un candidate DI: repo autonomo con pipeline toolkit + dashboard.

## Pipeline

```bash
make check    # preflight dataset.yml
make run      # raw → clean → mart (toolkit)
make clean    # rimuove out/
make test     # contract test
```

Raw: `http_file` da lod.aci.it (LOD) e aci.gov.it (Auto-Trend ZIP).
Clean: macro standard; ISTAT via support external `{support.istat_comuni.path}`.
Mart: aggregazioni multi-anno (`mart.tables[].years`). Auto-Trend include anni solo-CSV (ODS fuori scope toolkit).

## Accesso ai dati

1. **Locale**: `out/data/clean/<slug>/<year>/` e `out/data/mart/<slug>/<year>/`
2. **Dashboard**: `streamlit run dashboard/app.py`
3. **MCP Lab**: dataset esposti se registrati nel catalogo Lab

## Domanda civica

Il Lab usa questi dati per leggere la **transizione energetica del parco auto** a livello comunale: flussi in entrata (prime iscrizioni × alimentazione) e in uscita (radiazioni × classe euro).

## Partecipa

- Problemi e idee: apri un'issue su questo repo
- Contributi: vedi [CONTRIBUTING.md](CONTRIBUTING.md)

Questo progetto fa parte di [DataCivicLab](https://github.com/dataciviclab).
