/*
 * value_type code: 5958 - mzda
 * 					316 - pocet osob
 *
 *industrie brunches: a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s;
 *years 2006-2018
 * milk code- 114201
 * bread code- 111301
 */
drop table t_andrii_lykhodid_project_sql_primary_final;
create table t_andrii_lykhodid_project_SQL_primary_final (year int,industry_branch_code bpchar(3), average_wage int, higher_than_previous_year BOOLEAN, milk_litres int, bread_kilos int, lowest_inflation_good_code int, hyperinflation_year boolean);
/*Wages for each year and every branch from 2006 to 2018*/
INSERT INTO t_andrii_lykhodid_project_SQL_primary_final (
    year, industry_branch_code, average_wage
)
SELECT 
    payroll_year AS year,
    industry_branch_code,
    AVG(value) AS average_wage
FROM 
    czechia_payroll
WHERE 
    value_type_code = '5958'
    AND payroll_year BETWEEN 2006 AND 2018
    AND industry_branch_code BETWEEN 'A' AND 'S'
GROUP BY 
    payroll_year, industry_branch_code;


/*Average across all branches*/
INSERT INTO t_andrii_lykhodid_project_sql_primary_final (
    year,
    industry_branch_code,
    average_wage
)
SELECT 
    year,
    'ALL' AS industry_branch_code,
    AVG(average_wage)::INT AS average_wage
FROM 
    t_andrii_lykhodid_project_sql_primary_final
WHERE 
    industry_branch_code != 'ALL'
GROUP BY 
    year;


/*Adding higher than previous year and updating it for every branch*/
WITH wage_diff AS (
    SELECT
        year,
        industry_branch_code,
        average_wage,
        LAG(average_wage) OVER (PARTITION BY industry_branch_code ORDER BY year) AS prev_year_wage
    FROM t_andrii_lykhodid_project_sql_primary_final
)
UPDATE t_andrii_lykhodid_project_sql_primary_final AS target
SET higher_than_previous_year = CASE 
    WHEN wage_diff.prev_year_wage IS NOT NULL AND wage_diff.average_wage > wage_diff.prev_year_wage THEN TRUE
    ELSE FALSE
END
FROM wage_diff
WHERE target.year = wage_diff.year
  AND target.industry_branch_code = wage_diff.industry_branch_code;




/*Adding values for milk and bread*/
WITH milk_prices_per_year AS (
    SELECT 
        EXTRACT(YEAR FROM date_from)::INT AS year,
        AVG(value) AS avg_price_milk
    FROM czechia_price
    WHERE category_code = 114201 --milk code
    GROUP BY EXTRACT(YEAR FROM date_from)
)
UPDATE t_andrii_lykhodid_project_SQL_primary_final AS main
SET milk_litres = ROUND(main.average_wage / milk_prices_per_year.avg_price_milk)
FROM milk_prices_per_year
WHERE main.year = milk_prices_per_year.year
  AND main.industry_branch_code = 'ALL';

WITH bread_prices_per_year AS (
    SELECT 
        EXTRACT(YEAR FROM date_from)::INT AS year,
        AVG(value) AS avg_price_bread
    FROM czechia_price
    WHERE category_code = 111301  -- bread code
    GROUP BY EXTRACT(YEAR FROM date_from)
)
UPDATE t_andrii_lykhodid_project_SQL_primary_final AS main
SET bread_kilos = ROUND(main.average_wage / bread_prices_per_year.avg_price_bread)
FROM bread_prices_per_year
WHERE main.year = bread_prices_per_year.year
  AND main.industry_branch_code = 'ALL';


select * from t_andrii_lykhodid_project_sql_primary_final where industry_branch_code = 'ALL' order by year;

/*Finding lowest  inflation good for each year*/
WITH avg_price_per_year AS (
    SELECT 
        category_code,
        EXTRACT(YEAR FROM date_from)::INT AS year,
        AVG(value) AS avg_value
    FROM czechia_price
    WHERE EXTRACT(YEAR FROM date_from) BETWEEN 2006 AND 2018
    GROUP BY category_code, EXTRACT(YEAR FROM date_from)
),
price_with_growth AS (
    SELECT 
        curr.category_code,
        curr.year,
        ((curr.avg_value - prev.avg_value) / prev.avg_value) AS growth
    FROM avg_price_per_year curr
    JOIN avg_price_per_year prev
      ON curr.category_code = prev.category_code
     AND curr.year = prev.year + 1
    WHERE curr.year BETWEEN 2007 AND 2018
),
lowest_growth_per_year AS (
    SELECT DISTINCT ON (year)
        year,
        category_code
    FROM price_with_growth
    ORDER BY year, growth ASC
)
UPDATE t_andrii_lykhodid_project_sql_primary_final AS main
SET lowest_inflation_good_code = lowest_growth.category_code
FROM lowest_growth_per_year AS lowest_growth
WHERE main.year = lowest_growth.year
  AND TRIM(main.industry_branch_code) = 'ALL';



/*Calculating a year where inflation in goods prices is atleast 10% than growth in wages*/
WITH food_prices_by_year AS (
    SELECT 
        EXTRACT(YEAR FROM date_from)::INT AS year,
        AVG(value) AS avg_food_price
    FROM czechia_price
    WHERE category_code BETWEEN 111100 AND 2000002
    GROUP BY EXTRACT(YEAR FROM date_from)
),
food_growth AS (
    SELECT 
        curr.year,
        ((curr.avg_food_price - prev.avg_food_price) / prev.avg_food_price) AS food_price_growth
    FROM food_prices_by_year curr
    JOIN food_prices_by_year prev
      ON curr.year = prev.year + 1
),
wage_by_year AS (
    SELECT 
        year,
        AVG(average_wage) AS avg_wage
    FROM t_andrii_lykhodid_project_sql_primary_final
    WHERE TRIM(industry_branch_code) = 'ALL'
    GROUP BY year
),
wage_growth AS (
    SELECT 
        curr.year,
        ((curr.avg_wage - prev.avg_wage) / prev.avg_wage) AS wage_growth
    FROM wage_by_year curr
    JOIN wage_by_year prev
      ON curr.year = prev.year + 1
),
combined_growth AS (
    SELECT 
        f.year,
        (f.food_price_growth - w.wage_growth) AS growth_difference
    FROM food_growth f
    JOIN wage_growth w ON f.year = w.year
)
UPDATE t_andrii_lykhodid_project_sql_primary_final AS main
SET hyperinflation_year = CASE 
    WHEN cg.growth_difference > 0.10 THEN TRUE
    ELSE FALSE
END
FROM combined_growth cg
WHERE main.year = cg.year
  AND TRIM(main.industry_branch_code) = 'ALL';

select * from t_andrii_lykhodid_project_sql_primary_final order by year;




