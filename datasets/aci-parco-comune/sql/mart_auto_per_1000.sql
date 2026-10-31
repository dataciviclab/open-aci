-- mart_auto_per_1000.sql: autovetture per 1000 abitanti, per comune.
--
-- Il denominatore viene da ISTAT (popolazione residente nello snapshot comuni),
-- non dal dato ACI. Il join è già risolto nel clean (`join_qualita`): qui si
-- pubblicano solo i comuni agganciati a un codice ISTAT, perché senza
-- denominatore il rapporto non esiste.
--
-- ⚠️ CAVEAT: numeratore = veicoli registrati al domicilio dell'intestatario.
-- Comuni con sedi di noleggio/leasing o grandi flotte aziendali risultano
-- gonfiati rispetto alla popolazione (il caso estremo è in Valle d'Aosta).
-- Il rapporto va letto come intensità di motorizzazione, non come traffico.

SELECT
    anno,
    regione,
    provincia,
    comune,
    codice_istat,
    SUM(CASE WHEN categoria_veicolo = 'autovetture' THEN veicoli ELSE 0 END) AS autovetture,
    SUM(veicoli) AS veicoli_totali,
    MAX(popolazione_residente) AS popolazione_residente,
    ROUND(1000.0 * SUM(CASE WHEN categoria_veicolo = 'autovetture' THEN veicoli ELSE 0 END)
          / NULLIF(MAX(popolazione_residente), 0), 1) AS auto_per_1000
FROM clean_input
WHERE codice_istat IS NOT NULL
  AND join_qualita IN ('nome+provincia', 'nome_univoco')
GROUP BY anno, regione, provincia, comune, codice_istat
ORDER BY anno, regione, provincia, comune
