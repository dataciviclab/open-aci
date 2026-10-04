"""Panoramica — KPI parco auto ACI."""

from __future__ import annotations

import streamlit as st
from sources import SLUG_PRIME, SLUG_RADIAZIONI, get_years, load_mart

st.title("🚗 Panoramica parco auto ACI")
st.caption("Prime iscrizioni e radiazioni per demolizione — dati ACI 2017–2025")

years = get_years()
year = st.selectbox("Anno", years, index=len(years) - 1)

col1, col2 = st.columns(2)

with col1:
    st.subheader(f"Prime iscrizioni · {year}")
    try:
        df = load_mart(SLUG_PRIME, "mart_anno_alimentazione")
        if df is not None and not df.empty:
            df_y = df[df["anno"] == year]
            tot = int(df_y["prime_iscrizioni"].sum()) if not df_y.empty else 0
            n_alim = int(df_y["alimentazione"].nunique()) if not df_y.empty else 0
            st.metric("Totale immatricolazioni", f"{tot:,}".replace(",", "."))
            st.metric("Tipi alimentazione", n_alim)
            st.dataframe(
                df_y.sort_values("prime_iscrizioni", ascending=False),
                width="stretch",
            )
        else:
            st.info("Nessun dato mart. Esegui `make run`.")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")

with col2:
    st.subheader(f"Radiazioni demolizione · {year}")
    try:
        df = load_mart(SLUG_RADIAZIONI, "mart_anno_classe_euro")
        if df is not None and not df.empty:
            df_y = df[df["anno"] == year]
            tot = int(df_y["radiazioni"].sum()) if not df_y.empty else 0
            n_euro = int(df_y["classe_euro"].nunique()) if not df_y.empty else 0
            st.metric("Totale radiazioni", f"{tot:,}".replace(",", "."))
            st.metric("Classi euro", n_euro)
            st.dataframe(
                df_y.sort_values("radiazioni", ascending=False),
                width="stretch",
            )
        else:
            st.info("Nessun dato mart. Esegui `make run`.")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")
