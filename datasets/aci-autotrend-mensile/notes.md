# aci_autotrend_mensile

Auto-Trend ACI: mercato auto mensile per **ufficio PRA** (provincia).

## Anni in scope (v0)

| Anno | Formato ZIP | In pipeline |
|---|---|---|
| 2019 | ODS | no (toolkit clean: csv/xlsx/xls) |
| 2020 | CSV | sì |
| 2021 | CSV | sì |
| 2022 | ODS | no |
| 2023 | ODS | no |
| 2024 | CSV | sì |
| 2025 | CSV | sì |

> Gap ODS: 2019/2022/2023 sono nello stesso open data ACI ma solo come `.ods`.
> Toolkit non legge ODS (solo xlsx/xls). Da aprire come follow-up toolkit o conversione.

## Fonte

- [aci.gov.it — Auto-Trend open data](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/)
- ZIP annuali, CC-BY 4.0
- Canale istituzionale ACI (non lod.aci.it)

## Contenuto

File provinciale: `Prime, usato netto e rad.ni AV mese-pv YYYY.csv`

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

- Categorie veicolo / minivolture (CSV secondari nello ZIP)
- Anni ODS
- PDF mensili editoriali
