-- mart_auto_per_1000_famiglie.sql: l'indicatore corretto.
--
-- Due colonne affiancate:
--   * totali_per_1000   — veicoli registrati / popolazione (quello "grezzo")
--   * famiglie_per_1000 — solo autovetture di persone fisiche / popolazione
-- La differenza tra le due è la distorsione da flotte aziendali.
--
-- Denominatore: popolazione residente ISTAT sommata per provincia.
-- Il nome provincia ACI non coincide sempre con ISTAT (Monza, Bolzano, Forlì,
-- Reggio, Verbano, Barletta, Aosta): mappatura esplicita qui sotto.
-- La Sardegna è l'unico caso non risolvibile per nome: l'ACI usa ancora il
-- "SUD SARDEGNA" pre-riforma, ISTAT 2026 ha 5 province nuove. Quelle righe
-- restano con popolazione NULL e niente per-1000, invece di un numero sbagliato.

WITH aci AS (
    SELECT * FROM clean_input
),
mappa AS (
    SELECT * FROM (VALUES
        ('AOSTA',                 'VALLE D AOSTA/VALLEE D AOSTE'),
        ('BARLETTA TRANI',        'BARLETTA-ANDRIA-TRANI'),
        ('BOLZANO',               'BOLZANO/BOZEN'),
        ('FORLI CESENA',          'FORLI-CESENA'),
        ('MASSA CARRARA',         'MASSA-CARRARA'),
        ('MONZA BRIANZA',         'MONZA E DELLA BRIANZA'),
        ('REGGIO EMILIA',         'REGGIO NELL EMILIA'),
        ('VERBANO CUSIO OSSOLA',  'VERBANO-CUSIO-OSSOLA')
    ) AS t(aci_nome, istat_nome)
),
pop AS (
    SELECT
        upper(replace(replace(replace(trim(provincia), '-', ' '), '''', ''), 'À', 'A')) AS prov_k,
        SUM(popolazione_residente) AS popolazione
    FROM read_parquet('{support.istat_comuni.path}')
    GROUP BY 1
),
aci_key AS (
    SELECT
        a.*,
        upper(replace(replace(replace(trim(a.provincia), '-', ' '), '''', ''), 'À', 'A')) AS prov_k,
        m.istat_nome
    FROM aci a
    LEFT JOIN mappa m
        ON upper(trim(a.provincia)) = upper(replace(m.aci_nome, '''', ''))
)
SELECT
    a.anno,
    a.regione,
    a.provincia,
    a.auto_persona_fisica AS auto_famiglie,
    a.auto_totali,
    -- Sardegna: ACI usa ancora le province pre-riforma (SUD SARDEGNA in testa),
    -- ISTAT 2026 ne ha cinque nuove. Denominatore non confrontabile: meglio NULL
    -- che un rapporto sbagliato.
    CASE WHEN a.regione = 'SARDEGNA' THEN NULL ELSE p.popolazione END AS popolazione_residente,
    CASE WHEN a.regione = 'SARDEGNA' THEN NULL
         ELSE ROUND(1000.0 * a.auto_persona_fisica / NULLIF(p.popolazione, 0), 1) END AS famiglie_per_1000,
    CASE WHEN a.regione = 'SARDEGNA' THEN NULL
         ELSE ROUND(1000.0 * a.auto_totali / NULLIF(p.popolazione, 0), 1) END AS totali_per_1000,
    CASE WHEN a.regione = 'SARDEGNA' THEN NULL
         ELSE ROUND(1000.0 * (a.auto_totali - a.auto_persona_fisica) / NULLIF(p.popolazione, 0), 1) END AS aziendali_per_1000
FROM aci_key a
LEFT JOIN pop p
    ON p.prov_k = COALESCE(
        upper(replace(replace(replace(trim(a.istat_nome), '-', ' '), '''', ''), 'À', 'A')),
        a.prov_k
    )
ORDER BY a.anno, a.regione, a.provincia
