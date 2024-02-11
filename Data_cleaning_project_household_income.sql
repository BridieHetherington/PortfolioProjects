SELECT * FROM Data_cleaning_project.us_household_income_data;




-- CREATING STORED PROCEDURE FOR DATA CLEANING --




DELIMITER $$
DROP PROCEDURE IF EXISTS copy_and_clean_data;
CREATE PROCEDURE copy_and_clean_data()
BEGIN
    -- CREATE TABLE IF NOT EXISTS --
    CREATE TABLE IF NOT EXISTS `us_household_income_data_cleaned` (
        `row_id` int DEFAULT NULL,
        `id` int DEFAULT NULL,
        `State_Code` int DEFAULT NULL,
        `State_Name` text,
        `State_ab` text,
        `County` text,
        `City` text,
        `Place` text,
        `Type` text,
        `Primary` text,
        `Zip_Code` int DEFAULT NULL,
        `Area_Code` int DEFAULT NULL,
        `ALand` int DEFAULT NULL,
        `AWater` int DEFAULT NULL,
        `Lat` double DEFAULT NULL,
        `Lon` double DEFAULT NULL,
        `Timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- COPY DATA TO NEW TABLE --
    INSERT INTO us_household_income_data_cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM us_household_income_data;
    
-- DATA CLEANING STEPS --

DELETE FROM Data_cleaning_project.us_household_income_data_cleaned 
WHERE 
	row_id IN (
	SELECT row_id
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id, `TimeStamp`
			ORDER BY id, `TimeStamp`) AS row_num
	FROM 
		Data_cleaning_project.us_household_income_data_cleaned
) duplicates
WHERE 
	row_num > 1
);

-- Fixing some data quality issues by fixing typos and general standardization


UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET County = UPPER(County);

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET City = UPPER(City);

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET Place = UPPER(Place);

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET State_Name = UPPER(State_Name);

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE Data_cleaning_project.us_household_income_data_cleaned
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';

END $$
DELIMITER ;



CALL copy_and_clean_data();


-- CHECKING IF STORED PROCEDURE HAS WORKED --



SELECT row_id, id, row_num
FROM (
	SELECT row_id, id,
		ROW_NUMBER() OVER (
			PARTITION BY id
			ORDER BY id) AS row_num
	FROM 
		Data_cleaning_project.us_household_income_data_cleaned
) duplicates
WHERE 
	row_num > 1
;



SELECT COUNT(row_id)
FROM us_household_income_data_cleaned;


SELECT state_name, COUNT(state_name)
FROM us_household_income_data_cleaned
GROUP BY state_name;




-- CREATE EVENT --


CREATE EVENT run_data_cleaning
ON SCHEDULE EVERY 2 MINUTE
DO CALL copy_and_clean_data();








