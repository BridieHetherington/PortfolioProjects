SELECT *
FROM worldlifexpectancy;


-- LOOK FOR AND REMOVE ANY DUPLICATE DATA --

SELECT country, year,CONCAT(country, year), COUNT(CONCAT(country, year))
FROM worldlifexpectancy
GROUP BY country, year,CONCAT(country, year)
HAVING COUNT(CONCAT(country, year)) >1
;



SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(country, year),
    ROW_NUMBER() OVER (PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS Row_num
	FROM worldlifexpectancy) AS Row_table
WHERE Row_num > 1;



DELETE FROM worldlifexpectancy
WHERE Row_ID IN (
		SELECT Row_ID
FROM(
	SELECT Row_ID, 
	CONCAT(country, year),
    ROW_NUMBER() OVER (PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS Row_num
	FROM worldlifexpectancy) AS Row_table
WHERE Row_num > 1);


-- LOOK FOR AND ATTEMPT TO POPULATE ANY UNPOPULATED FIELDS--

SELECT *
FROM worldlifexpectancy
WHERE status = '';


SELECT DISTINCT(country)
FROM worldlifexpectancy
WHERE status = 'Developing';

UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developing'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developing';


UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
	ON t1.country = t2.country
SET t1.status = 'Developed'
WHERE t1.status = ''
AND t2.status <> ''
AND t2.status = 'Developed';



SELECT *
FROM worldlifexpectancy
WHERE Lifeexpectancy = '';


SELECT  t1.country, t1.year, t1.Lifeexpectancy,
		t2.country, t2.year, t2.Lifeexpectancy,
        t3.country, t3.year, t3.Lifeexpectancy,
        ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1)
FROM worldlifexpectancy t1
JOIN worldlifexpectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year -1
JOIN worldlifexpectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year +1
WHERE t1.Lifeexpectancy = ''
;


UPDATE worldlifexpectancy t1
JOIN worldlifexpectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year -1
JOIN worldlifexpectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year +1
SET t1.Lifeexpectancy = ROUND((t2.Lifeexpectancy + t3.Lifeexpectancy)/2, 1)
WHERE t1.Lifeexpectancy = '';



-- ### EXPLORATORY DATA ANALYSIS ### --

 
SELECT *
FROM worldlifexpectancy
;


SELECT country, 
MIN(Lifeexpectancy),
MAX(Lifeexpectancy),
ROUND(MAX(Lifeexpectancy)-MIN(Lifeexpectancy), 1) AS Life_increase_15_years
FROM worldlifexpectancy
GROUP BY country
HAVING MIN(Lifeexpectancy) <> 0 AND MAX(Lifeexpectancy) <>0
ORDER BY Life_increase_15_years DESC
;


SELECT Year, ROUND(AVG(Lifeexpectancy), 1)
FROM worldlifexpectancy
WHERE Lifeexpectancy <> 0 
GROUP BY Year
ORDER BY Year;


SELECT country, ROUND(AVG(Lifeexpectancy) , 1)AS life_ex, ROUND(AVG(GDP),1) AS avg_gdp
FROM worldlifexpectancy
GROUP BY country
HAVING life_ex > 0 
AND avg_gdp > 0
ORDER BY avg_gdp ASC
;

SELECT 
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS high_gpd_count,
    AVG(CASE WHEN GDP >= 1500 THEN Lifeexpectancy ELSE NULL END) AS high_gdp_life_expectancy,
    SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS LOW_gpd_count,
    AVG(CASE WHEN GDP <= 1500 THEN Lifeexpectancy ELSE NULL END) AS low_gdp_life_expectancy
FROM worldlifexpectancy
ORDER BY gdp
;


SELECT status, ROUND(AVG(Lifeexpectancy), 1)
FROM worldlifexpectancy
GROUP BY status
;


SELECT status, COUNT(DISTINCT country), ROUND(AVG(Lifeexpectancy), 1)
FROM worldlifexpectancy
GROUP BY status
;


SELECT country, ROUND(AVG(Lifeexpectancy) , 1)AS life_ex, ROUND(AVG(BMI),1) AS avg_bmi
FROM worldlifexpectancy
GROUP BY country
HAVING life_ex > 0 
AND avg_bmi > 0
ORDER BY avg_bmi DESC
;

SELECT  country,
		year,
        Lifeexpectancy,
        AdultMortality,
        SUM(AdultMortality) OVER(PARTITION BY country  ORDER BY year) AS rolling_total
FROM worldlifexpectancy
;



