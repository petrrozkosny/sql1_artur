
-- prvnich 5 radku tabulky
SELECT TOP 5 *
FROM data_nova

-- prvnich 5 nejvyssich hodnot ze sloupce srazky
SELECT TOP 5 srazky
FROM data_nova
ORDER BY srazky DESC;

-- prvnich 10 nejnizsich NOT NULL hodnot ze sloupce minimalni_teplota

SELECT TOP 10 minimalni_teplota
FROM data_nova
WHERE minimalni_teplota IS NOT NULL
ORDER BY minimalni_teplota ASC;

-- Lokalitu s nejvyssi maximalni_teplotou
SELECT TOP 1 lokalita, maximalni_teplota
FROM data_nova
ORDER BY maximalni_teplota DESC;

-- TOP 10 procent nejvyssich srazek

SELECT TOP 10 PERCENT srazky
FROM data_nova
ORDER BY srazky DESC;


--1
SELECT TOP 10 srazky
FROM data_nova;

--2
SELECT TOP 10 srazky
FROM data_nova
ORDER BY srazky DESC;
--3
SELECT TOP 3 MONTH(datum) mesic, SUM(srazky) mesicni_srazky
FROM data_nova
WHERE lokalita = 'RUZYNE' AND YEAR(datum) = 2019
GROUP BY MONTH(datum)
ORDER BY mesicni_srazky DESC;

--4
SELECT TOP 10 *
FROM data_nova
WHERE lokalita = 'RUZYNE'
ORDER BY srazky DESC;
