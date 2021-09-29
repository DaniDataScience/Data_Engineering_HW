-- HOMEWORK 2

-- EXC 1: Based on the previous chapter, create a table called “employee” with two columns: “id” and “employee_name”. NULL values should not be accepted for these 2 columns.
CREATE TABLE employee
(ID INTEGER NOT NULL,
employee VARCHAR(32),
primary key (ID));

-- EXC 2: What state figures in the 145th line of our database?
SELECT state from birdstrikes limit 144,1;

-- EXC 3 :What is flight_date of the latest birstrike in this database?
select flight_date date from birdstrikes order by flight_date desc limit 1;

-- EXC 4: What was the cost of the 50th most expensive damage?
select * from birdstrikes order by cost desc limit 49,1;

-- EXC 5: What state figures in the 2nd record, if you filter out all records which have no state and no bird_size specified?
select * from birdstrikes where state is not null and cost is not null;
select * from birdstrikes where state <> "" AND  bird_size <> "";

-- EXC 6: How many days elapsed between the current date and the flights happening in week 52, for incidents from Colorado? (Hint: use NOW, DATEDIFF, WEEKOFYEAR)
 SELECT datediff(NOW(), flight_date) 
	FROM birdstrikes
    WHERE weekofyear(flight_date) =52 AND state="Colorado";