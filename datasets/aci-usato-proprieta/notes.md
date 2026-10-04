# aci_usato_proprieta

Passaggi di proprietà (mercato **usato**) ACI — Autoritratto.

## Perché conta

Complementa flussi e stock:
- Auto-Trend / LOD = immatricolazioni e radiazioni
- Parco veicolare = quante auto ci sono
- Qui = **quante auto cambiano proprietario** (usato), con split **minivolture**

## Fonte

- [aci.gov.it — Autoritratto / Open Data](https://aci.gov.it/attivita-e-progetti/studi-e-ricerche/open-data/)
- File xlsx annuali (`Autoritratto*Usato*.xlsx`), CC-BY 4.0
- Foglio: `1` (Specifiche: nazionale, trasferimenti per classe + minivolture)

## Anni in scope (v0)

| Anno | File |
|---|---|
| 2024 | `Autoritratto-2024-Usato.xlsx` |
| 2025 | `Autoritratto2025_-Usato.xlsx` |
| 2019–2023 | layout/formati non omogenei — backlog |

## Schema clean

| Colonna | Note |
|---|---|
| anno_riferimento | anno del rilevamento |
| categoria | AUTOVETTURE, MOTOCICLI, AUTOCARRI… |
| minivolture | passaggi “minivoltura” |
| non_minivolture | resti |
| totale | totale passaggi |

## Mart

- `mart_usato_categoria`
- `mart_usato_sintesi` (totale usato, quota AV, quota minivolture AV)

## Out of scope v0

- Foglio 13: usato netto per provincia × categoria (backlog)
- Classi euro / fasce immatricolazione dell’usato
- Anni &lt; 2024
