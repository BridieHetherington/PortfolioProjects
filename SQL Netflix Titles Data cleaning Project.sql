

/* 

DATA CLEANING PROJECT NETFLIX TITLES

*/

SELECT *
FROM PortfolioProject..netflixtitles

---Standardise date format and eparate year added from date added ---


UPDATE netflixtitles
SET date_added = CONVERT(DATE, date_added, 106);



-- Check for missing values in important columns --

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS missing_titles,
  SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_directors,
  SUM(CASE WHEN cast IS NULL THEN 1 ELSE 0 END) AS missing_cast,
  SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
  SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS missing_release_year,
  SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS missing_rating
FROM PortfolioProject..netflixtitles;




-- Label missing values --


UPDATE PortfolioProject..netflixtitles
SET title = COALESCE(title, 'unknown'),
    director = COALESCE(director, 'unknown'),
	cast = COALESCE(cast, 'unknown'),
	country = COALESCE(country, 'unknown'),
	release_year = COALESCE(release_year, 'unknown'),
	rating = COALESCE(rating, 'unknown')

   --- Remove irrelevant columns ---

ALTER TABLE PortfolioProject..netflixtitles
DROP COLUMN F13;




