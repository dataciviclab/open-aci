"""Prime iscrizioni — trend alimentazione e territorio."""

from __future__ import annotations

import streamlit as st
from sources import SLUG_PRIME, get_years, load_mart, query_prime

st.title("⚡ Prime iscrizioni per alimentazione")

years = get_years()
year = st.selectbox("Anno (dettaglio comune)", years, index=len(years) - 1)

st.subheader("Serie nazionale per alimentazione")
try:
    df = load_mart(SLUG_PRIME, "mart_anno_alimentazione")
    if df is not None and not df.empty:
        try:
            import plotly.express as px

            fig = px.bar(
                df,
                x="anno",
                y="prime_iscrizioni",
                color="alimentazione",
                title="Prime iscrizioni per anno e alimentazione",
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

st.subheader(f"Quota alimentazione · {year}")
try:
    df = load_mart(SLUG_PRIME, "mart_quota_alimentazione")
    if df is not None and not df.empty:
        df = df[df["anno"] == year].copy()
        df["quota_pct"] = df["quota_totale"] * 100
        st.dataframe(
            df.sort_values("prime_iscrizioni", ascending=False)[
                ["alimentazione", "prime_iscrizioni", "quota_pct"]
            ],
            width="stretch",
        )
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati non disponibili: {e}")

st.subheader("Top comuni per alimentazione")
alim = st.selectbox(
    "Alimentazione",
    ["Elettrica", "Ibrido Benzina-Elettrico", "Benzina", "Gasolio"],
    index=0,
)
try:
    df = query_prime(
        f"""
        SELECT comune, provincia, regione, prime_iscrizioni
        FROM clean_input
        WHERE anno = {year} AND alimentazione = '{alim}'
        ORDER BY prime_iscrizioni DESC
        LIMIT 25
        """,
        years=(year,),
    )
    if df is not None and not df.empty:
        st.dataframe(df, width="stretch")
    else:
        st.info(f"Nessun dato per {alim} nel {year}.")
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati non disponibili: {e}")
