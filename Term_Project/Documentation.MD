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

The detailed content of each table can be seen in the image below:
<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/EER_diagram_vf.png">


<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/Analytics_plan.png">


<img height= 500 src="https://github.com/DaniDataScience/Data_Engineering_HW/blob/main/Term_Project/Pictures/Data_Warehouse.png">



