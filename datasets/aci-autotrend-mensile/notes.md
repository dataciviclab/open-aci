# aci_autotrend_mensile

Auto-Trend ACI: mercato auto mensile per **ufficio PRA** (provincia), 2019–2025.

## Fonte

- [aci.gov.it — Auto-Trend open data](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/)
- ZIP annuali, CC-BY 4.0
- Canale istituzionale ACI (non lod.aci.it)

## Formati nei ZIP

| Anno | Formato file provinciale |
|---|---|
| 2019 | ODS |
| 2020–2021 | CSV |
| 2022–2023 | ODS |
| 2024–2025 | CSV |

Pulito con `include: Prime*AV*mese-pv*` (csv + ods).  
Lettura ODS: toolkit clean `engine=odf` (branch `feat/clean-ods`, dipendenza `odfpy`).

## Contenuto

| Clean | Note |
|---|---|
| anno | anno di riferimento |
| mese / mese_num | italiano + num per grafici |
| ufficio_pra | provincia / ufficio PRA |
| formalita | `prime_iscrizioni` · `usato_netto` · `radiazioni` |
| quantita | `remove_dot_thousands` (punti migliaia) |

## Mart

- `mart_anno_formalita`
- `mart_anno_mese_formalita`
- `mart_anno_provincia_formalita`
- `mart_trend_mensile` (con `mese_num`)

## Perché conta

Frequenza **mensile** × granularità **provinciale** — complementa LOD comunale annuale.

## Out of scope v0

- Categorie veicolo / minivolture (file secondari nello ZIP)
- PDF mensili editoriali
