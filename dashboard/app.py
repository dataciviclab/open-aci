#!/usr/bin/env python3
"""
Open ACI · Dashboard Streamlit
Parco auto italiano — prime iscrizioni e radiazioni per comune.
"""

import streamlit as st
from lab_connectors.branding import apply_branding

st.set_page_config(
    page_title="Open ACI · Dashboard",
    page_icon="🚗",
    layout="wide",
    initial_sidebar_state="expanded",
)

apply_branding(repo_name="open-aci", repo_url="https://github.com/dataciviclab/open-aci")

pages = {
    "": [
        st.Page("pages/01_Panoramica.py", title="Panoramica", icon="📊", default=True),
    ],
    "Analisi": [
        st.Page("pages/02_Prima_Iscrizioni.py", title="Prime iscrizioni", icon="⚡"),
        st.Page("pages/03_Radiazioni.py", title="Radiazioni", icon="♻️"),
    ],
    "Strumenti": [
        st.Page("pages/04_SQL.py", title="Query SQL", icon="🧪"),
    ],
}

pg = st.navigation(pages, position="sidebar")
pg.run()
