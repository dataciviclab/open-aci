-- clean.sql: ACI Autoritratto, foglio "45 Comune categoria" —
-- parco veicolare per comune e categoria (stock al 31/12).
--
-- Accortezze obbligate dalla fonte:
--  1. Area/Regione/Provincia sono valorizzate solo sulla prima riga del gruppo
--     (celle unite): vanno riportate in avanti, altrimenti si perdono tutti i
--     comuni tranne il primo di ogni provincia.
--  2. Nel foglio convivono righe di riepilogo ("Totale", "NON DEFINITO") tra i
--     comuni: vanno escluse o i totali raddoppiano.
--  3. ACI non pubblica codici ISTAT: il join è per nome + provincia, con
--     fallback su nome univoco. `join_qualita` dice come è stato risolto, e i
--     non risolti restano nel dataset con codice_istat NULL (non si buttano).
--
-- Il totale di riga non viene letto: le categorie sono 10 e si sommano nei mart.

WITH src AS (
    SELECT
        row_number() OVER () AS rn,
        CAST({year} AS INTEGER) AS anno,
        "Area Geografica" AS area,
        "Regione" AS regione_raw,
        "Provincia" AS provincia_raw,
        "Comune" AS comune_raw,
        "AUTOBUS" AS c_autobus,
        "AUTOCARRI TRASPORTO MERCI" AS c_autocarri,
        "AUTOVEICOLI SPECIALI / SPECIFICI" AS c_autoveicoli_speciali,
        "AUTOVETTURE" AS c_autovetture,
        "MOTOCARRI E QUADRICICLI TRASPORTO MERCI" AS c_motocarri,
        "MOTOCICLI" AS c_motocicli,
        "MOTOVEICOLI E QUADRICICLI SPECIALI / SPECIFICI" AS c_motoveicoli_speciali,
        "RIMORCHI E SEMIRIMORCHI SPECIALI / SPECIFICI" AS c_rimorchi_speciali,
        "RIMORCHI E SEMIRIMORCHI TRASPORTO MERCI" AS c_rimorchi_merci,
        "TRATTORI STRADALI O MOTRICI" AS c_trattori
    FROM raw_input
),
filled AS (
    SELECT
        anno, rn,
        upper(trim(last_value(regione_raw IGNORE NULLS) OVER (ORDER BY rn))) AS regione,
        upper(trim(last_value(provincia_raw IGNORE NULLS) OVER (ORDER BY rn))) AS provincia,
        upper(trim(CAST(comune_raw AS VARCHAR))) AS comune,
        c_autobus, c_autocarri, c_autoveicoli_speciali, c_autovetture, c_motocarri,
        c_motocicli, c_motoveicoli_speciali, c_rimorchi_speciali, c_rimorchi_merci, c_trattori
    FROM src
),
unp AS (
    UNPIVOT (
        SELECT
            anno, regione, provincia, comune,
            c_autobus, c_autocarri, c_autoveicoli_speciali, c_autovetture, c_motocarri,
            c_motocicli, c_motoveicoli_speciali, c_rimorchi_speciali, c_rimorchi_merci, c_trattori
        FROM filled
    )
    ON c_autobus, c_autocarri, c_autoveicoli_speciali, c_autovetture, c_motocarri,
       c_motocicli, c_motoveicoli_speciali, c_rimorchi_speciali, c_rimorchi_merci, c_trattori
    INTO NAME categoria_col VALUE veicoli
),
cat AS (
    SELECT
        anno, regione, provincia, comune,
        CASE categoria_col
            WHEN 'c_autobus' THEN 'autobus'
            WHEN 'c_autocarri' THEN 'autocarri_merci'
            WHEN 'c_autoveicoli_speciali' THEN 'autoveicoli_speciali'
            WHEN 'c_autovetture' THEN 'autovetture'
            WHEN 'c_motocarri' THEN 'motocarri'
            WHEN 'c_motocicli' THEN 'motocicli'
            WHEN 'c_motoveicoli_speciali' THEN 'motoveicoli_speciali'
            WHEN 'c_rimorchi_speciali' THEN 'rimorchi_speciali'
            WHEN 'c_rimorchi_merci' THEN 'rimorchi_merci'
            ELSE 'trattori_stradali'
        END AS categoria_veicolo,
        TRY_CAST(veicoli AS DOUBLE) AS veicoli_num
    FROM unp
    WHERE regione IS NOT NULL AND comune IS NOT NULL
      AND upper(trim(comune)) NOT IN ('TOTALE', 'NON DEFINITO')
),
istat AS (
    SELECT
        codice_istat,
        regione,
        provincia,
        lower(trim(denominazione)) AS nome_k,
        popolazione_residente
    FROM read_parquet('{support.istat_comuni.path}')
),
univoci AS (
    SELECT nome_k, min(codice_istat) AS codice_istat
    FROM istat
    GROUP BY nome_k
    HAVING count(*) = 1
),
match AS (
    SELECT
        c.*,
        COALESCE(i.codice_istat, u.codice_istat) AS codice_istat,
        CASE WHEN i.codice_istat IS NOT NULL THEN 'nome+provincia'
             WHEN u.codice_istat IS NOT NULL THEN 'nome_univoco'
             ELSE 'non_risolto' END AS join_qualita
    FROM cat c
    LEFT JOIN istat i
        ON lower(trim(i.regione)) = lower(trim(c.regione))
       AND lower(trim(i.provincia)) = lower(trim(c.provincia))
       AND i.nome_k = lower(c.comune)
    LEFT JOIN univoci u
        ON u.nome_k = lower(c.comune)
       AND i.codice_istat IS NULL
),
enriched AS (
    SELECT
        m.*,
        i2.popolazione_residente
    FROM match m
    LEFT JOIN istat i2 ON i2.codice_istat = m.codice_istat
)
SELECT
    anno,
    regione,
    provincia,
    comune,
    codice_istat,
    categoria_veicolo,
    CAST(veicoli_num AS BIGINT) AS veicoli,
    popolazione_residente,
    join_qualita
FROM enriched
WHERE veicoli_num IS NOT NULL
