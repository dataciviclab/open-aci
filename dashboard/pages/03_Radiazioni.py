"""Radiazioni per demolizione — classe euro e territorio."""

from __future__ import annotations

import streamlit as st
from sources import SLUG_RADIAZIONI, get_years, load_mart, query_radiazioni

st.title("♻️ Radiazioni per demolizione")

years = get_years()
year = st.selectbox("Anno (dettaglio comune)", years, index=len(years) - 1)

st.subheader("Serie nazionale per classe euro")
try:
    df = load_mart(SLUG_RADIAZIONI, "mart_anno_classe_euro")
    if df is not None and not df.empty:
        try:
            import plotly.express as px

            fig = px.bar(
                df,
                x="anno",
                y="radiazioni",
                color="classe_euro",
                title="Radiazioni per anno e classe euro",
                barmode="stack",
            )
            fig.update_layout(height=500)
            st.plotly_chart(fig, width="stretch")
        except ImportError:
            st.dataframe(df, width="stretch")
    else:
        st.info("Nessun dato. Esegui `make run`.")
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati non disponibili: {e}")

st.subheader(f"Quota classe euro · {year}")
try:
    df = load_mart(SLUG_RADIAZIONI, "mart_quota_classe_euro")
    if df is not None and not df.empty:
        df = df[df["anno"] == year].copy()
        df["quota_pct"] = df["quota_totale"] * 100
        st.dataframe(
            df.sort_values("radiazioni", ascending=False)[
                ["classe_euro", "radiazioni", "quota_pct"]
            ],
            width="stretch",
        )
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati non disponibili: {e}")

st.subheader(f"Top comuni per radiazioni · {year}")
try:
    df = query_radiazioni(
        f"""
        SELECT comune, provincia, regione, SUM(radiazioni) AS radiazioni
        FROM clean_input
        WHERE anno = {year}
        GROUP BY comune, provincia, regione
        ORDER BY radiazioni DESC
        LIMIT 25
        """,
        years=(year,),
    )
    if df is not None and not df.empty:
        st.dataframe(df, width="stretch")
    else:
        st.info("Nessun dato.")
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati non disponibili: {e}")
