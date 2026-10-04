"""Query SQL sui dataset open-aci."""

from pathlib import Path

from lab_connectors.duckdb.sql_page import render_sql_query
from lab_connectors.registry import load_registry
from sources import PREFIX, SLUG_PRIME

registry = load_registry(Path(__file__).resolve().parent.parent.parent / "registry" / "registry.json")

render_sql_query(
    registry=registry,
    prefix=PREFIX,
    default_slug=SLUG_PRIME,
    title="🧪 Query SQL",
    description=(
        "Interroga direttamente i clean layer ACI. "
        "Usa ``clean_input`` come tabella di partenza."
    ),
)
