# Contribuire a open-ACI

Repo dataset del Lab (archetipo Dataset, ADR-001).

## Comandi

```bash
make check    # preflight dataset.yml
make run      # pipeline toolkit
make clean    # pulisci out/
make test     # pytest
```

## Standard

- Pipeline: `infra/lab-ops/standards/pipeline.md`
- Repo: `infra/lab-ops/standards/repo.md`
- Dashboard: `infra/lab-ops/standards/dashboard.md`
- Test: `infra/lab-ops/standards/tests.md`

## Regole del repo

1. **Raw via `http_file`** da lod.aci.it — niente `local_file` + scarichi manuali
2. **Niente path hardcoded** nei SQL: join ISTAT con `{support.istat_comuni.path}`
3. **Niente output in git**: `out/` e `datasets/raw/` sono gitignored
4. **1 clean = 1 responsabilità**: pulizia/typing; le aggregazioni stanno nel mart
5. **Marti analitici**: niente re-aggio del clean
6. **`validation.fail_on_error: true`** e `primary_key` dichiarati

## Aggiungere un dataset

1. Crea `datasets/<slug>/dataset.yml` (copia un dataset esistente)
2. Scrivi `sql/clean.sql` e `sql/mart_*.sql`
3. `make check && make run`
4. Aggiorna `registry/` se serve
5. Apri una PR col template del repo

## Fonti ACI in roadmap (non in v0)

Auto-Trend (mensile provinciale), Autoritratto (parco stock / usato), incidenti.
Vedi note di scouting: non farlo finché il LOD non è stabile.
