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
	Median_Income VARCHAR(8));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MedianHouseholdIncome2015.txt'
	INTO TABLE MedianHouseholdIncome
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\r\n"
	IGNORE 1 LINES
	(State,City,Median_Income);

-- CREATING POVERTY RATE TABLE -----------------------------------
DROP TABLE IF EXISTS PercentageBelowPoverty;
CREATE TABLE PercentageBelowPoverty
	(State VARCHAR(8),
	City VARCHAR(250),
	poverty_rate VARCHAR(8));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PercentagePeopleBelowPovertyLevel.txt'
	INTO TABLE PercentageBelowPoverty
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY '\r\n'
	IGNORE 1 LINES
	(State, City, poverty_rate);

-- CREATING SHARE RACE YB CITY TABLE --------------------------------
DROP TABLE IF EXISTS ShareRaceByCity;
CREATE TABlE ShareRaceByCity
	(State VARCHAR(8),
	City VARCHAR(255),
	share_white VARCHAR(8),
	share_black VARCHAR(8),
	share_native_american VARCHAR(8),
	share_asian VARCHAR(8),
	share_hispanic VARCHAR(8));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ShareRaceByCity.txt'
	INTO TABLE ShareRaceByCity
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(State, City, share_white, share_black, share_native_american, share_asian, share_hispanic);

-- CREATE TABLE % OF PEOPLE OVER 25 COMPLETING HIGH SCHOOL ------------------
DROP TABLE IF EXISTS PeopleOver25CompletingHighSchool;
CREATE TABLE PeopleOver25CompletingHighSchool
	(State varchar(8),
	City varchar(255),
	percent_completed_hs varchar(8));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PercentOver25CompletedHighSchool.txt'
	into table PeopleOver25CompletingHighSchool
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(State,City,percent_completed_hs);

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
	
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PoliceKillingsUS.txt'
	INTO TABLE shootings2015
	FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\'
	LINES TERMINATED BY "\n"
	IGNORE 1 LINES
	(id,name,date,manner_of_death,armed,age,gender,race,city,state,signs_of_mental_illness,threat_level,flee,body_camera);

-- -----------------------------------------------------------
-- ANALYTICAL PLAN -------------------------------------------
-- -----------------------------------------------------------?

-- Questions to be anwsered: 
-- - What is the distribution of shootings by race?
-- - How many fatal shootings have happened in 2015 in the US?
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
	UPDATE medianhouseholdincome SET Median_Income="" WHERE Median_Income="(X)";

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
	UPDATE shareracebycity SET share_white="" WHERE share_white="(X)";
	UPDATE shareracebycity SET share_black="" WHERE share_black="(X)";
	UPDATE shareracebycity SET share_native_american="" WHERE share_native_american="(X)";
	UPDATE shareracebycity SET share_asian="" WHERE share_asian="(X)";
	UPDATE shareracebycity SET share_hispanic="" WHERE share_hispanic="(X)";
	
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
	UPDATE percentagebelowpoverty SET poverty_rate="" WHERE poverty_rate="-";
	
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
DROP PROCEDURE IF EXISTS peopleover25completinghighschool;
DELIMITER //
CREATE PROCEDURE Clean_peopleover25completinghighschool()
	BEGIN

	ALTER TABLE peopleover25completinghighschool
		ADD COLUMN city_cleaned VARCHAR(255) AFTER City;
	UPDATE peopleover25completinghighschool SET city_cleaned = city;
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' city' FROM city_cleaned);
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' town' FROM city_cleaned);
	UPDATE peopleover25completinghighschool SET city_cleaned = TRIM(BOTH ' CDP' FROM city_cleaned);
	UPDATE peopleover25completinghighschool SET percent_completed_hs="" WHERE percent_completed_hs="-";
	
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
	poverty_rate
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
SELECT race, count(race) FROM datawarehouse GROUP BY race; 

-- How many shootings occured where the victim was black in places where black population is a minority
DROP VIEW IF EXISTS Black_majority_or_minority;
CREATE VIEW `Black_majority_or_minority` AS
SELECT Black_pop_ratio,count(*) FROM datawarehouse WHERE race = "B" GROUP BY Black_pop_ratio;

-- What is the median income and poverty rate per race where shootings occured?
DROP VIEW IF EXISTS Income_and_poverty_rate_per_race;
CREATE VIEW `Income_and_poverty_rate_per_race` AS
SELECT race, count(race),round(avg(median_income)), round(avg(poverty_rate)) FROM datawarehouse Group by race ;
