"""Data sources for the Open ACI dashboard — wraps DuckDB + GCS/local out/."""

from __future__ import annotations

from pathlib import Path

import streamlit as st

from lab_connectors.duckdb.queries import (
    detect_local_root,
    load_mart_flat as _load_mart_flat,
    load_mart_table as _load_mart_table,
    query_clean as _query_clean,
)

ROOT = Path(__file__).parent.parent
PREFIX = "aci/"
YEARS = list(range(2017, 2026))
LOCAL_ROOT = detect_local_root(repo_root=ROOT)

SLUG_PRIME = "aci_prime_iscrizioni_autovetture"
SLUG_RADIAZIONI = "aci_radiazioni_classe_euro"

# Mart multi-anno live in out/data/mart/<slug>/<table>.parquet (senza <year>/)
_MULTIYEAR_MARTS = {
    "mart_anno_alimentazione",
    "mart_regione_alimentazione",
    "mart_quota_alimentazione",
    "mart_anno_classe_euro",
    "mart_regione_classe_euro",
    "mart_quota_classe_euro",
}


@st.cache_data(ttl=3600, show_spinner=False)
def load_mart(slug: str, table: str, year: int | None = None):
    if table in _MULTIYEAR_MARTS or year is None:
        return _load_mart_flat(slug, table, prefix=PREFIX, local_root=LOCAL_ROOT)
    return _load_mart_table(slug, table, year, prefix=PREFIX, local_root=LOCAL_ROOT)


@st.cache_data(ttl=3600, show_spinner=False)
def query_prime(sql: str, years: tuple[int, ...] = tuple(YEARS)):
    return _query_clean(SLUG_PRIME, sql, list(years), prefix=PREFIX, local_root=LOCAL_ROOT)


@st.cache_data(ttl=3600, show_spinner=False)
def query_radiazioni(sql: str, years: tuple[int, ...] = tuple(YEARS)):
    return _query_clean(SLUG_RADIAZIONI, sql, list(years), prefix=PREFIX, local_root=LOCAL_ROOT)


def get_years() -> list[int]:
    return list(YEARS)
