"""Query SQL sui clean layer ACI."""

from __future__ import annotations

import streamlit as st
from sources import SLUG_PRIME, SLUG_RADIAZIONI, YEARS, query_prime, query_radiazioni

st.title("🧪 Query SQL")

slug = st.radio(
    "Dataset",
    [SLUG_PRIME, SLUG_RADIAZIONI],
    format_func=lambda s: "Prime iscrizioni" if s == SLUG_PRIME else "Radiazioni classe euro",
)
year = st.selectbox("Anno", YEARS, index=len(YEARS) - 1)

default_sql = (
    "SELECT comune, provincia, alimentazione, prime_iscrizioni\n"
    "FROM clean_input\n"
    "WHERE alimentazione = 'Elettrica'\n"
    "ORDER BY prime_iscrizioni DESC\n"
    "LIMIT 20"
    if slug == SLUG_PRIME
    else "SELECT comune, provincia, classe_euro, radiazioni\n"
    "FROM clean_input\n"
    "ORDER BY radiazioni DESC\n"
    "LIMIT 20"
)

sql = st.text_area("SQL (usa clean_input)", value=default_sql, height=200)

if st.button("Esegui"):
    try:
        runner = query_prime if slug == SLUG_PRIME else query_radiazioni
        df = runner(sql, years=(year,))
        if df is None or df.empty:
            st.info("Query senza risultati.")
        else:
            st.dataframe(df, width="stretch")
            st.caption(f"{len(df)} righe · anno {year}")
    except Exception as e:  # noqa: BLE001
        st.error(f"Errore query: {e}")
