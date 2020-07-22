-- GLOBAL SITUATION
-- What was the total forest area (in sq km) of the world in 1990?
WITH T1 AS
    (SELECT fa.country_code,
         fa.country_name,
         fa.year,
         fa.forest_area_sqkm
    FROM forest_area fa
    WHERE year=1990
            AND forest_area_sqkm IS NOT NULL AND LOWER(country_name) NOT IN ('world'))
SELECT T1.year,
         CAST(SUM(forest_area_sqkm) AS DECIMAL(18,
         2)) AS total_forest_area
FROM T1
GROUP BY  1;

-- What was the total forest area (in sq km) of the world in 2016?
WITH T1 AS
    (SELECT fa.country_code,
         fa.country_name,
         fa.year,
         fa.forest_area_sqkm
    FROM forest_area fa
    WHERE year=2016
            AND forest_area_sqkm IS NOT NULL
            AND LOWER(country_name) NOT IN ('world'))
SELECT T1.year,
         CAST(SUM(forest_area_sqkm) AS DECIMAL(18,
         2)) AS total_forest_area
FROM T1
GROUP BY  1;

-- What was the change (in sq km) in the forest area of the world from 1990 to 2016?
WITH T1 AS
    (SELECT CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_1990
    FROM
        (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm
        FROM forest_area
        WHERE year=1990
                AND forest_area_sqkm IS NOT NULL
                AND LOWER(country_name) NOT IN ('world') ) AS fa ), T2 AS
        (SELECT CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_2016
        FROM
            (SELECT country_code ,
        country_name,
        year ,
        forest_area_sqkm
            FROM forest_area
            WHERE year=2016
                    AND forest_area_sqkm IS NOT NULL
                    AND LOWER(country_name) NOT IN ('world') ) AS fa )
        SELECT (T1.total_1990-T2.total_2016) AS difference ,
        CAST(((T1.total_1990-T2.total_2016)/T1.total_1990)*100 AS DECIMAL(18,
        2)) AS percentage
    FROM T1, T2;

-- What was the percent change in forest area of the world between 1990 and 2016?
WITH T1 AS
    (SELECT CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_1990
    FROM
        (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm
        FROM forest_area
        WHERE year=1990
                AND forest_area_sqkm IS NOT NULL
                AND LOWER(country_name) NOT IN ('world') ) AS fa ), T2 AS
        (SELECT CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_2016
        FROM
            (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm
            FROM forest_area
            WHERE year=2016
                    AND forest_area_sqkm IS NOT NULL
                    AND LOWER(country_name) NOT IN ('world') ) AS fa )
        SELECT (T1.total_1990-T2.total_2016) AS difference ,
        CAST(((T1.total_1990-T2.total_2016)/T1.total_1990)*100 AS DECIMAL(18,
        2)) AS percentage
    FROM T1, T2;

-- If you compare the amount of forest area lost between 1990 and 2016, to which
-- country's total area in 2016 is it closest?
WITH T1 AS
    (SELECT year ,
        CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_1990
    FROM
        (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm
        FROM forest_area
        WHERE year=1990
                AND LOWER(country_name) NOT IN ('world') ) AS fa
        GROUP BY  1) ,T2 AS
        (SELECT year ,
        CAST(SUM(fa.forest_area_sqkm) AS DECIMAL(18,
        2)) AS total_2016
        FROM
            (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm
            FROM forest_area
            WHERE year=2016
                    AND LOWER(country_name) NOT IN ('world') ) AS fa
            GROUP BY  1),T3 AS
            (SELECT (T1.total_1990-T2.total_2016) AS diff
            FROM T1, T2), T4 AS
            (SELECT * ,
        CAST((total_area_sq_mi*2.59) AS DECIMAL(18,
        2)) AS total_area_sqKM
            FROM land_area
            WHERE year=2016
                    AND LOWER(country_name) NOT IN ('world') )
        SELECT T4.country_code ,
        T4.country_name ,
        T4.year ,
        T4.total_area_sqKM
    FROM T4, T3
WHERE T4.total_area_sqKM <= T3.diff
ORDER BY  T4.total_area_sqKM DESC LIMIT 1;

-- REGIONAL OUTLOOK
-- Create a table that shows the Regions and their percent forest area (sum of forest area
-- divided by sum of land area) in 1990 and 2016. (Note that 1 sq mi = 2.59 sq km).
WITH T2 AS
    (SELECT *,
         ((T1.total_forest_area/T1.total_land_area)*100) AS forest_area_percent
    FROM
        (SELECT year,
         region,
         SUM(forest_area_sqkm) AS total_forest_area,
         SUM(total_area_sq_mi*2.59) AS total_land_area
        FROM forestation
        WHERE year=1990
                AND forest_area_sqkm IS NOT NULL
                AND total_area_sq_mi IS NOT NULL
        GROUP BY  1,2 ) T1 ), T3 AS
        (SELECT year,
         SUM(T2.total_forest_area) AS global_forest_area,
         SUM(T2.total_land_area) AS global_land_area
        FROM T2
        GROUP BY  1 )
    SELECT T3.year,
         CAST(T3.global_forest_area AS DECIMAL(18,
         2)),
         CAST(T3.global_land_area AS DECIMAL(18,
         2)),
         CAST((T3.global_forest_area/T3.global_land_area)*100 AS DECIMAL(18,
         2)) AS global_forest_percent
FROM T3;

-- What was the percent forest of the entire world in 2016? Which region had the HIGHEST
-- percent forest in 2016, and which had the LOWEST, to 2 decimal places?
WITH T2 AS
    (SELECT *,
         CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,
         2)) AS forest_area_percent
    FROM
        (SELECT year,
         region,
         SUM(forest_area_sqkm) AS total_forest_area,
         SUM(total_area_sq_mi*2.59) AS total_land_area
        FROM forestationWHERE year=1990
                AND forest_area_sqkm IS NOT NULL
                AND total_area_sq_mi IS NOT NULL
        GROUP BY  1,2 ) T1 )
    SELECT year,
         region,
         CAST(total_forest_area AS DECIMAL(18,
         2)),
         CAST(total_land_area AS DECIMAL(18,
         2)),
         forest_area_percent
FROM T2
ORDER BY  5 DESC;

-- What was the percent forest of the entire world in 1990? Which region had the HIGHEST
-- percent forest in 1990, and which had the LOWEST, to 2 decimal places?
WITH T2 AS
    (SELECT *,
         CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,
         2)) AS forest_area_percent
    FROM
        (SELECT year,
         region,
         SUM(forest_area_sqkm) AS total_forest_area,
         SUM(total_area_sq_mi*2.59) AS total_land_area
        FROM forestation
        WHERE year=2016
                AND LOWER(region) NOT IN ('world')
                AND forest_area_sqkm IS NOT NULL
                AND total_area_sq_mi IS NOT NULL
        GROUP BY  1,2 ) T1 )
    SELECT year,
         region,
         CAST(total_forest_area AS DECIMAL(18,
         2)),
         CAST(total_land_area AS DECIMAL(18,
         2)),
         forest_area_percent
FROM T2
ORDER BY  5 ASC;

-- Based on the table you created, which regions of the world DECREASED in forest area
-- from 1990 to 2016?
WITH T2 AS
    (SELECT * ,
        CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,
        2)) AS forest_area_percent
    FROM
        (SELECT year ,
        region ,
        SUM(forest_area_sqkm) AS total_forest_area ,
        SUM(total_area_sq_mi*2.59) AS total_land_area
        FROM forestation
        WHERE year=1990
                AND LOWER(region) NOT IN ('world')
                AND forest_area_sqkm IS NOT NULL
                AND total_area_sq_mi IS NOT NULL
        GROUP BY  1 ,2 ) T1 ), T3 AS
        (SELECT * ,
        CAST(((T1.total_forest_area/T1.total_land_area)*100) AS DECIMAL(18,
        2)) AS forest_area_percent
        FROM
            (SELECT year ,
        region ,
        SUM(forest_area_sqkm) AS total_forest_area ,
        SUM(total_area_sq_mi*2.59) AS total_land_area
            FROM forestation
            WHERE year=2016
                    AND LOWER(region) NOT IN ('world')
                    AND forest_area_sqkm IS NOT NULL
                    AND total_area_sq_mi IS NOT NULL
            GROUP BY  1 ,2 ) T1 )
        SELECT T3.year ,
        T3.region ,
        CAST(T3.total_forest_area AS DECIMAL(18,
        2)) ,
        CAST(T3.total_land_area AS DECIMAL(18,
        2)) ,
        T3.forest_area_percent
    FROM T2
INNER JOIN T3
    ON T2.region = T3.regionWHERE T3.forest_area_percent < T2.forest_area_percent
ORDER BY  5 DESC;

-- COUNTRY-LEVEL DETAIL
-- Which country saw the largest amount increase in forest area from 1990 to 2016?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=2016
            AND forest_area_sqkm is NOT NULL), T2 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm is NOT NULL), T3 AS
    (SELECT T1.country_code,
         T1.country_name,
         T1.year,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS increased_amount
    FROM T1
    INNER JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         CAST(T3.increased_amount AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_amount DESC;

-- What was the change in sq km?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestationWHERE year=2016
            AND forest_area_sqkm is NOT NULL), T2 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm IS NOT NULL), T3 AS
    (SELECT T1.country_code,
         T1.country_name,
         T1.year,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS increased_amount
    FROM T1
    INNER JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         CAST(T3.increased_amount AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_amount DESC;

-- Which country saw the 2nd largest increase over this time period?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=2016
            AND forest_area_sqkm is NOT null), T2 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm is NOT null), T3 AS
    (SELECT T1.country_code,
         T1.country_name,
         T1.year,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS increased_amountFROM T1
    INNER JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         CAST(T3.increased_amount AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_amount DESC;

-- What was the change in sq km?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=2016
            AND forest_area_sqkm is NOT null), T2 AS
    (SELECT country_code,
         country_name,
         year,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm is NOT null), T3 AS
    (SELECT T1.country_code,
         T1.country_name,
         T1.year,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS increased_amount
    FROM T1
    INNER JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         CAST(T3.increased_amount AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_amount DESC;

-- Which country saw the largest percent increase in forest area from 1990 to 2016?
WITH T1 AS
    (SELECT country_code ,
        country_name ,
        year,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent
    FROM forestation
    WHERE year=2016
            AND forest_area_percent is NOT null), T2 AS
    (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent
    FROM forestation
    WHERE year=1990
            AND forest_area_percent is NOT null), T3 AS
    (SELECT T1.country_code ,
        T1.country_name ,
        T1.year ,
        T2.forest_area_sqkm AS forest_area_1990 ,
        T2.total_area_sqkm AS total_area_sqkm_1990 ,
        T1.forest_area_sqkm AS forest_area_2016 ,
        T1.total_area_sqkm AS total_area_sqkm_2016 ,
        (T1.forest_area_percent-T2.forest_area_percent) AS increased_percent
    FROM T1
    INNER JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code ,
        T3.country_name ,
        T3.forest_area_1990 ,
        T3.total_area_sqkm_1990 ,
        T3.forest_area_2016 ,
        T3.total_area_sqkm_2016 ,
        CAST(T3.increased_percent AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_percent DESC;

-- What was the percent change to 2 decimal places?
WITH T1 AS
    (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent
    FROM forestationWHERE year=2016
            AND forest_area_percent is NOT null), T2 AS
    (SELECT country_code ,
        country_name ,
        year ,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent
    FROM forestation
    WHERE year=1990
            AND forest_area_percent is NOT null), T3 AS
    (SELECT T1.country_code ,
        T1.country_name ,
        T1.year ,
        T2.forest_area_sqkm AS forest_area_1990 ,
        T2.total_area_sqkm AS total_area_sqkm_1990 ,
        T1.forest_area_sqkm AS forest_area_2016 ,
        T1.total_area_sqkm AS total_area_sqkm_2016 ,
        (T1.forest_area_percent-T2.forest_area_percent) AS increased_percent
    FROM T1
    JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code ,
        T3.country_name ,
        T3.forest_area_1990 ,
        T3.total_area_sqkm_1990 ,
        T3.forest_area_2016 ,
        T3.total_area_sqkm_2016 ,
        CAST(T3.increased_percent AS DECIMAL(18,
        2))
FROM T3
ORDER BY  T3.increased_percent DESC;

-- Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016?
-- What was the percent change to 2 decimal places?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         region,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=2016
            AND forest_area_sqkm is NOT null), T2 AS
    (SELECT country_code,
        country_name,
         year,
         region,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm is NOT null), T3 AS
    (SELECT T1.country_code,
         T1.country_name,
         T1.year,
         T2.region,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS decreased_amount
    FROM T1
    JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         T3.region,
         CAST(T3.decreased_amount AS DECIMAL(18,
         2))
FROM T3
ORDER BY  T3.decreased_amount ASC;

-- What was the difference in forest area?
WITH T1 AS
    (SELECT country_code,
         country_name,
         year,
         region,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=2016
            AND forest_area_sqkm is NOT null), T2 AS
    (SELECT country_code,
         country_name,
         year,
         region,
         forest_area_sqkm,
         (total_area_sq_mi*2.59) AS total_area_sqkm
    FROM forestation
    WHERE year=1990
            AND forest_area_sqkm is NOT null), T3 AS
    (SELECT T1.country_code,
        T1.country_name,
         T1.year,
         T2.region,
         (T1.forest_area_sqkm-T2.forest_area_sqkm) AS decreased_amount
    FROM T1
    JOIN T2
        ON T1.country_code = T2.country_code)
SELECT T3.country_code,
         T3.country_name,
         T3.region,
         CAST(T3.decreased_amount AS DECIMAL(18,
         2))
FROM T3
ORDER BY  T3.decreased_amount ASC;

-- If countries were grouped by percent forestation in quartiles, which group had the most
-- countries in it in 2016?
-- List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT p.Quartiles,
         COUNT(*)
FROM
    (SELECT country_code ,
        country_name ,
        year ,
        region ,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent ,
        CASE
        WHEN forest_area_percent <= 25 THEN
        '1 Quartile'
        WHEN forest_area_percent > 25
            AND forest_area_percent <= 50 THEN
        '2 Quartile'
        WHEN forest_area_percent > 50
            AND forest_area_percent <= 75 THEN
        '3 Quartile'
        WHEN forest_area_percent > 75 THEN
        '4 Quartile'
        END AS Quartiles
    FROM forestation
    WHERE year = 2016
            AND forest_area_percent is NOT NULL
            AND LOWER(country_name) NOT IN ('world')
            AND forest_area_percent IS NOT NULL ) AS p
GROUP BY  1;

-- How many countries had a percent forestation higher than the United States in 2016?
SELECT * ,
        CAST(forest_area_percent AS DECIMAL(18,
        2)) FROM
    (SELECT country_code ,
        country_name ,
        year ,
        region ,
        forest_area_sqkm ,
        (total_area_sq_mi*2.59) AS total_area_sqkm ,
        forest_area_percent ,
        CASE
        WHEN forest_area_percent <= 25 THEN
        '1 Quartile'
        WHEN forest_area_percent > 25
            AND forest_area_percent <= 50 THEN
        '2 Quartile'
        WHEN forest_area_percent > 50
            AND forest_area_percent <= 75 THEN
        '3 Quartile'
        WHEN forest_area_percent > 75 THEN
        '4 Quartile'
        END AS Quartiles
    FROM forestation
    WHERE year = 2016
            AND forest_area_percent is NOT NULL
            AND LOWER(country_name) NOT IN ('world')
            AND forest_area_percent IS NOT NULL ) AS p
WHERE p.Quartiles='4 Quartile'
ORDER BY  total_area_sqkm DESC