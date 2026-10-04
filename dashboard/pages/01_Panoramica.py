"""Panoramica — KPI del parco auto ACI."""

from __future__ import annotations

import pandas as pd
import streamlit as st
from sources import fmt_num, fmt_pct, load_mart, SLUG_PARCO, SLUG_PRIME, SLUG_RADIAZIONI, SLUG_USATO

st.title("🚗 Open ACI · Panoramica")
st.caption(
    "Flussi comunali, stock parco e mercato dell’usato — dati ACI puliti dal Lab."
)


def _safe_load(slug: str, table: str):
    try:
        df = load_mart(slug, table)
        return df if df is not None and not df.empty else None
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili per `{slug}`: {e}")
        return None


col1, col2 = st.columns(2)

# ── Prime iscrizioni (flusso) ─────────────────────────────────────────
with col1:
    st.subheader("Prime iscrizioni · quota elettrica")
    df = _safe_load(SLUG_PRIME, "mart_quota_alimentazione")
    if df is not None:
        # Solo BEV puri — non ibridi (contiene "Elettrico")
        ev = df[
            df["alimentazione"].astype(str).str.strip().str.upper().eq("ELETTRICA")
        ]
        if not ev.empty:
            ev = ev.sort_values("anno")
            latest = ev.iloc[-1]
            prev = ev.iloc[-2] if len(ev) > 1 else None
            delta = None
            if prev is not None:
                delta = f"{(float(latest['quota_totale']) - float(prev['quota_totale'])) * 100:+.1f} p.p."
            st.metric(
                "Elettriche (share immatricolazioni)",
                fmt_pct(float(latest["quota_totale"])),
                delta=delta,
                help=(
                    f"Anno {int(latest['anno'])} · solo alimentazione Elettrica (BEV) "
                    f"· esclusi ibridi"
                ),
            )
            st.caption(f"Anno di riferimento: {int(latest['anno'])}")
        else:
            st.info("Nessun dato BEV nei mart.")
    else:
        st.info("Esegui `make run` o attendi sync GCS.")

# ── Parco veicolare (stock) ───────────────────────────────────────────
with col2:
    st.subheader("Parco · stock elettriche in circolazione")
    df = _safe_load(SLUG_PARCO, "mart_av_alimentazione")
    if df is not None:
        # Autoritratto usa ELETTRICITA (BEV puri)
        ev = df[
            df["alimentazione"].astype(str).str.strip().str.upper().eq("ELETTRICITA")
        ]
        if not ev.empty:
            ev = ev.sort_values("anno_riferimento")
            latest = ev.iloc[-1]
            prev = ev.iloc[-2] if len(ev) > 1 else None
            delta = None
            if prev is not None and float(prev["veicoli"]) > 0:
                pct = (float(latest["veicoli"]) - float(prev["veicoli"])) / float(prev["veicoli"])
                delta = f"{pct * 100:+.1f}%"
            st.metric(
                "AV elettriche in circolazione",
                fmt_num(float(latest["veicoli"])),
                delta=delta,
                help=(
                    f"Stock al 31/12/{int(latest['anno_riferimento'])} · Autoritratto "
                    f"· solo ELETTRICITA"
                ),
            )
        else:
            st.info("Nessun dato stock BEV.")
    else:
        st.info("Esegui `make run` o attendi sync GCS.")

col3, col4 = st.columns(2)

# ── Radiazioni ────────────────────────────────────────────────────────
with col3:
    st.subheader("Radiazioni · totale nazionale")
    df = _safe_load(SLUG_RADIAZIONI, "mart_anno_classe_euro")
    if df is not None:
        by_year = (
            df.groupby("anno", as_index=False)["radiazioni"]
            .sum()
            .sort_values("anno")
        )
        if not by_year.empty:
            latest = by_year.iloc[-1]
            st.metric(
                "Radiazioni demolizione",
                fmt_num(float(latest["radiazioni"])),
                help=f"Anno {int(latest['anno'])}",
            )
            try:
                import plotly.express as px

                fig = px.bar(
                    by_year,
                    x="anno",
                    y="radiazioni",
                    title="Radiazioni per anno",
                )
                fig.update_layout(height=280, margin={"t": 20, "b": 40})
                st.plotly_chart(fig, width="stretch")
            except ImportError:
                st.dataframe(by_year, width="stretch")
    else:
        st.info("Nessun dato radiazioni.")

# ── Usato ─────────────────────────────────────────────────────────────
with col4:
    st.subheader("Usato · passaggi di proprietà")
    df = _safe_load(SLUG_USATO, "mart_usato_sintesi")
    if df is not None and not df.empty:
        latest = df.sort_values("anno_riferimento").iloc[-1]
        st.metric(
            "Passaggi totali",
            fmt_num(float(latest["totale_usato"])),
            help=f"Anno {int(latest['anno_riferimento'])}",
        )
        st.metric(
            "Autovetture",
            fmt_num(float(latest["totale_av"])),
        )
        if "quote_minivolture_av" in df.columns and pd.notna(latest.get("quote_minivolture_av")):
            st.metric("Quota minivolture AV", fmt_pct(float(latest["quote_minivolture_av"])))
    else:
        st.info("Nessun dato usato.")

with st.expander("Dataset nel repo"):
    st.markdown(
        """
| Dataset | Copertura |
|---|---|
| `aci_prime_iscrizioni_autovetture` | 2017–2025 comunale |
| `aci_radiazioni_classe_euro` | 2017–2025 comunale |
| `aci_autotrend_mensile` | 2019–2025 provincia × mese |
| `aci_parco_veicolare` | 2024–2025 stock AV |
| `aci_usato_proprieta` | 2024–2025 passaggi |
"""
    )
