"""Data layer — open-aci dashboard.

Legge clean/mart da GCS via lab-connectors (prefix open-aci/).
Fallback locale: out/data/ se presente (detect_local_root).
"""

from __future__ import annotations

from pathlib import Path

import streamlit as st
from lab_connectors.duckdb.queries import (
    detect_local_root,
    load_mart_flat,
    query_clean,
)
from lab_connectors.formatters import fmt_eur, fmt_num, fmt_pct
from lab_connectors.registry import load_registry

REPO_ROOT = Path(__file__).resolve().parent.parent
PREFIX = "open-aci/"
LOCAL_ROOT = detect_local_root(repo_root=REPO_ROOT)

_registry = load_registry(REPO_ROOT / "registry" / "registry.json")
YEARS = list(range(2017, 2026))

SLUG_PRIME = "aci_prime_iscrizioni_autovetture"
SLUG_RADIAZIONI = "aci_radiazioni_classe_euro"
SLUG_AUTOTREND = "aci_autotrend_mensile"
SLUG_PARCO = "aci_parco_veicolare"
SLUG_USATO = "aci_usato_proprieta"


def get_registry():
    return _registry


@st.cache_data(ttl=3600, show_spinner=False)
def load_mart(slug: str, table: str):
    """Mart flat multi-anno da GCS (o locale out/ se presente)."""
    return load_mart_flat(slug, table, prefix=PREFIX, local_root=LOCAL_ROOT)


@st.cache_data(ttl=3600, show_spinner=False)
def query_prime(sql: str, years: tuple[int, ...] = tuple(range(2017, 2026))):
    return query_clean(SLUG_PRIME, sql, list(years), prefix=PREFIX, local_root=LOCAL_ROOT)


@st.cache_data(ttl=3600, show_spinner=False)
def query_radiazioni(sql: str, years: tuple[int, ...] = tuple(range(2017, 2026))):
    return query_clean(SLUG_RADIAZIONI, sql, list(years), prefix=PREFIX, local_root=LOCAL_ROOT)


@st.cache_data(ttl=3600, show_spinner=False)
def query_autotrend(sql: str, years: tuple[int, ...] = tuple(range(2019, 2026))):
    return query_clean(SLUG_AUTOTREND, sql, list(years), prefix=PREFIX, local_root=LOCAL_ROOT)


# Re-export per comodità pagine
__all__ = [
    "PREFIX",
    "YEARS",
    "SLUG_PRIME",
    "SLUG_RADIAZIONI",
    "SLUG_AUTOTREND",
    "SLUG_PARCO",
    "SLUG_USATO",
    "fmt_eur",
    "fmt_num",
    "fmt_pct",
    "get_registry",
    "load_mart",
    "query_prime",
    "query_radiazioni",
    "query_autotrend",
]
