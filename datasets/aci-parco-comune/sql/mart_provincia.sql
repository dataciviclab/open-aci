-- mart_provincia.sql: aggregato provinciale, per la lettura territoriale larga.
-- Somma dei comuni (non dei dati provinciali ACI, che sono un'altra tabella):
-- così il totale provinciale è confrontabile con i mart comunali.

SELECT
    anno,
    regione,
    provincia,
    SUM(CASE WHEN categoria_veicolo = 'autovetture' THEN veicoli ELSE 0 END) AS autovetture,
    SUM(veicoli) AS veicoli_totali,
    SUM(CASE WHEN codice_istat IS NOT NULL THEN veicoli ELSE 0 END) AS veicoli_con_codice_istat,
    count(DISTINCT comune) AS comuni,
    count(DISTINCT CASE WHEN codice_istat IS NOT NULL THEN comune END) AS comuni_agganciati
FROM clean_input
GROUP BY anno, regione, provincia
ORDER BY anno, regione, provincia
