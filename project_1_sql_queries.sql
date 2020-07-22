 /* Introduction You’re a data analyst for ForestQuery, a non-profit
ON a mission to reduce deforestation around the world AND to raise awareness about this important environmental topic. Your executive director AND her leadership team members are looking to understand which countries AND regions around the world seem to have forests that have been shrinking IN size, AND also which countries AND regions have the most significant forest area, both IN terms of amount AND percent of total area. The hope is that these findings can help inform initiatives, communications, AND personnel allocation to achieve the largest impact with the precious few resources that the organization has at its disposal. You’ve been able to find tables of data online dealing with forestation AS well AS total land area AND region groupings, AND you’ve brought these tables together into a database that you’d like to query to answer some of the most important questions IN preparation for a meeting with the ForestQuery executive team coming up IN a few days. Ahead of the meeting, you’d like to prepare AND disseminate a report for the leadership team that uses complete sentences to help them understand the global deforestation overview BETWEEN 1990 AND 2016. Steps to Complete

CREATE a View called “forestation” by joining all three tables - forest_area, land_area AND regions IN the workspace. The forest_area AND land_area tables join
ON both country_code AND year. The regions TABLE joins these based
ON only country_code. IN the ‘forestation’ View, include the following: All of the columns of the origin tables A new column that provides the percent of the land area that is designated AS forest. Keep IN mind that the column forest_area_sqkm IN the forest_area TABLE AND the land_area_sqmi IN the land_area TABLE are IN different units (square kilometers AND square miles, respectively), so an adjustment will need to be made IN the calculation you write (1 sq mi = 2.59 sq km). */ /* GLOBAL SITUATION What was the total forest area (in sq km) of the world IN 1990? What was the total forest area (in sq km) of the world IN 2016? What was the change (in sq km) IN the forest area of the world
FROM 1990 to 2016? What was the percent change IN forest area of the world BETWEEN 1990 AND 2016? If you compare the amount of forest area lost BETWEEN 1990 AND 2016, to which country's total area IN 2016 is it closest? */

CREATE OR REPLACE VIEW forestation AS (
SELECT  fa.country_code
       ,fa.country_name
       ,fa.year
       ,fa.forest_area_sqkm
       ,la.total_area_sq_mi
       ,rg.region
       ,rg.income_group
       ,((forest_area_sqkm/(total_area_sq_mi*2.59))*100) AS forest_area_percent
FROM forest_area fa
INNER JOIN land_area la
ON fa.country_code=la.country_code AND fa.year=la.year
INNER JOIN regions rg
ON rg.country_code=la.country_code ); ----------------------------------------------------------------------------------------- /* Total forest area IN sq KM IN 1990 AND 2016 */ WITH T1 AS (

SELECT  fa.country_code
       ,fa.country_name
       ,fa.year
       ,fa.forest_area_sqkm
FROM forest_area fa
WHERE year=1990
AND forest_area_sqkm IS NOT NULL
AND total_area_sq_mi IS NOT NULL
AND LOWER(country_name) NOT IN ('world'))
SELECT  T1.year
       ,CAST(SUM(forest_area_sqkm) AS DECIMAL(18,2)) AS total_forest_area
FROM T1
GROUP BY  1; -------------------------------------------------------------------------------------------- /* Difference BETWEEN 1990 AND 2016 AND reduction percentage */ WITH T1 AS (

SELECT  CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,2)) AS total_1990
FROM (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
FROM forest_area
WHERE year=1990
AND forest_area_sqkm IS NOT NULL
AND LOWER(country_name) NOT IN ('world') ) AS fa ), T2 AS (
SELECT  CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,2)) AS total_2016
FROM (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
FROM forest_area
WHERE year=2016
AND forest_area_sqkm IS NOT NULL
AND LOWER(country_name) NOT IN ('world') ) AS fa )
SELECT  (T1.total_1990-T2.total_2016)                                            AS difference
       ,CAST(((T1.total_1990-T2.total_2016)/T1.total_1990)*100 AS DECIMAL(18,2)) AS percentage
FROM T1, T2; ------------------------------------------------------------------------------------------ /* Amount of forest area lost BETWEEN 1990 AND 2016 to which country's total area IN 2016 is it closest*/

-- SELECT  la.country_code
       ,-- la.country_name
       ,-- la.year
       ,-- la.total_area_sqKM
FROM
-- (
SELECT  *
       ,-- CAST((total_area_sq_mi*2.59) AS DECIMAL(18 -- 2)) AS total_area_sqKM
-- FROM land_area
-- WHERE year=2016
-- AND forest_area_sqkm IS NOT NULL
-- AND LOWER(country_name) NOT IN ('world')
-- AND LOWER(country_name) NOT IN ('world')
) AS la
-- WHERE la.total_area_sqKM <= 2191038.09
-- ORDER BY la.total_area_sqKM DESC
LIMIT 1; ------------------------------------------------------------------------------------------------- WITH T1 AS (

SELECT  year
       ,CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,2)) AS total_1990
FROM
(
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
FROM forest_area
WHERE year=1990
AND LOWER(country_name) NOT IN ('world')
) AS fa
GROUP BY  1)
         ,T2 AS (
SELECT  year
       ,CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,2)) AS total_2016
FROM
(
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
FROM forest_area
WHERE year=2016
AND LOWER(country_name) NOT IN ('world')
) AS fa
GROUP BY  1)
         ,T3 AS (
SELECT  (T1.total_1990-T2.total_2016) AS diff
FROM T1, T2), T4 AS (
SELECT  *
       ,CAST((total_area_sq_mi*2.59) AS DECIMAL(18,2)) AS total_area_sqKM
FROM land_area
WHERE year=2016
AND LOWER(country_name) NOT IN ('world') )
SELECT  T4.country_code
       ,T4.country_name
       ,T4.year
       ,T4.total_area_sqKM
FROM T4, T3
WHERE T4.total_area_sqKM <= T3.diff
ORDER BY T4.total_area_sqKM DESC
LIMIT 1; ----------------------------------------------------------------------------------------- /* REGIONAL OUTLOOK

CREATE a TABLE that shows the Regions AND their percent forest area (sum of forest area divided by sum of land area) IN 1990 AND 2016. (Note that 1 sq mi = 2.59 sq km). What was the percent forest of the entire world IN 2016? Which region had the HIGHEST percent forest IN 2016, AND which had the LOWEST, to 2 decimal places? What was the percent forest of the entire world IN 1990? Which region had the HIGHEST percent forest IN 1990, AND which had the LOWEST, to 2 decimal places? Based
ON the TABLE you created, which regions of the world DECREASED IN forest area
FROM 1990 to 2016? */ WITH T2 AS
(
SELECT  *
       ,((T1.total_forest_area/T1.total_land_area)*100) AS forest_area_percent
FROM
(
	SELECT  year
	       ,region
	       ,SUM(forest_area_sqkm)      AS total_forest_area
	       ,SUM(total_area_sq_mi*2.59) AS total_land_area
	FROM forestation
	WHERE year=1990
	AND forest_area_sqkm IS NOT NULL
	AND total_area_sq_mi IS NOT NULL
	GROUP BY  1
	         ,2
) T1
), T3 AS (
SELECT  year
       ,SUM(T2.total_forest_area) AS global_forest_area
       ,SUM(T2.total_land_area)   AS global_land_area
FROM T2
GROUP BY  1 )
SELECT  T3.year
       ,CAST(T3.global_forest_area                                             AS DECIMAL(18,2))
       ,CAST(T3.global_land_area                                               AS DECIMAL(18,2))
       ,CAST((T3.global_forest_area/T3.global_land_area)*100 AS DECIMAL(18,2)) AS global_forest_percent
FROM T3; ------------------------------------------------------------------------------------------ WITH T2 AS
(
SELECT  *
       ,CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,2)) AS forest_area_percent
FROM
(
	SELECT  year
	       ,region
	       ,SUM(forest_area_sqkm)      AS total_forest_area
	       ,SUM(total_area_sq_mi*2.59) AS total_land_area
	FROM forestation
	WHERE year=1990
	AND forest_area_sqkm IS NOT NULL
	AND total_area_sq_mi IS NOT NULL
	GROUP BY  1
	         ,2
) T1
)
SELECT  year
       ,region
       ,CAST(total_forest_area AS DECIMAL(18,2))
       ,CAST(total_land_area   AS DECIMAL(18,2))
       ,forest_area_percent
FROM T2
ORDER BY 5 DESC; ----------------------------------------------------------------------------------------------- WITH T2 AS
(
SELECT  *
       ,CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,2)) AS forest_area_percent
FROM
(
	SELECT  year
	       ,region
	       ,SUM(forest_area_sqkm)      AS total_forest_area
	       ,SUM(total_area_sq_mi*2.59) AS total_land_area
	FROM forestation
	WHERE year=2016
	AND LOWER(region) NOT IN ('world')
	AND forest_area_sqkm IS NOT NULL
	AND total_area_sq_mi IS NOT NULL
	GROUP BY  1
	         ,2
) T1
)
SELECT  year
       ,region
       ,CAST(total_forest_area AS DECIMAL(18,2))
       ,CAST(total_land_area   AS DECIMAL(18,2))
       ,forest_area_percent
FROM T2
ORDER BY 5 ASC; ---------------------------------------------------------------------------------------------- WITH T2 AS
(
SELECT  *
       ,CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,2)) AS forest_area_percent
FROM
(
	SELECT  year
	       ,region
	       ,SUM(forest_area_sqkm)      AS total_forest_area
	       ,SUM(total_area_sq_mi*2.59) AS total_land_area
	FROM forestation
	WHERE year=1990
	AND LOWER(region) NOT IN ('world')
	AND forest_area_sqkm IS NOT NULL
	AND total_area_sq_mi IS NOT NULL
	GROUP BY  1
	         ,2
) T1
), T3 AS (
SELECT  *
       ,CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,2)) AS forest_area_percent
FROM
(
SELECT  year
       ,region
       ,SUM(forest_area_sqkm)      AS total_forest_area
       ,SUM(total_area_sq_mi*2.59) AS total_land_area
FROM forestation
WHERE year=2016
AND LOWER(region) NOT IN ('world')
AND forest_area_sqkm IS NOT NULL
AND total_area_sq_mi IS NOT NULL
GROUP BY  1
         ,2
) T1 )
SELECT  T3.year
       ,T3.region
       ,CAST(T3.total_forest_area AS DECIMAL(18,2))
       ,CAST(T3.total_land_area   AS DECIMAL(18,2))
       ,T3.forest_area_percent
FROM T2
JOIN T3
ON T2.region = T3.region
WHERE T3.forest_area_percent < T2.forest_area_percent
ORDER BY 5 DESC; -------------------------------------------------------------------------------------------------

-- SELECT  *
       ,CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,2)) AS forest_area_percent
FROM
(
SELECT  year
       ,SUM(forest_area_sqkm)      AS total_forest_area
       ,SUM(total_area_sq_mi*2.59) AS total_land_area
FROM forestation
WHERE year=2016
AND LOWER(region) NOT IN ('world')
AND forest_area_sqkm IS NOT NULL
AND total_area_sq_mi IS NOT NULL
GROUP BY  1
) T1 --------------------------------------------------------------------------------------------------- /* COUNTRY-LEVEL DETAIL Which country saw the largest amount increase IN forest area
FROM 1990 to 2016? What was the change IN sq km? Which country saw the 2nd largest increase over this time period? What was the change IN sq km? Which country saw the largest percent increase IN forest area
FROM 1990 to 2016? What was the percent change to 2 decimal places? Which 5 countries saw the largest amount decrease IN forest area
FROM 1990 to 2016? What was the difference IN forest area? Which 5 countries saw the largest percent decrease IN forest area
FROM 1990 to 2016? What was the percent change to 2 decimal places? If countries were grouped by percent forestation IN quartiles, which group had the most countries IN it IN 2016? List all of the countries that were IN the 4th quartile
(percent forest > 75%
) IN 2016. How many countries had a percent forestation higher than the United States IN 2016? */ WITH T1 AS (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
FROM forestation
WHERE year=2016
AND forest_area_sqkm is NOT NULL), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
FROM forestation
WHERE year=1990
AND forest_area_sqkm is NOT NULL), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,(T1.forest_area_sqkm-T2.forest_area_sqkm) AS increased_amount
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,CAST(T3.increased_amount AS DECIMAL(18,2))
FROM T3
ORDER BY T3.increased_amount DESC;

SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59)                                                               AS total_area_sqKm
       ,MAX(forest_area_sqkm) OVER (PARTITION BY year,country_name ORDER BY forest_area_sqkm) AS max_forest_area
FROM forestation; ---------------------------------------------------------------------------------------------------------

-- SELECT  *
FROM forestation
WHERE country_code IN ( 'HKG', 'GIB', 'MCO', 'ETH', 'MAF', 'MAC', 'QAT', 'CUW', 'SDN', 'SMR', 'NRU', 'XKX', 'SXM', 'SSD'); ---------------------------------------------------------------------------------------------------------- WITH T1 AS (

SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=2016
AND forest_area_percent is NOT NULL), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=1990
AND forest_area_percent is NOT NULL), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,T2.forest_area_sqkm                             AS forest_area_1990
       ,T2.total_area_sqkm                              AS total_area_sqkm_1990
       ,T1.forest_area_sqkm                             AS forest_area_2016
       ,T1.total_area_sqkm                              AS total_area_sqkm_2016
       ,(T1.forest_area_percent-T2.forest_area_percent) AS increased_percent
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,T3.forest_area_1990
       ,T3.total_area_sqkm_1990
       ,T3.forest_area_2016
       ,T3.total_area_sqkm_2016
       ,CAST(T3.increased_percent AS DECIMAL(18,2))
FROM T3
ORDER BY T3.increased_percent DESC; -------------------------------------------------------------------------------------------------- WITH T1 AS
(
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=2016
AND forest_area_percent is NOT NULL
), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=1990
AND forest_area_percent is NOT NULL), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,T2.forest_area_sqkm                             AS forest_area_1990
       ,T2.total_area_sqkm                              AS total_area_sqkm_1990
       ,T1.forest_area_sqkm                             AS forest_area_2016
       ,T1.total_area_sqkm                              AS total_area_sqkm_2016
       ,(T1.forest_area_percent-T2.forest_area_percent) AS increased_percent
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,T3.forest_area_1990
       ,T3.total_area_sqkm_1990
       ,T3.forest_area_2016
       ,T3.total_area_sqkm_2016
       ,CAST(T3.increased_percent AS DECIMAL(18,2))
FROM T3
WHERE T3.forest_area_1990 < T3.forest_area_2016
ORDER BY T3.increased_percent DESC; ----------------------------------------------------------------------------------------- WITH T1 AS (

SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
FROM forestation
WHERE year=2016
AND forest_area_sqkm is NOT NULL
AND LOWER(country_name) NOT IN ('world')), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
FROM forestation
WHERE year=1990
AND forest_area_sqkm is NOT NULL
AND LOWER(country_name) NOT IN ('world')), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,T2.region
       ,(T1.forest_area_sqkm-T2.forest_area_sqkm) AS decreased_amount
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,T3.region
       ,CAST(T3.decreased_amount AS DECIMAL(18,2))
FROM T3
ORDER BY T3.decreased_amount ASC; --------------------------------------------------------------------------------------- WITH T1 AS
(
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=2016
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')
), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=1990
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,T2.region
       ,T2.forest_area_sqkm                             AS forest_area_1990
       ,T2.total_area_sqkm                              AS total_area_sqkm_1990
       ,T1.forest_area_sqkm                             AS forest_area_2016
       ,T1.total_area_sqkm                              AS total_area_sqkm_2016
       ,(T1.forest_area_percent-T2.forest_area_percent) AS increased_percent
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,T3.region
       ,T3.forest_area_1990
       ,T3.total_area_sqkm_1990
       ,T3.forest_area_2016
       ,T3.total_area_sqkm_2016
       ,CAST(T3.increased_percent AS DECIMAL(18,2))
FROM T3
WHERE T3.forest_area_1990 < T3.forest_area_2016
ORDER BY T3.increased_percent ASC; ---------------------------------------------------------------------------------- WITH T1 AS (

SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=2016
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')), T2 AS (
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59) AS total_area_sqkm
       ,forest_area_percent
FROM forestation
WHERE year=1990
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')), T3 AS (
SELECT  T1.country_code
       ,T1.country_name
       ,T1.year
       ,T2.region
       ,T2.forest_area_sqkm                             AS forest_area_1990
       ,T2.total_area_sqkm                              AS total_area_sqkm_1990
       ,T1.forest_area_sqkm                             AS forest_area_2016
       ,T1.total_area_sqkm                              AS total_area_sqkm_2016
       ,(T1.forest_area_percent-T2.forest_area_percent) AS decreased_percent
FROM T1
JOIN T2
ON T1.country_code = T2.country_code)
SELECT  T3.country_code
       ,T3.country_name
       ,T3.region
       ,T3.forest_area_1990
       ,T3.total_area_sqkm_1990
       ,T3.forest_area_2016
       ,T3.total_area_sqkm_2016
       ,CAST(T3.decreased_percent AS DECIMAL(18,2))
FROM T3
WHERE T3.forest_area_1990 > T3.forest_area_2016
ORDER BY T3.decreased_percent ASC; ---------------------------------------------------------------------------------------------------

-- SELECT  p.Quartiles
       ,COUNT(*)
FROM
(
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59)                                  AS total_area_sqkm
       ,forest_area_percent
       ,CASE WHEN forest_area_percent <= 25 THEN '1 Quartile'
             WHEN forest_area_percent > 25 AND forest_area_percent <= 50 THEN '2 Quartile'
             WHEN forest_area_percent > 50 AND forest_area_percent <= 75 THEN '3 Quartile'
             WHEN forest_area_percent > 75 THEN '4 Quartile' END AS Quartiles
FROM forestation
WHERE year = 2016
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')
AND forest_area_percent IS NOT NULL
) AS p
GROUP BY  1; -----------------------------------------------------------------------------------------------------

-- SELECT  *
       ,CAST(forest_area_percent AS DECIMAL(18,2))
FROM
(
SELECT  country_code
       ,country_name
       ,year
       ,region
       ,forest_area_sqkm
       ,(total_area_sq_mi*2.59)                                  AS total_area_sqkm
       ,forest_area_percent
       ,CASE WHEN forest_area_percent <= 25 THEN '1 Quartile'
             WHEN forest_area_percent > 25 AND forest_area_percent <= 50 THEN '2 Quartile'
             WHEN forest_area_percent > 50 AND forest_area_percent <= 75 THEN '3 Quartile'
             WHEN forest_area_percent > 75 THEN '4 Quartile' END AS Quartiles
FROM forestation
WHERE year = 2016
AND forest_area_percent is NOT NULL
AND LOWER(country_name) NOT IN ('world')
AND forest_area_percent IS NOT NULL
) AS p
WHERE p.Quartiles='4 Quartile'
ORDER BY total_area_sqkm DESC ------------------------------------------------------------------------------------------------------
-- SET TIMEZONE='Africa/Maputo' -- EXERCISES
SET TIMEZONE='America/New_York'
SET TIMEZONE='America/California'

CREATE TABLE "json_test" ( "val" JSONB );

INSERT INTO "json_test" VALUES ('{"name":"irzelindo", "gender":"male"}'), ('{"name":"sherly", "gender":"female"}');

SELECT  "val"
FROM json_test
WHERE "val"->>'name'='irzelindo'; COMMENT
ON COLUMN "json_test"."val" IS 'Both name AND gender json key-value data type'

CREATE TABLE "movies" ("id" SERIAL, "name" TEXT, "release_date" DATE);

INSERT INTO "movies" ("name", "release_date") VALUES ('Elysium', '2013-05-20'), ('Avengers', '2012-03-29'), ('John Wick', '2019-10-1')

INSERT INTO "people" (first_name, last_name)
SELECT  first_name
       ,last_name
FROM denormalized_people
WHERE first_name is not null
AND last_name is not null;

SELECT  a.id
       ,a.first_name
       ,a.last_name
       ,regexp_split_to_table(a.emails,',') AS email_address
FROM
(
SELECT  p.id
       ,p.first_name
       ,p.last_name
       ,dp.emails
FROM denormalized_people dp
INNER JOIN people p
ON dp.first_name=p.first_name AND dp.last_name=p.last_name
) a;

SELECT  name
       ,split_part(name,' ',1) AS fisrt_name
       ,split_part(name,' ',1) AS last_name
       ,
FROM user_data;

SELECT  *
FROM user_data;

CREATE TABLE "state" ("id" SERIAL, "code" VARCHAR(2));

INSERT INTO "state" (code)
SELECT  DISTINCT state
FROM "user_data";

ALTER TABLE "user_data" ADD COLUMN "statde_id" INT;

 UPDATE "user_data"

SET "state_id" = (
SELECT  s.id
FROM "states" s
JOIN "user_data" ud
ON s.code = ud.state);

UPDATE "user_data"
SET "state_id" = ( s.id)
FROM "states" s
JOIN "user_data" ud
ON s.code = ud.state
WHERE s.code = ud.state;

ALTER TABLE "Table_Name" ADD CONSTRAINT "Name_Of_The_Constraint" UNIQUE ("Column_Name")