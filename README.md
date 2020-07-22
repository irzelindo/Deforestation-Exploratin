# Deforestation-Exploration
ForestQuery, a non-profit organization. on a mission to reduce deforestation around the world and which raises awareness about this important environmental topic.

My executive director and her leadership team members are looking to understand which countries and regions around the world seem to have forests that have been shrinking in size, and also which countries and regions have the most significant forest area, both in terms of amount and percent of total area. The hope is that these findings can help inform initiatives, communications, and personnel allocation to achieve the largest impact with the precious few resources that the organization has at its disposal.

I was able to find tables of data online dealing with forestation as well as total land area and region groupings, I brought these tables together into a database that I'd like to query to answer some of the most important questions in preparation for a meeting with the ForestQuery executive team coming up in a few days. Ahead of the meeting, I'd like to prepare and disseminate a report for the leadership team that uses complete sentences to help them understand the global deforestation overview between 1990 and 2016.

## Steps to Complete
1. Create a View called [**“forestation”**](https://github.com/irzelindo/Deforestation-Exploratin/blob/master/forestation_view.sql) by joining all three tables - **forest_area**, **land_area** and **regions**.
2. The **forest_area** and **land_area** tables join on both **country_code** AND **year**.
3. The **regions** table joins these based on only **country_code**.
4. In the **forestation** View, include the following:

* All of the columns of the origin tables
* A new column that provides the **percent** of the land area that is designated as forest.

5. Keep in mind that the column **forest_area_sqkm** in the **forest_area** table and the **land_area_sqmi** in the **land_area** table are in different units **(square kilometers and square miles, respectively)**, so an adjustment will need to be made in the calculation you write **(1 sq mi = 2.59 sq km)**.

## Instructions
I'll be creating a report using complete sentences for the executive team. I'll use a template and work through each section. There are 5 parts to the report I will be working on.

* Global Situation;
* Regional Outlook;
* Country-Level Detail;
* Recommendations;
* Appendix: SQL queries used;

## Instructions:

Answering these questions will help to add information into the template.
I'll use these questions as guides to write SQL queries.
The output from the queries will answer these particular questions:

### 1. GLOBAL SITUATION 

a. What was the total forest area (in sq km) of the world in 1990?

b. What was the total forest area (in sq km) of the world in 2016?

c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?

d. What was the percent change in forest area of the world between 1990 and 2016?

e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

### 2. REGIONAL OUTLOOK

Here I've created a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).

Based on the table...

a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?

c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?

### 3. COUNTRY-LEVEL DETAIL

a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?

b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.

e. How many countries had a percent forestation higher than the United States in 2016?

Find all answers for this questions on the [*projetc_template*](https://github.com/irzelindo/Deforestation-Exploratin/blob/master/project-template-deforestation-exploration-solution.pdf) or in [*sql_queries.sql*](https://github.com/irzelindo/Deforestation-Exploratin/blob/master/sql_queries.sql) files
