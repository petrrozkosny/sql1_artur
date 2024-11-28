

-- data_nova je nalevo
-- zeme z dim_oblasti, ktera je napravo

/*
Spojujeme vedle sebe (tj. provadime join) tabulek data_nova a dim_oblasti
Spojujeme pres sloupec data_nova.lokalita a dim_oblasti.stanice
data_nova si ukladame do alias dn, dim_oblasti do alias do
*/
-- vybirame vsechny sloupce z tabulky po slouceni, tj. jedna se o vsechny sloupce leve a prave tabulky
SELECT *
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice 

-- vybirame vsechny sluoupce leve tabulky, sloupec zeme prave tabulky
SELECT dn.*,do.zeme
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice 

-- vybirame sloupec datum, lokalita, srazky leve tabulky, sloupec zeme prave tabulky
SELECT dn.datum,dn.lokalita,dn.srazky, do.zeme
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.zeme 

-- vsechny udaje lokalit, ktere jsou na slovensku

SELECT * -- krok 4
FROM data_nova dn -- krok 1
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice -- krok 2
WHERE do.zeme = 'Slovensko' --krok 3

-- prumerne srazky dle zemi

SELECT do.zeme,AVG(dn.srazky) prumerne_srazky
FROM data_nova dn -- krok 1
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice -- krok 2
GROUP BY do.zeme


-- prumerne rocni srazky lokalit na slovensku
SELECT
	YEAR(datum) rok
	,AVG(dn.srazky) prumerne_srazky
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE
	do.zeme = 'Slovensko'
GROUP BY
	YEAR(datum)

-- maximalni srazky v jednotlivych lokalitach ceska v roce 2019 razeny sestupne dle srazky

SELECT dn.lokalita, MAX(dn.srazky) maximalni_srazky
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Cesko' AND YEAR(dn.datum) = 2019
GROUP BY dn.lokalita
ORDER BY maximalni_srazky DESC;

-- maximalni srazky v zemi Slovensko
SELECT MAX(dn.srazky) maximalni_srazky
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Slovensko'

-- zeme, jejichz lokality jsou v leve i prave tabulce
SELECT DISTINCT do.zeme
FROM data_nova dn
JOIN dim_oblasti do ON  dn.lokalita = do.stanice

-- ve kterych mesicich roku 2019 byla v lokalitach rakouska mimo wien namìøena maximalni_teplota > 20
-- serazeno vzestupne dle mesicu

SELECT DISTINCT MONTH(dn.datum) mesic
FROM data_nova dn 
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE YEAR(dn.datum) = 2019 AND do.zeme = 'Rakousko' AND dn.lokalita <> 'WIEN' AND dn.maximalni_teplota > 20
ORDER BY mesic;

-- maximalni datum rakouskych lokalit mimo wien
SELECT MAX(dn.datum)
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
WHERE do.zeme = 'Rakousko' AND dn.lokalita <> 'WIEN'


-- JOIN cviceni

SELECT dn.lokalita,dn.srazky,do.zeme
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice

SELECT dn.lokalita,dn.srazky,do.zeme
FROM data_nova dn
LEFT JOIN dim_oblasti do ON do.stanice = dn.lokalita
WHERE do.zeme = 'Cesko'

SELECT
dn.lokalita,SUM(dn.srazky),do.zeme, YEAR(dn.datum)
FROM data_nova dn
LEFT JOIN dim_oblasti do ON dn.lokalita = do.stanice
GROUP BY YEAR(datum),do.zeme,dn.lokalita
ORDER BY do.zeme,YEAR(datum)

-- spojit pod sebe hodnoty ze sloupce datum tabulky data_nova a tabulky data_stara
-- pøipojujeme tak, a odstraníme pøípadné duplicity

SELECT  lokalita FROM data_nova
UNION 
SELECT  lokalita FROM data_stara


-- data_nova a data_stara, vybirame sloupce lokalita,datum, srazky
-- pripadne duplicity zanechat

SELECT lokalita, datum, srazky
FROM data_nova
UNION ALL
SELECT lokalita, datum, srazky
FROM data_stara

-- data_nova a data_stara z lokality ruzyne

SELECT * FROM data_nova
WHERE lokalita = 'RUZYNE'
UNION
SELECT * FROM data_stara
WHERE lokalita = 'RUZYNE'

-- maximalni_teploty, datum, lokalita  z data_nova a data_stara, kde maximalni_teplota > 35
SELECT maximalni_teplota, datum, lokalita
FROM data_nova
WHERE maximalni_teplota > 35
UNION
SELECT maximalni_teplota, datum, lokalita
FROM data_stara
WHERE maximalni_teplota > 35

-- ktere lokality jsou v data_nova a nejsou v data_stara
SELECT lokalita FROM data_stara
EXCEPT
SELECT lokalita FROM data_nova

SELECT lokalita FROM data_stara
INTERSECT
SELECT lokalita FROM data_nova

SELECT lokalita,datum,srazky FROM data_nova
UNION ALL
SELECT lokalita, datum, srazky FROM data_stara

SELECT lokalita,datum,srazky FROM data_nova
WHERE lokalita = 'RUZYNE'
UNION ALL
SELECT lokalita, datum, srazky FROM data_stara
WHERE lokalita = 'RUZYNE'


-- datumy data_nova, ve kterych byla max maximalni_teplota

SELECT datum
FROM data_nova
-- subselect ve where
WHERE maximalni_teplota IN (SELECT MAX(maximalni_teplota) FROM data_nova)

-- rozdil mezi srazkami na danem radku a maximalnimi srazkami tabulky data_nova	

SELECT datum,srazky, srazky - (SELECT MAX(srazky) FROM data_nova) rozdil_srazek
FROM data_nova

SELECT * FROM 
(
SELECT * FROM data_nova
UNION ALL 
SELECT * FROM data_stara) dv
WHERE dv.maximalni_teplota > 35

-- prumerne rocni srazky v ruzyne za vsechny roky

SELECT YEAR(dv.datum) rok, ROUND(AVG(dv.srazky),2) prumerne_srazky
FROM
(
SELECT lokalita,datum,srazky
FROM data_nova 

UNION ALL

SELECT lokalita,datum,srazky FROM data_stara) dv
WHERE dv.lokalita = 'RUZYNE'
GROUP BY YEAR(dv.datum)
ORDER BY YEAR(dv.datum) ASC;

-- prumerne srazky dle zemi za celou historii
SELECT do.zeme, AVG(dv.srazky) prumerne_srazky
FROM
	(
	SELECT datum,srazky,lokalita
	FROM data_nova
	UNION ALL
	SELECT datum,srazky,lokalita
	FROM data_stara
	) dv
LEFT JOIN dim_oblasti do ON dv.lokalita = do.stanice
GROUP BY do.zeme
ORDER BY do.zeme

-- datum, lokalita,srazky pro slovensko

SELECT datum,lokalita,srazky
FROM
(
SELECT datum,lokalita,srazky
FROM data_nova
UNION ALL
SELECT datum,lokalita,srazky
FROM data_stara) dv
LEFT JOIN dim_oblasti do ON dv.lokalita = do.stanice
WHERE do.zeme = 'Slovensko'

-- datum maximalnich srazek z data_nova
SELECT datum
FROM data_nova
WHERE srazky IN (SELECT MAX(srazky) FROM data_nova)

-- lokality, ve kterych je pocet null zaznamu ve sloupci srazky vetsi 10

SELECT lokalita
FROM
(
SELECT srazky,lokalita
FROM data_nova
UNION ALL
SELECT srazky,lokalita
FROM data_stara
) dv
WHERE srazky IS NULL
GROUP BY lokalita
HAVING COUNT(*) > 10


SELECT *
FROM
(
SELECT *
FROM data_nova
UNION ALL
SELECT *
FROM data_stara
) dv;

SELECT dv.lokalita, YEAR(dv.datum) rok, AVG(dv.srazky) prumerne_srazky
FROM
(
SELECT datum,lokalita,srazky
FROM data_nova
UNION ALL
SELECT datum,lokalita,srazky
FROM data_stara
) dv
GROUP BY
	YEAR(datum),lokalita
ORDER BY lokalita, rok;


SELECT lokalita,AVG(srazky) prumerne_srazky
FROM
(
SELECT lokalita,datum,srazky FROM data_nova
UNION ALL
SELECT lokalita,datum,srazky FROM data_stara) dv
LEFT JOIN dim_oblasti do ON do.stanice = dv.lokalita
WHERE do.zeme = 'Cesko'
GROUP BY lokalita
ORDER BY prumerne_srazky DESC;







  
