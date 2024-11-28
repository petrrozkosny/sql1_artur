

-- z data nova nadprumerne srazkove datumy
-- tj. dny, ve kterych srazky byly vyssi nez prumerne srazky data nova

/*
1. Prùmìr ze sloupce srazky z tabulky data_nova
2. Tabulku data_nova filtrovat na srazky > prumerne srazky
3. Vypsat hodnoty ze sloupce datum
*/

SELECT datum
FROM data_nova
WHERE srazky >
-- ============ PRUMERNE SRAZKY ==============
(
SELECT
AVG(srazky)
FROM data_nova
);
-- ============ PRUMERNE SRAZKY ==============

-- TOP 3 roky dle suma srazek v lokalite RUZYNE serazeno SESTUPNE


/*
1. Spojim pod sebe data_nova a data stara
2. Zafiltruji tabulku po spojeni na RUZYNE
3. Agreguji tabulku po zafiltrovani dle ROK
4. Radim a vybiram TOP 3 hodnoty
*/
SELECT TOP 3 YEAR(dv.datum) rok,SUM(dv.srazky) srazky
FROM 
-- ==== poddotaz, jehoz vysledkem je tabulka, kterou ctu, filtruji a agreguji =====
(
SELECT * FROM data_nova
WHERE lokalita = 'RUZYNE'
UNION ALL
SELECT * FROM data_stara
WHERE lokalita = 'RUZYNE'
) dv
-- ===== konec poddotazu
GROUP BY YEAR(datum)
ORDER BY SUM(srazky) DESC;


-- sloupec, lokalita,datum,srazky, prumerne srazky (tj. prumerne hodnota ze sloupce srazky)

/*
Prumerna hodnota ze sloupce srazky tabulky data_nova
Dosazeni spocitaneho sloupce do tabulky data_nova v rámci "hlavního" selectu
*/

SELECT lokalita,datum,srazky, 
-- Prumerna hondnota ze sloupce srazky
(SELECT AVG(srazky)
FROM data_nova ) prumerne_srazky
FROM data_nova

-- datumy maximalnich srazek v mosnov z data_nova

/*


1. maximalni srazky z mosnov
2. hlavni select s filtrem na mosnov
3. select na datumy
*/
SELECT datum
FROM data_nova
WHERE srazky = 
(
SELECT MAX(srazky) FROM data_nova WHERE lokalita = 'MOSNOV')
AND lokalita = 'MOSNOV'


-- data z data_nova pro lokalitu /lokality, ktera mela prumerne srazky > 2

/*
Lokality s prumernymi srazkami nad 2 z data_nova
*/
SELECT *
FROM data_nova
WHERE lokalita IN
(
SELECT lokalita
FROM data_nova
GROUP BY lokalita
HAVING AVG(srazky) >2)


-- data z data_nova za posledni den, tj. maximalni datum z data_nova

-- maximalni datum z data_nova
SELECT *
FROM data_nova
WHERE datum = 
(
SELECT MAX(datum)
FROM data_nova)

-- data 3 nejsrazkovesi datumy v RUZYNE z data_nova

/*
TOP 3 hodnoty z data_nova pro RUZYNE dle srazky razeno sestupne
*/


SELECT TOP 3 *
FROM data_nova
WHERE lokalita = 'RUZYNE'
ORDER BY srazky DESC

-- prumerne srazky v lokalitach, ve kterych jsou maximalni srazky > 100

SELECT AVG(srazky)
FROM data_nova
WHERE lokalita IN 
(
-- lokality, ve kterych byly srazky > 100
SELECT lokalita
FROM data_nova
WHERE srazky > 100
)

-- Tøi sloupeèky, jeden prùmìrné srážky v RUZYNE, druhý prùmìrné srážky v MOSNOV, 
-- tøetí prùmìrné srážky vše
SELECT 
(SELECT AVG(srazky) FROM data_nova WHERE lokalita = 'RUZYNE') prum_srazky_ruzyne,
(SELECT AVG(srazky) FROM data_nova WHERE lokalita = 'MOSNOV') prum_srazky_mosnov,
AVG(srazky) prum_srazky_vse
FROM data_nova;

-- Dva sloupeèky. Prùmìrné srážky po letech, prùmìrné srážky ruzyne po letech

WITH tbl1 AS(
SELECT  YEAR(datum) rok, AVG(srazky) prumerne_srazky
FROM data_nova
GROUP BY YEAR(datum)),

tbl2 AS(
SELECT  YEAR(datum) rok, AVG(srazky) prumerne_srazky
FROM data_nova
WHERE lokalita = 'RUZYNE'
GROUP BY YEAR(datum))
SELECT tbl1.*,tbl2.prumerne_srazky prumerne_srazky_ruzyne
FROM tbl1
LEFT JOIN tbl2 ON tbl1.rok = tbl2.rok;


-- lokalitu, jeji prumerne srazky, jeji prumerne srazky v roce 2019
-- z data_nova

WITH tbl1 AS(
SELECT lokalita, AVG(srazky) prumerne_srazky
FROM data_nova
GROUP BY lokalita
),
tbl2 AS(
SELECT lokalita, AVG(srazky) prumerne_srazky_2019
FROM data_nova
WHERE YEAR(datum) = 2019
GROUP BY lokalita
)
SELECT tbl1.*, tbl2.prumerne_srazky_2019
FROM tbl1
LEFT JOIN tbl2 ON tbl1.lokalita = tbl2.lokalita;

-- srazky lokality turany za datumy, ve kterych byla
-- v lokalite turany namìøena nejvyšší maximalni_teplota. Pocitame jen z data_nova

SELECT srazky
FROM data_nova
WHERE 
	lokalita = 'TURANY'
	AND maximalni_teplota = (SELECT MAX(maximalni_teplota) FROM data_nova WHERE lokalita = 'TURANY')

-- roky a jejich prumerne srazky pro lokalitu turany, ve kterych (letech) 
-- turany nemela null hodnoty ve srazky. Pocitame z data_stara


WITH tbl1 AS(
-- roky, ve kterych je pocet nullovych hodnot 
SELECT YEAR(datum) rok
FROM data_stara
WHERE lokalita = 'WIEN' AND srazky  IS NULL
GROUP BY YEAR(datum))

SELECT YEAR(datum), AVG(srazky)
FROM data_stara
WHERE YEAR(datum) NOT IN (SELECT * FROM tbl1)
GROUP BY YEAR(datum)
ORDER BY YEAR(datum)



-- prumerne srazky v jednotlivych zemich ze vsech dat
SELECT do.zeme,AVG(dv.srazky) prumerne_srazky
FROM
(
SELECT lokalita, srazky
FROM data_nova
UNION ALL
SELECT lokalita, srazky
FROM data_stara) AS dv
LEFT JOIN dim_oblasti do ON dv.lokalita = do.stanice
GROUP BY do.zeme




-- prumerne srazky lokalit v cesko. pocitame s data_nova i data_stara
-- ve kterem roce byl v lokalite ruzyne nejvyssi mezirocni narust srazek

SELECT AVG(srazky)
FROM(
SELECT lokalita, srazky
FROM data_nova
UNION ALL
SELECT lokalita, srazky
FROM data_stara) AS dv
LEFT JOIN dim_oblasti do ON dv.lokalita = do.stanice
WHERE do.zeme = 'Cesko';


WITH tbl_data AS (
SELECT YEAR(datum) rok, SUM(srazky) rocni_srazky
FROM 
(
	SELECT lokalita, srazky,datum
	FROM data_nova
	UNION ALL
	SELECT lokalita, srazky,datum
	FROM data_stara) AS dv
WHERE lokalita = 'RUZYNE'
GROUP BY YEAR(datum)
),
	tbl_data_predchozi AS (
SELECT tb1.*, tb2.rocni_srazky rocni_srazky_predchozi
FROM tbl_data tb1
LEFT JOIN tbl_data tb2 ON tb1.rok = tb2.rok + 1)

SELECT TOP 1 rok, rocni_srazky - rocni_srazky_predchozi AS mezirocni_rozdil
FROM tbl_data_predchozi
ORDER BY mezirocni_rozdil DESC;


/*
Pokud srazky jsou NULL tak nevyplneno
srazky jsou 0 tak neprselo
jinak prselo
*/


SELECT  typ_srazek, COUNT(*) pocet_zaznamu
FROM
(
SELECT 
	CASE
		WHEN srazky IS NULL THEN 'nevypleno'
		WHEN srazky = 0 then 'neprselo'
		ELSE 'prselo'
	END typ_srazek
FROM
	data_nova
) dv
GROUP BY typ_srazek

