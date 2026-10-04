"""Parco veicolare e usato — stock e passaggi di proprietà."""

from __future__ import annotations

import streamlit as st
from sources import fmt_num, fmt_pct, load_mart, SLUG_PARCO, SLUG_USATO

st.title("🅿️ Parco e usato")
st.caption("Stock autovetture per alimentazione e passaggi di proprietà (Autoritratto ACI).")

tab1, tab2 = st.tabs(["Parco veicolare", "Usato / passaggi"])

with tab1:
    st.subheader("Stock AV per alimentazione")
    try:
        df = load_mart(SLUG_PARCO, "mart_av_alimentazione")
        quota = load_mart(SLUG_PARCO, "mart_quota_alimentazione")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")
        df, quota = None, None

    if df is None or df.empty:
        st.info("Nessun dato parco. Esegui `make run`.")
    else:
        years = sorted(df["anno_riferimento"].unique())
        year = st.selectbox("Anno del parco (31/12)", years, index=len(years) - 1, key="parco_year")
        ydf = df[df["anno_riferimento"] == year].sort_values("veicoli", ascending=False)
        st.dataframe(
            ydf.assign(veicoli=ydf["veicoli"].map(lambda v: fmt_num(float(v)))),
            width="stretch",
            hide_index=True,
        )

        try:
            import plotly.express as px

            fig = px.bar(
                ydf,
                x="veicoli",
                y="alimentazione",
                orientation="h",
                title=f"Parco AV per alimentazione · {year}",
            )
            fig.update_layout(height=420, margin={"t": 20, "b": 40})
            st.plotly_chart(fig, width="stretch")
        except ImportError:
            pass

        if quota is not None and not quota.empty:
            st.subheader("Quote sul totale parco")
            qy = quota[quota["anno_riferimento"] == year].copy()
            if "quota_totale" in qy.columns:
                qy["quota_pct"] = qy["quota_totale"] * 100
                st.dataframe(
                    qy.sort_values("veicoli", ascending=False)[
                        ["alimentazione", "veicoli", "quota_pct"]
                    ],
                    width="stretch",
                    hide_index=True,
                )

with tab2:
    st.subheader("Passaggi di proprietà per categoria")
    try:
        cat = load_mart(SLUG_USATO, "mart_usato_categoria")
        sint = load_mart(SLUG_USATO, "mart_usato_sintesi")
    except Exception as e:  # noqa: BLE001
        st.warning(f"Dati non disponibili: {e}")
        cat, sint = None, None

    if cat is None or cat.empty:
        st.info("Nessun dato usato. Esegui `make run`.")
    else:
        years = sorted(cat["anno_riferimento"].unique())
        year = st.selectbox("Anno", years, index=len(years) - 1, key="usato_year")
        cdf = cat[cat["anno_riferimento"] == year].sort_values("totale", ascending=False)
        st.dataframe(
            cdf.assign(
                minivolture=cdf["minivolture"].map(lambda v: fmt_num(float(v)) if v is not None else ""),
                non_minivolture=cdf["non_minivolture"].map(
                    lambda v: fmt_num(float(v)) if v is not None else ""
                ),
                totale=cdf["totale"].map(lambda v: fmt_num(float(v))),
            ),
            width="stretch",
            hide_index=True,
        )

        if sint is not None and not sint.empty:
            srow = sint[sint["anno_riferimento"] == year]
            if not srow.empty:
                r = srow.iloc[0]
                c1, c2, c3 = st.columns(3)
                c1.metric("Passaggi totali", fmt_num(float(r["totale_usato"])))
                c2.metric("Autovetture", fmt_num(float(r["totale_av"])))
                if "quote_minivolture_av" in sint.columns:
                    c3.metric(
                        "Quota minivolture AV",
                        fmt_pct(float(r["quote_minivolture_av"]))
                        if r["quote_minivolture_av"] is not None
                        else "—",
                    )
