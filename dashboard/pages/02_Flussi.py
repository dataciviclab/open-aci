"""Flussi comunali — prime iscrizioni e radiazioni."""

from __future__ import annotations

import streamlit as st
from sources import (
    fmt_num,
    fmt_pct,
    load_mart,
    SLUG_PRIME,
    SLUG_RADIAZIONI,
)

st.title("🛣️ Flussi comunali ACI")
st.caption("Prime iscrizioni × alimentazione e radiazioni × classe euro (lod.aci.it).")

tab1, tab2 = st.tabs(["Prime iscrizioni", "Radiazioni"])

with tab1:
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
                fig.update_layout(height=420, margin={"t": 20, "b": 40})
                st.plotly_chart(fig, width="stretch")
            except ImportError:
                st.dataframe(df, width="stretch")

            st.subheader("Quota sul totale")
            try:
                q = load_mart(SLUG_PRIME, "mart_quota_alimentazione")
                if q is not None and not q.empty:
                    years = sorted(q["anno"].unique())
                    year = st.selectbox("Anno", years, index=len(years) - 1, key="prime_year")
                    qy = q[q["anno"] == year].copy()
                    qy["quota_pct"] = qy["quota_totale"] * 100
                    st.dataframe(
                        qy.sort_values("prime_iscrizioni", ascending=False)[
                            ["alimentazione", "prime_iscrizioni", "quota_pct"]
                        ],
                        width="stretch",
                        hide_index=True,
                    )
            except Exception as e:  # noqa: BLE001
                st.warning(f"Quote non disponibili: {e}")
        else:
            st.info("Nessun dato. Esegui `make run`.")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")

with tab2:
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
                fig.update_layout(height=420, margin={"t": 20, "b": 40})
                st.plotly_chart(fig, width="stretch")
            except ImportError:
                st.dataframe(df, width="stretch")

            st.subheader("Quota classe euro")
            try:
                q = load_mart(SLUG_RADIAZIONI, "mart_quota_classe_euro")
                if q is not None and not q.empty:
                    years = sorted(q["anno"].unique())
                    year = st.selectbox("Anno", years, index=len(years) - 1, key="rad_year")
                    qy = q[q["anno"] == year].copy()
                    qy["quota_pct"] = qy["quota_totale"] * 100
                    st.dataframe(
                        qy.sort_values("radiazioni", ascending=False)[
                            ["classe_euro", "radiazioni", "quota_pct"]
                        ],
                        width="stretch",
                        hide_index=True,
                    )
            except Exception as e:  # noqa: BLE001
                st.warning(f"Quote non disponibili: {e}")
        else:
            st.info("Nessun dato. Esegui `make run`.")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")
