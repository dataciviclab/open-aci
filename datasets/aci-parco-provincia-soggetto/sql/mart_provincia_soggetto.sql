-- mart_provincia_soggetto.sql: autovetture per provincia e natura del
-- proprietario, con la quota aziendale che spiega il gonfiaggio del parco.
--
-- `quota_giuridica_pct` è la variabile da guardare prima di usare qualunque
-- indicatore per abitante: sopra il 25-30% il rapporto auto/popolazione di quel
-- territorio è dominato dalle flotte, non dalle famiglie.

SELECT
    anno,
    regione,
    provincia,
    auto_persona_fisica,
    auto_persona_giuridica,
    auto_non_definito,
    auto_totali,
    ROUND(100.0 * auto_persona_giuridica / NULLIF(auto_totali, 0), 1) AS quota_giuridica_pct,
    ROUND(100.0 * auto_persona_fisica / NULLIF(auto_totali, 0), 1) AS quota_fisica_pct
FROM clean_input
WHERE auto_totali > 0
ORDER BY anno, quota_giuridica_pct DESC
