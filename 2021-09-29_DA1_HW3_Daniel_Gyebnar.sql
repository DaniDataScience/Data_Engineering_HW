-- HOMEWORK FOR LESSON 3

-- EXC 1: Do the same with speed. If speed is NULL or speed < 100 create a “LOW SPEED” category, otherwise, mark as “HIGH SPEED”. Use IF instead of CASE!
SELECT aircraft, airline, speed, 
	IF(speed IS NULL OR speed < 100, "LOW SPEED","HIGH SPEED")
    AS speed_chategory
    FROM birdstrikes;
    
-- EXC 2: How many distinct ‘aircraft’ we have in the database?
SELECT count(distinct aircraft) FROM birdstrikes;

-- EXC 3: What was the lowest speed of aircrafts starting with ‘H’
SELECT aircraft,speed FROM birdstrikes WHERE AIRCRAFT like "H%" order by speed asc limit 1;
SELECT aircraft,min(speed) FROM birdstrikes WHERE AIRCRAFT like "H%";

-- EXC 4: Which phase_of_flight has the least number of incidents?
SELECT phase_of_flight,count(phase_of_flight) 
	FROM birdstrikes 
    GROUP BY phase_of_flight 
    ORDER BY count(phase_of_flight);
    
-- EXC 5: What is the rounded highest average cost by phase_of_flight?
SELECT phase_of_flight,round(AVG(cost)) as avg_cost
	FROM birdstrikes 
    group by phase_of_flight
    order by avg_cost desc;
    
-- EXC 6: What is the highest AVG speed of the states with names less than 5 characters?
SELECT state,AVG(speed)
	FROM birdstrikes 
    WHERE length(state) < 5 AND length(state) IS NOT NULL 
    group by state
    order by avg(speed) desc;
SELECT state,AVG(speed)
	FROM birdstrikes 
    GROUP BY state
    HAVING length(state) < 5 
    ORDER BY avg(speed) desc;


