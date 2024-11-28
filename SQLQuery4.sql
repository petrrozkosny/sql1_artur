
--1
SELECT dn.lokalita, AVG(dn.srazky) prumerne_srazky
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Cesko' AND YEAR(datum) = 2019
GROUP BY dn.lokalita

--2
SELECT TOP 3 dn.srazky, dn.datum, dn.lokalita
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Cesko'
ORDER BY srazky DESC;

-- 3
SELECT TOP 3 maximalni_teplota
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Slovensko' AND YEAR(datum) = 2019 AND maximalni_teplota IS NOT NULL
ORDER BY maximalni_teplota

