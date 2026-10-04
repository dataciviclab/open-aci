"""Contract test per repo open-aci (archetipo Dataset).

Verifica struttura e contratti pubblici:
  - layout multi-dataset
  - dataset.yml valido (years, raw year-tagged, validate, fail_on_error)
  - SQL dichiarati esistenti
  - support ISTAT external, nessun path hardcoded GCS nei clean.sql
  - niente output di run committati

Markers: contract.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest
import yaml

REPO_ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = REPO_ROOT / "out"
REQUIRED_FILES = [
    REPO_ROOT / "Makefile",
    REPO_ROOT / "pyproject.toml",
    REPO_ROOT / "conftest.py",
    REPO_ROOT / "LICENSE",
    REPO_ROOT / "README.md",
    REPO_ROOT / "CONTRIBUTING.md",
    REPO_ROOT / ".gitignore",
    REPO_ROOT / ".github" / "workflows" / "check.yml",
    REPO_ROOT / ".github" / "workflows" / "pipeline.yml",
    REPO_ROOT / "registry" / "registry.json",
]
BLOCKED_OUT_EXTENSIONS = {".parquet", ".csv", ".jsonl", ".zip", ".xlsx", ".tsv"}
EXPECTED_SLUGS = {
    "aci_prime_iscrizioni_autovetture",
    "aci_radiazioni_classe_euro",
    "aci_autotrend_mensile",
}
GCS_HARDCODED = re.compile(r"storage\.googleapis\.com/dataciviclab-clean/istat_elenco_comuni")


def _iter_dataset_configs() -> list[Path]:
    return sorted((REPO_ROOT / "datasets").glob("*/dataset.yml"))


@pytest.fixture(scope="module")
def dataset_configs() -> list[Path]:
    configs = _iter_dataset_configs()
    assert configs, "Il repo deve dichiarare almeno un dataset in datasets/"
    return configs


@pytest.mark.contract
def test_required_files_exist() -> None:
    missing = [str(p.relative_to(REPO_ROOT)) for p in REQUIRED_FILES if not p.exists()]
    assert not missing, f"Missing required files: {missing}"


@pytest.mark.contract
def test_layout_is_multidataset() -> None:
    assert (REPO_ROOT / "datasets").is_dir()
    assert not (REPO_ROOT / "dataset.yml").exists()


@pytest.mark.contract
def test_expected_scope_a_slugs_present(dataset_configs: list[Path]) -> None:
    names = set()
    for cfg in dataset_configs:
        data = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        names.add(data["dataset"]["name"])
    assert EXPECTED_SLUGS <= names, f"Scope A incompleto: presenti {names}, attesi {EXPECTED_SLUGS}"


@pytest.mark.contract
def test_each_dataset_declares_minimum_contract(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        rel = str(cfg.relative_to(REPO_ROOT))
        assert dataset.get("schema_version") == 1, f"{rel}: schema_version != 1"
        assert "root" in dataset
        ds = dataset["dataset"]
        assert ds.get("name")
        assert ds.get("source_id") == "aci", f"{rel}: source_id deve essere aci"
        assert isinstance(ds.get("years"), list) and ds["years"], f"{rel}: years non valida"
        assert ds.get("category") == "trasporti", f"{rel}: category deve essere trasporti"

        raw = dataset["raw"]
        sources = raw.get("sources") or []
        assert sources, f"{rel}: manca raw.sources"
        assert all(s.get("type") == "http_file" for s in sources), f"{rel}: raw deve essere http_file"
        years_tagged = {s.get("year") for s in sources if s.get("year") is not None}
        assert years_tagged == set(ds["years"]), f"{rel}: years delle source != dataset.years"
        assert any(s.get("primary") for s in sources)

        clean = dataset["clean"]
        assert clean.get("sql")
        assert clean.get("required_columns")
        validate = clean.get("validate") or {}
        assert validate.get("primary_key"), f"{rel}: manca clean.validate.primary_key"
        assert validate.get("not_null"), f"{rel}: manca clean.validate.not_null"
        assert validate.get("min_rows"), f"{rel}: manca clean.validate.min_rows"

        mart = dataset["mart"]
        tables = mart.get("tables") or []
        assert tables, f"{rel}: manca mart.tables"
        assert mart.get("required_tables"), f"{rel}: manca mart.required_tables"
        rules = (mart.get("validate") or {}).get("table_rules") or {}
        assert rules, f"{rel}: manca mart.validate.table_rules"
        names = {t["name"] for t in tables}
        assert set(mart["required_tables"]) <= names
        assert set(rules) <= names
        for t in tables:
            if t.get("years"):
                assert set(t["years"]) == set(ds["years"]), f"{rel}: mart years != dataset.years"

        assert dataset.get("validation", {}).get("fail_on_error") is True

        support = dataset.get("support") or []
        clean_sql = (cfg.parent / dataset["clean"]["sql"]).read_text(encoding="utf-8")
        if "{support.istat_comuni.path}" in clean_sql:
            assert support, f"{rel}: clean usa ISTAT ma manca support istat_comuni"
            istat = next((s for s in support if s.get("name") == "istat_comuni"), None)
            assert istat, f"{rel}: manca support istat_comuni"
            assert istat.get("type") == "external"
            uri = istat.get("uri") or ""
            assert "istat_elenco_comuni" in uri
            assert "{year}" not in uri, f"{rel}: support ISTAT non deve usare {{year}} (usa snapshot fisso)"


@pytest.mark.contract
def test_declared_sql_files_exist(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        dataset = yaml.safe_load(cfg.read_text(encoding="utf-8"))
        cfg_dir = cfg.parent
        rel = str(cfg.relative_to(REPO_ROOT))
        clean_sql = (cfg_dir / dataset["clean"]["sql"]).resolve()
        assert clean_sql.is_file(), f"{rel}: manca clean SQL"
        for table in dataset["mart"]["tables"]:
            sql_path = (cfg_dir / table["sql"]).resolve()
            assert sql_path.is_file(), f"{rel}: manca mart SQL {table['sql']}"


@pytest.mark.contract
def test_clean_sql_uses_support_placeholder_not_hardcoded_istat(
    dataset_configs: list[Path],
) -> None:
    for cfg in dataset_configs:
        sql = (cfg.parent / yaml.safe_load(cfg.read_text(encoding="utf-8"))["clean"]["sql"]).read_text(
            encoding="utf-8"
        )
        rel = str(cfg.relative_to(REPO_ROOT))
        if "istat_elenco_comuni" in sql or "storage.googleapis.com" in sql:
            assert "{support.istat_comuni.path}" in sql, f"{rel}: ISTAT hardcoded senza support placeholder"


@pytest.mark.contract
def test_sql_files_do_not_hardcode_istat_gcs(dataset_configs: list[Path]) -> None:
    for cfg in dataset_configs:
        for sql_file in (cfg.parent / "sql").glob("*.sql"):
            text = sql_file.read_text(encoding="utf-8")
            assert not GCS_HARDCODED.search(text), f"{sql_file}: path ISTAT hardcoded"


@pytest.mark.contract
def test_gitignore_blocks_out_and_raw() -> None:
    gitignore = (REPO_ROOT / ".gitignore").read_text(encoding="utf-8")
    assert "out/" in gitignore or "out/**" in gitignore, ".gitignore deve ignorare out/"
    assert "datasets/raw/" in gitignore or "datasets/raw" in gitignore
    assert "_legacy/" in gitignore


@pytest.mark.contract
def test_no_unignored_run_outputs() -> None:
    """Nessun output di run tracciato da git (se il repo è git)."""
    if not (REPO_ROOT / ".git").exists():
        pytest.skip("repo non git: out/ è locale e gitignored")
    if not OUT_DIR.exists():
        return
    import subprocess

    offenders: list[str] = []
    for path in OUT_DIR.rglob("*"):
        if not path.is_file() or path.name == ".gitkeep":
            continue
        if path.suffix.lower() in BLOCKED_OUT_EXTENSIONS or "_runs" in path.parts:
            rel = path.relative_to(REPO_ROOT)
            ignored = subprocess.run(
                ["git", "check-ignore", "-q", str(rel)],
                cwd=REPO_ROOT,
                capture_output=True,
            ).returncode == 0
            if not ignored:
                offenders.append(str(rel).replace("\\", "/"))
    assert not offenders, f"Output di run non gitignored in out/: {offenders}"


@pytest.mark.contract
def test_legacy_is_isolated() -> None:
    legacy_datasets = list((REPO_ROOT / "_legacy" / "datasets").glob("*/dataset.yml"))
    active_datasets = _iter_dataset_configs()
    assert active_datasets, "datasets/ attivi mancanti"
    # I config legacy non devono stare in datasets/
    assert not any("_legacy" in str(p) for p in active_datasets)
