# aci_parco_veicolare

Stock ACI **Autoritratto**: autovetture circolanti per **alimentazione** al 31/12.

## Perché conta

Complementa flussi LOD/Auto-Trend:
- LOD / Auto-Trend = **quante auto nuove** si immatricolano
- Qui = **quante auto ci sono** sul territorio (es. elettriche in circolazione)

## Fonte

- [aci.gov.it — Autoritratto / Open Data](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/)
- ZIP `Autoritratto*Parco*Veicolare*.zip`, CC-BY 4.0
- Foglio: `4 AV Alimentazione anno immat`

## Anni in scope (v0)

| Anno | ZIP | Layout |
|---|---|---|
| 2024 | `Autoritratto-2024-Parco-Veicolare.zip` | stabile |
| 2025 | `Autoritratto2025_Parco_veicolare.zip` | stabile |
| 2019–2023 | diversi (skip/header/sheet nomi) | backlog |

2021 pubblicato come **RAR** (non supportato da toolkit raw zip).

## Schema clean

| Colonna | Note |
|---|---|
| anno_riferimento | anno del parco (31/12) |
| alimentazione | BENZINA, ELETTRICITA, IBRIDO… |
| veicoli | totale da colonna Totale |

Fasce di anno immatricolazione non ancora unpivoted (nomi colonne non omogenei tra anni).

## Mart

- `mart_av_alimentazione`
- `mart_quota_alimentazione` (quote sul totale nazionale)

## Out of scope v0

- Provincia/comune del parco (fogli geografici, layout diverso)
- Fasce immatricolazione / cilindrata
- Anni < 2024
- Usato / passaggi proprietà (P3 separato)
