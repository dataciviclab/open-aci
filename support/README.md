# Support datasets

In open-ACI non ci sono support locali.

Il join territoriale (codice ISTAT, regione, popolazione) usa un **support external** GCS
dichiarato in ogni `dataset.yml`:

```yaml
support:
  - name: "istat_comuni"
    type: "external"
    uri: "https://storage.googleapis.com/dataciviclab-clean/istat_elenco_comuni/2026/istat_elenco_comuni_2026_clean.parquet"
    years: [2026]
```

URI **senza** `{year}`: toolkit altrimenti risolve con l'anno del run candidate (es. 2025) e il path ISTAT non esiste.


Nei SQL si referenzia solo con `{support.istat_comuni.path}` — mai URL hardcoded.
