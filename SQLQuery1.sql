


-- jako posledni pocitame prumerne srazky po pripojeni, slouceni, zafiltrovani
SELECT AVG(dv.srazky) prumerne_srazky
-- tento prikaz vybira vsechny sloupce z tabulky vracene poddotazem
FROM 
(
-- vybirame vsechny hodnoty z tabulky data_nova
SELECT * FROM data_nova
UNION ALL
-- vybirame vsechny hodnoty z tabulky data_stara
SELECT * FROM data_stara) dv
-- tabulku, ktera je vysledkem poddotazu slucujeme zleva s tabulkou dim_oblasti
LEFT JOIN dim_oblasti do ON do.stanice = dv.lokalita 
-- tabulku, ktere je vysledkem poddotazu a slouceni filtrujeme na zeme = Cesko
WHERE do.zeme = 'Cesko'


--1
SELECT YEAR(datum) rok, AVG(srazky) prumerne_srazky
FROM
(
SELECT * FROM data_nova
UNION ALL
SELECT * FROM data_stara) dv
LEFT JOIN dim_oblasti do ON do.stanice = dv.lokalita 
WHERE do.zeme = 'Cesko'
GROUP BY YEAR(datum)

--2
SELECT DISTINCT YEAR(datum) rok_max_srazek
FROM
data_nova
WHERE lokalita = 'RUZYNE' AND srazky = (SELECT MAX(srazky) FROM data_nova WHERE lokalita = 'RUZYNE')

--3
SELECT TOP 3 YEAR(datum) rok
FROM
(
SELECT * FROM data_nova
UNION ALL
SELECT * FROM data_stara) dv
WHERE dv.lokalita = 'RUZYNE'
GROUP BY YEAR(datum)
ORDER BY SUM(srazky) ASC;


-- vytvoøit CTE tabulku data ruzyne a z ni potom vybrat vse

WITH data_ruzyne AS (
SELECT *
FROM data_nova)
SELECT * FROM data_ruzyne;

-- vytvorit CTE tabulku se vsemi hodnotami pro RUZYNE, tj. data_nova i data_stara
-- tuto CTE tabulku nasledne filtrovat na hodnoty srazky > 100, vypsat vsechny sloupce

WITH vsechno_ruzyne AS (
SELECT * FROM data_nova
WHERE lokalita = 'RUZYNE'
UNION ALL
SELECT * FROM data_stara
WHERE lokalita = 'RUZYNE')
SELECT * FROM vsechno_ruzyne
WHERE srazky > 100;

-- cte tabulku z data_nova filtrovanou na rok 2019, tuto cte budeme nasledne groupovat 
-- dle lokality, pocitat prumerne srazky

WITH data_2019 AS (
	SELECT * 
	FROM data_nova
	WHERE YEAR(datum) = 2019)
SELECT lokalita, AVG(srazky) prumerne_srazky
FROM data_2019
GROUP BY lokalita;

-- CTE tabulku s rocnimi hodnotami suma srazek v lokalitach z Cesko
-- z teto CTE budeme naslene filtrovat hodnoty vetsi 5000

WITH rocni_data_cesko AS (
SELECT YEAR(datum) rok, SUM(srazky) suma_srazek
FROM
(
SELECT *
FROM data_nova
UNION ALL
SELECT *
FROM data_stara) dv
LEFT JOIN dim_oblasti do ON dv.lokalita = do.stanice 
WHERE do.zeme = 'Cesko'
GROUP BY YEAR(datum)
)
SELECT *
FROM rocni_data_cesko
WHERE suma_srazek > 5000;

-- CTE tabulku z data_nova jen pro Rakousko, 
-- z teto tabulky nasledne filtrovat lokalita SALZBURG a srazky vetsi nez 10

WITH data_rakousko as (
SELECT lokalita,srazky
FROM data_nova
LEFT JOIN dim_oblasti do ON lokalita = do.stanice
WHERE do.zeme = 'Rakousko')
SELECT * 
FROM data_rakousko
WHERE lokalita = 'SALZBURG' AND srazky > 10

--1
WITH tbl_prumerne_srazky AS (
SELECT lokalita, AVG(srazky) prumerne_srazky
FROM data_nova
GROUP BY lokalita)
SELECT lokalita
FROM tbl_prumerne_srazky
WHERE prumerne_srazky > 2;

--2 
WITH rocni_data AS(
SELECT
YEAR(datum) rok, ROUND(SUM(srazky),1) rocni_srazky
FROM data_nova
GROUP BY YEAR(datum))

SELECT rd1.*, rd2.rocni_srazky srazky_predchozi_rok
FROM rocni_data rd1
LEFT JOIN rocni_data rd2 ON rd1.rok = rd2.rok+1
ORDER BY rd1.rok ASC;

-- data_nova_lektor

CREATE VIEW data_nova_lektor AS
SELECT * FROM data_nova

SELECT * FROM data_nova_lektor

DROP VIEW data_nova_lektor;