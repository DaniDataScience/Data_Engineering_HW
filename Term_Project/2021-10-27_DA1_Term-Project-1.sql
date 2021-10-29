DROP schema if exists US_Police_Shootings_2015;
Create schema US_Police_Shootings_2015;
USE US_Police_Shootings_2015;

SHOW VARIABLES LIKE "secure_file_priv";

-- --------------------------------------------------------------------------
-- CREATING THE TABLES AND IMPORTING DATA -----------------------------------
-- --------------------------------------------------------------------------

-- CREATING MEDIAN HOUSEHOLD INCOME TABLE -----------------------------------
DROP TABLE IF EXISTS MedianHouseholdIncome;
CREATE TABLE MedianHouseholdIncome
	(State VARCHAR(8),
	City VARCHAR(255),
	Median_Income DOUBLE);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MedianHouseholdIncome2015.csv'
	INTO TABLE MedianHouseholdIncome
	FIELDS TERMINATED BY ';' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\r\n"
	IGNORE 1 LINES
	(State,City,@Median_Income)
    SET Median_Income = NULLIF(@Median_Income,'');

-- CREATING POVERTY RATE TABLE -----------------------------------
DROP TABLE IF EXISTS PercentageBelowPoverty;
CREATE TABLE PercentageBelowPoverty
	(State VARCHAR(8),
	City VARCHAR(250),
	avg_poverty_rate DOUBLE);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PercentagePeopleBelowPovertyLevel.csv'
	INTO TABLE PercentageBelowPoverty
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES
	(State, City, @avg_poverty_rate)
    SET avg_poverty_rate = NULLIF(@avg_poverty_rate,'');

-- CREATING SHARE RACE YB CITY TABLE --------------------------------
DROP TABLE IF EXISTS ShareRaceByCity;
CREATE TABlE ShareRaceByCity
	(State VARCHAR(8),
	City VARCHAR(255),
	share_white DOUBLE,
	share_black DOUBLE,
	share_native_american DOUBLE,
	share_asian DOUBLE,
	share_hispanic DOUBLE);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ShareRaceByCity.csv'
	INTO TABLE ShareRaceByCity
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\r\n"
	IGNORE 1 LINES
	(State, City, @share_white, @share_black, @share_native_american, @share_asian, @share_hispanic)
    SET share_white = NULLIF(@share_white,''),
		share_black = NULLIF(@share_black,''),
		share_native_american = NULLIF(@share_native_american,''),
		share_asian = NULLIF(@share_asian,''),
		share_hispanic = NULLIF(@share_hispanic,'');

-- CREATE TABLE % OF PEOPLE OVER 25 COMPLETING HIGH SCHOOL ------------------
DROP TABLE IF EXISTS PeopleOver25CompletingHighSchool;
CREATE TABLE PeopleOver25CompletingHighSchool
	(State varchar(8),
	City varchar(255),
	percent_completed_hs DOUBLE);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PercentOver25CompletedHighSchool.csv'
	into table PeopleOver25CompletingHighSchool
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\r\n"
	IGNORE 1 LINES
	(State,City,@percent_completed_hs)
    SET percent_completed_hs = NULLIF(@percent_completed_hs,"-");

-- CREATING POLICE SHOOTINGS TABLE -----------------------------------
DROP TABLE IF EXISTS shootings2015;
CREATE TABLE shootings2015
	(id INTEGER NOT NULL,
	name VARCHAR(255),
	date DATE,
	manner_of_death VARCHAR(50),
	armed VARCHAR(50),
	age VARCHAR(3),
	gender VARCHAR(1),
	race VARCHAR(1),
	city VARCHAR(255),
	state VARCHAR(255),
	signs_of_mental_illness VARCHAR(10),
	threat_level VARCHAR(50),
	flee VARCHAR(50),
	body_camera VARCHAR(10)
	);
	
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PoliceKillingsUS.csv'
	INTO TABLE shootings2015
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(id,name,date,manner_of_death,armed,age,gender,race,city,state,signs_of_mental_illness,threat_level,flee,body_camera);

-- -----------------------------------------------------------
-- ANALYTICAL PLAN -------------------------------------------
-- -----------------------------------------------------------?

-- Questions to be anwsered: 
-- - How many fatal shootings have happened in 2015 in the US?
-- - What is the distribution of shootings by race?
-- - How many shootings occured where the victim was black in places where black population is a minority?
-- - What is the median income and poverty rate per race where shootings occured?

-- -----------------------------------------------------------
-- CREATING STORE PROCEDURES TO CLEAN DATA -------------------
-- -----------------------------------------------------------

-- issues to be fixed:
-- - ID needs for aux tables to be created based on Sate & City combination 
-- - cities have "town", or "city" words added to the city name in the auxiliary tables 
-- - cities are duplicated in the auxiliary tables with "CDP" edings, e.g. "Washington" and "Washington CDP"
-- - Non number values within the aux table data (e.g. "(X)")

-- Median household income -----------------------------------
DROP PROCEDURE IF EXISTS Clean_medianhouseholdincome;
DELIMITER //
CREATE PROCEDURE Clean_medianhouseholdincome()
	BEGIN

	ALTER TABLE medianhouseholdincome
		ADD COLUMN city_cleaned VARCHAR(255) AFTER City;
	UPDATE medianhouseholdincome SET city_cleaned = city;
	UPDATE medianhouseholdincome SET city_cleaned = TRIM(BOTH ' city' FROM city_cleaned);
	UPDATE medianhouseholdincome SET city_cleaned = TRIM(BOTH ' town' FROM city_cleaned);
	UPDATE medianhouseholdincome SET city_cleaned = TRIM(BOTH ' CDP' FROM city_cleaned);

	ALTER TABLE medianhouseholdincome
		ADD COLUMN id VARCHAR(255);
	UPDATE medianhouseholdincome SET id = concat(State,"-",city_cleaned);
 
	DROP TABLE IF EXISTS temp;
	CREATE TABLE temp SELECT *, count(id) FROM medianhouseholdincome GROUP BY id HAVING count(id)>1;
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' city' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' town' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
	
	DELETE medianhouseholdincome
	FROM medianhouseholdincome INNER JOIN temp ON medianhouseholdincome.city = temp.city;

	DROP TABLE temp;
END //
DELIMITER ;

-- Share race by city -----------------------------------
DROP PROCEDURE IF EXISTS Clean_shareracebycity;
DELIMITER //
CREATE PROCEDURE Clean_shareracebycity()
	BEGIN

	ALTER TABLE shareracebycity
		ADD COLUMN city_cleaned VARCHAR(255) AFTER City;
	UPDATE shareracebycity SET city_cleaned = city;
	UPDATE shareracebycity SET city_cleaned = TRIM(BOTH ' city' FROM city_cleaned);
	UPDATE shareracebycity SET city_cleaned = TRIM(BOTH ' town' FROM city_cleaned);
	UPDATE shareracebycity SET city_cleaned = TRIM(BOTH ' CDP' FROM city_cleaned);
		
	ALTER TABLE shareracebycity
		ADD COLUMN id VARCHAR(255);
	UPDATE shareracebycity SET id = concat(State,"-",city_cleaned);
	
	DROP TABLE IF EXISTS temp;
	CREATE TABLE temp SELECT *, count(id) FROM shareracebycity GROUP BY id HAVING count(id)>1;
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' city' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' town' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
		
	DELETE shareracebycity
	FROM shareracebycity INNER JOIN temp ON shareracebycity.city = temp.city;
	
	ALTER TABLE shareracebycity
		ADD COLUMN Black_pop_ratio VARCHAR(50);
	UPDATE shareracebycity SET Black_pop_ratio="Black_minority" WHERE share_black < 50;
	UPDATE shareracebycity SET Black_pop_ratio="Black_majority" where share_black >= 50;
	
	DROP TABLE temp;
	END //
DELIMITER ;

-- % below poverty level -----------------------------------
DROP PROCEDURE IF EXISTS Clean_percentagebelowpoverty;
DELIMITER //
CREATE PROCEDURE Clean_percentagebelowpoverty()
	BEGIN
	
	ALTER TABLE percentagebelowpoverty
		ADD COLUMN city_cleaned VARCHAR(255) AFTER City;
	UPDATE percentagebelowpoverty SET city_cleaned = city;
	UPDATE percentagebelowpoverty SET city_cleaned = TRIM(BOTH ' city' FROM city_cleaned);
	UPDATE percentagebelowpoverty SET city_cleaned = TRIM(BOTH ' town' FROM city_cleaned);
	UPDATE percentagebelowpoverty SET city_cleaned = TRIM(BOTH ' CDP' FROM city_cleaned);
	
	ALTER TABLE percentagebelowpoverty
		ADD COLUMN id VARCHAR(255);
	UPDATE percentagebelowpoverty SET id = concat(State,"-",city_cleaned);
	
	DROP TABLE IF EXISTS temp;
	CREATE TABLE temp SELECT *, count(id) FROM percentagebelowpoverty GROUP BY id HAVING count(id)>1;
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' city' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' town' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
		
	DELETE percentagebelowpoverty
	FROM percentagebelowpoverty INNER JOIN temp ON percentagebelowpoverty.city = temp.city;
	
	DROP TABLE temp;
END //
DELIMITER ;

-- Over 25 completing high school -----------------------------------
DROP PROCEDURE IF EXISTS Clean_peopleover25completinghighschool;
DELIMITER //
CREATE PROCEDURE Clean_peopleover25completinghighschool()
	BEGIN

	ALTER TABLE peopleover25completinghighschool
		ADD COLUMN city_cleaned VARCHAR(255) AFTER City;
	UPDATE peopleover25completinghighschool SET city_cleaned = city;
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' city' FROM city_cleaned);
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' town' FROM city_cleaned);
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' CDP' FROM city_cleaned);
	
	ALTER TABLE peopleover25completinghighschool
		ADD COLUMN id VARCHAR(255);
	UPDATE peopleover25completinghighschool SET id = concat(State,"-",city_cleaned);
 
	DROP TABLE IF EXISTS temp;
	CREATE TABLE temp SELECT *, count(id) FROM peopleover25completinghighschool GROUP BY id HAVING count(id)>1;
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' city' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
	UPDATE temp 
		SET city = concat(TRIM(BOTH ' town' FROM city), " CDP")
		WHERE city NOT LIKE "%CDP%"; 
		
	DELETE peopleover25completinghighschool
	FROM peopleover25completinghighschool INNER JOIN temp ON peopleover25completinghighschool.city = temp.city;
	
	DROP TABLE temp;
END //
DELIMITER ;

-- -----------------------------------------------------------
-- CALLING STORED PROCEDURES TO CLEAN TABLES------------------
-- -----------------------------------------------------------

CALL Clean_medianhouseholdincome();
CALL Clean_peopleover25completinghighschool();
CALL Clean_percentagebelowpoverty();
CALL Clean_shareracebycity();

-- ---------------------------------------------------------
-- CREATING TRIGGER TO UPDATE TABLE -----------------------
-- ----------------------------------------------------------

DROP TRIGGER IF EXISTS update_shootings2015;
CREATE TABLE IF NOT EXISTS messages (message varchar(100) NOT NULL); 
DELIMITER //
CREATE TRIGGER update_shootings2015
AFTER INSERT
ON shotings2015 FOR EACH ROW
BEGIN
	INSERT INTO messages SELECT CONCAT('new id: ', NEW.id);

  	INSERT INTO shotings2015
	SELECT *
	FROM shotings2015
	WHERE id = NEW.id
	ORDER BY date, id;
        
END $$

DELIMITER ;

-- -----------------------------------------------------------
-- CREATE DATA WAREHOUSE  ------------------------------------
-- -----------------------------------------------------------

DROP TABLE IF EXISTS datawarehouse;
CREATE TABLE datawarehouse
SELECT 
	shootings2015.id, shootings2015.city, shootings2015.state, race,
    share_black, Black_pop_ratio,
	percent_completed_hs,
	Median_income,
	avg_poverty_rate
FROM shootings2015
LEFT JOIN shareracebycity
ON shootings2015.city=shareracebycity.city_cleaned AND shootings2015.state=shareracebycity.State
LEFT JOIN peopleover25completinghighschool
ON shootings2015.city=peopleover25completinghighschool.city_cleaned AND shootings2015.state=peopleover25completinghighschool.State
LEFT JOIN medianhouseholdincome
ON shootings2015.city=medianhouseholdincome.city_cleaned AND shootings2015.state=medianhouseholdincome.state
LEFT JOIN percentagebelowpoverty
ON shootings2015.city=percentagebelowpoverty.city_cleaned AND shootings2015.state=percentagebelowpoverty.State;


-- checking if there are same amount of records in the original and the enriched table
-- both contain 2535 records!
SELECT count(*) FROM datawarehouse;
SELECT count(*) FROM shootings2015;

-- -----------------------------------------------------------
--  QUESIONS TO BE ANWSERED ----------------------------------
-- -----------------------------------------------------------

-- How many fatal shootings have happened in 2015 in the US?
DROP VIEW IF EXISTS Number_of_shootings;
CREATE VIEW `Number_of_shootings` AS
SELECT count(*) FROM datawarehouse;

-- What is the distribution of shootings by race
DROP VIEW IF EXISTS Shooting_distribution_by_race;
CREATE VIEW `Shooting_distribution_by_race` AS
SELECT race, count(race), count(race)/2535 as Proportion FROM datawarehouse GROUP BY race; 

-- How many shootings occured where the victim was black in places where black population is a minority
DROP VIEW IF EXISTS Black_majority_or_minority;
CREATE VIEW `Black_majority_or_minority` AS
SELECT Black_pop_ratio,count(*),count(*)/618 as Proportion FROM datawarehouse WHERE race = "B" GROUP BY Black_pop_ratio;

-- What is the poverty rate per race where shootings occured?
DROP VIEW IF EXISTS Poverty_rate_per_race;
CREATE VIEW `Poverty_rate_per_race` AS
SELECT 
	race, 
    count(race),
    round(avg(avg_poverty_rate)) as avg_poverty_rate,
    round(min(avg_poverty_rate)) as min_poverty_rate,
    round(max(avg_poverty_rate)) as max_poverty_rate,
    round(std(avg_poverty_rate)) as std_poverty_rate
FROM datawarehouse Group by race ;

-- What is the median income per race where shootings occured?
DROP VIEW IF EXISTS Median_income_per_race;
CREATE VIEW `Median_income_per_race` AS
SELECT 
	race, 
    count(race),
    round(avg(Median_Income)) as Avg_Median_Income,
    round(min(Median_Income)) as min_Median_Income,
    round(max(Median_Income)) as max_Median_Income,
    round(std(Median_Income)) as std_Median_Income
FROM datawarehouse Group by race ;
