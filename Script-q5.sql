/*Question 5:Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*/
WITH yearly_gdp_per_capita AS (
    SELECT 
        year,
        ROUND((AVG(gdp::numeric) / AVG(population))::numeric, 2) AS avg_gdp_per_capita
    FROM t_andrii_lykhodid_project_sql_secondary_final
    WHERE country_name = 'Czech Republic'
      AND year BETWEEN 2006 AND 2018
    GROUP BY year
),
yearly_gdp_growth AS (
    SELECT
        year,
        avg_gdp_per_capita,
        LAG(avg_gdp_per_capita) OVER (ORDER BY year) AS prev_year_avg_gdp_per_capita,
        ROUND(
            ((avg_gdp_per_capita - LAG(avg_gdp_per_capita) OVER (ORDER BY year)) / 
            NULLIF(LAG(avg_gdp_per_capita) OVER (ORDER BY year), 0)) * 100,
            2
        ) AS gdp_per_capita_growth_pct
    FROM yearly_gdp_per_capita
)
SELECT
    year,
    avg_gdp_per_capita,
    prev_year_avg_gdp_per_capita,
    gdp_per_capita_growth_pct
FROM yearly_gdp_growth
ORDER BY year;