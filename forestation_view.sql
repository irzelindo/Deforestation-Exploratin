-- CREATE A VIEW

CREATE VIEW forestation AS
    (SELECT fa.country_code,
         fa.country_name,
         fa.year,
         fa.forest_area_sqkm,
         la.total_area_sq_mi,
         rg.region,
         rg.income_group,
         ((forest_area_sqkm/(total_area_sq_mi*2.59))*100) AS forest_area_percent
    FROM forest_area fa
    JOIN land_area la
        ON fa.country_code=la.country_code
            AND fa.year=la.year
    JOIN regions rg
        ON rg.country_code=la.country_code );