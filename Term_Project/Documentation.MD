## Submission - Police shootings 2015 dataset

My project focuses on the Police shooting cases in the USA in 2015: Cases in which the Police used lethal force against the detained person. 
These cases have stirred communities across the US and news were broadcasted across the globe on protests against police brutality.
One of the key questions stirring the public regarding police brutality is wether racism is or is not an important factor in the escalation of such situations.

To analyize this question, I have downloaded a database with police shootign incidents from 2015 and I enriched this table with additional ethnic and social data.

### Key analytical questions

During my project, I was aiming to anwser the following questions:
 - How many fatal shootings have happened in 2015 in the US?
 - What is the distribution of shootings by race?
 - How many shootings occured where the victim was black in places where black population is a minority?
 - What is the median income and poverty rate per race in locations where shootings occured?

### Operational layer

My operational layer consists of 5 tables, originally csv files. One for the shooting incidents and 4 auxiliary tables with social and ethnic data

- A table of each shooting incident in 2015, with various attributes of the event
- A table on the average median income, per state and settlement
- A table on the percentage of population compleging highschool before the age 25, per state and settlement
- A table on the share of ethnic races in % per state and settlement
- A table on the percentage of pople living below the poverty level, per state and settlement

Median Household Income Table:
**Key**	| **Description**	| **Type** | **Sample Value**
----| ---------------- | ----| -------------
State	| US state |	VARCHAR(8) |	NY
City	| city	| VARCHAR(250)	| New York
Median Income	| Median household income per state and city | INTEGER	| 124564

Percentage below poverty level Table:
**Key**	| **Description**	| **Type** | **Sample Value**
----| ------------ | ----| -------------
State	| US state |	VARCHAR(8) |	NY
City	| city	| VARCHAR(250)	| New York
Avg poverty rate	| Percentage of population per state per city living under the poverty level	| DOUBLE	| 6.6

People over 25 completed high school Table:
**Key**	| **Description**	| **Type** | **Sample Value**
----| ------------ | ----| -------------
State	| US state |	VARCHAR(8) |	NY
City	| city	| VARCHAR(250)	| New York
Percent completed highschool	| Average percentage of state population above 25 years old who have graduated high school	| DOUBLE	| 22.2

Share of race by city Table:
**Key**	| **Description**	| **Type** | **Sample Value**
----| ------------ | ----| -------------
State	| US state |	VARCHAR(8) |	NY
City	| city	| VARCHAR(250)	| New York
B	| Black ethnicity	| DOUBLE	| 4.6
H	| Hispanic ethnicity	| DOUBLE	| 6.0
N	| Native american	| DOUBLE	| 52.0
H	| Hispanic	| DOUBLE	| 17.2
A	| Asian	| DOUBLE	| 7.4
W	| White ethnicity	| DOUBLE	| 8.0

Plice shootin incidents Table:
**Key**	| **Description**	| **Type** | **Sample Value**
----| ------------ | ----| -------------
id	| Data table id of fatal shooting	| INT	| 125
name	| Shooting victim name	| VARCHAR(255)	| Tim Elliot
date	| Date of fatal shooting	| DATE	| 2015-02-01
manner_of_death	| Manner of fatal police killing	| VARCHAR(50)	| shot
armed	| Indicates if the victim was armed with some sort of weapon that a police officer believed could cause harm	| VARCHAR(50)	| unarmed
age	| Age of victim	| INT	| 53
gender	| Gender of victim	| VARCHAR(50)	| M
race	| Race of victim	| VARCHAR(50) | W
city	| City of fatal police shooting	| VARCHAR(50)	| Essex
signs_of_mental_illness	| Mental illness status of victim	| VARCHAR(50)	| TRUE
threat_level	| Threat level of victim	| VARCHAR(50)	| attack
flee	| Flee status of victim during fatal shooting	| VARCHAR(50)	| Not fleeing
body_camera	| Body camera status of police officer who committed fatal police shooting	| VARCHAR(50)	| FALSE


The operational layer needed cleaning for the following issues
 - ID needs for aux tables to be created based on Sate & City combination 
 - cities have "town", or "city" words added to the city name in the auxiliary tables 
 - cities are duplicated in the auxiliary tables with "CDP" edings, e.g. "Washington" and "Washington CDP"

I created a new calculated column to determine if the balck population is in a minority or in a majority within the Share of Race table, called Black_pop_ratio.
I also created a column caled id for the auxilary tables, where i combined city and state, as a unique indentifier (as city names were duplicated along various states)


This resulte in the following operational layer
<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/EER_diagram_vf.png">

## Analytics plan

My analytics plan is the following:

- Loading up the acquired data with initial data cleaning (e.g. getting rid of "-" and "(X)" as missing values
- Rurther cleaning the data using stored procdures and creating a trigger that notifies when a new row is added to the police shootings table
- Create ETL pipeline to create a denormalised data warehouse
- Create ETL pipeline to create data marts for the three analytical teams

To create the analytica layer, I used the comibnation of city & state in the auxiliary tables to join the ethnic and social data to the shootings2015 table.

<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/Analytics_plan.png">

Joining the selected columns resulted in the following datawarehouse, which includes all the variables I need to anwser my analytical questions
<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/Data_Warehouse.png">

Using this datawarehouse, I created data marts to anwser each specific question

## Data marts

### Number of shootings
From this simple mart we see that in 2015, there were 2535 incidents

### Shooting distribution by race
This data mart shows the distribution of he 2535 shootings among the different ethnicities. We get to know that 47% (1201) of victims were white, 24% (618) were black, 17% (423) were hispanic, and the rest were native american, asion or other. Also we see that in 195 cases the race of the victim was not recorded

### Black minority/majority
This data mart zooms into incidents where the victim was black, and shows wether the black community was a majority or a minority in the settlement.
It is surpizing to see that in 71% of these indicents, the victim was living as a minority in the settlement! Ony 16% of black victims were living as a majority in the settlement. 

### Median income per race and Poverty level per race
These tables show the minimum, maximum, average and std. of the median income and the poverty level for each location where an incident occured, segmented accordingly to the ethnicity of the victim. 
