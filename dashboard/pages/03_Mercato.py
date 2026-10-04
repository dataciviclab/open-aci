"""Mercato mensile — Auto-Trend (nazionale) + top province."""

from __future__ import annotations

import streamlit as st
from sources import fmt_num, load_mart, SLUG_AUTOTREND

st.title("📆 Mercato auto · Auto-Trend")
st.caption("Prime iscrizioni, usato netto e radiazioni — serie mensile nazionale e top province.")

# Mart nazionali (senza provincia)
try:
    trend = load_mart(SLUG_AUTOTREND, "mart_trend_mensile")
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati trend mensile non disponibili: {e}")
    trend = None

# Mart provinciali (anno × ufficio PRA × formalità)
try:
    prov = load_mart(SLUG_AUTOTREND, "mart_anno_provincia_formalita")
except Exception as e:  # noqa: BLE001
    st.warning(f"Dati provinciali non disponibili: {e}")
    prov = None

if trend is None or trend.empty:
    st.info("Nessun dato Auto-Trend. Esegui `make run` o attendi sync GCS.")
    st.stop()

formalita = sorted(trend["formalita"].dropna().unique())
default_idx = formalita.index("prime_iscrizioni") if "prime_iscrizioni" in formalita else 0
f_sel = st.selectbox("Formalità", formalita, index=default_idx)

sub = trend[trend["formalita"] == f_sel]
years = sorted(sub["anno"].unique())
y0, y1 = st.select_slider(
    "Intervallo anni",
    options=years,
    value=(years[0], years[-1]),
)
sub = sub[(sub["anno"] >= y0) & (sub["anno"] <= y1)]

st.subheader(f"Serie mensile nazionale · {f_sel}")
try:
    import plotly.express as px

    monthly = (
        sub.groupby(["anno", "mese_num", "mese"], as_index=False)["quantita"]
        .sum()
        .sort_values(["anno", "mese_num"])
    )
    monthly["periodo"] = monthly["mese_num"].map(lambda m: f"{int(m):02d}")
    fig = px.bar(
        monthly,
        x="periodo",
        y="quantita",
        color=monthly["anno"].astype(str),
        title=f"{f_sel} per mese (Italia)",
        barmode="group",
        labels={"periodo": "mese", "quantita": "quantità", "color": "anno"},
    )
    fig.update_layout(height=420, margin={"t": 20, "b": 40})
    st.plotly_chart(fig, width="stretch")
except ImportError:
    st.dataframe(
        sub.groupby(["anno", "mese_num"])["quantita"].sum().reset_index(),
        width="stretch",
    )

st.subheader("Top uffici PRA (anno più recente)")
if prov is None or prov.empty:
    st.info("Mart provinciale non disponibile.")
else:
    try:
        psub = prov[prov["formalita"] == f_sel]
        latest_year = int(psub["anno"].max())
        latest = psub[psub["anno"] == latest_year]
        top = (
            latest.groupby("ufficio_pra", as_index=False)["quantita"]
            .sum()
            .sort_values("quantita", ascending=False)
            .head(15)
        )
        st.caption(f"Formalità: {f_sel} · anno {latest_year}")
        st.dataframe(
            top.assign(quantita=top["quantita"].map(lambda v: fmt_num(float(v)))),
            width="stretch",
            hide_index=True,
        )
    except Exception as e:  # noqa: BLE001
        st.warning(f"Top province non disponibili: {e}")

with st.expander("Dati grezzi — trend mensile nazionale"):
    st.dataframe(
        sub.sort_values(["anno", "mese_num"]),
        width="stretch",
        hide_index=True,
    )

if prov is not None and not prov.empty:
    with st.expander("Dati grezzi — provincia × anno"):
        psub = prov[prov["formalita"] == f_sel]
        st.dataframe(
            psub.sort_values(["anno", "ufficio_pra"]),
            width="stretch",
            hide_index=True,
        )
