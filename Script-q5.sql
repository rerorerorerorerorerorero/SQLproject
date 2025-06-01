/*Question 5:Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?*/
WITH czech_gdp AS (
    SELECT 
        year,
        gdp
    FROM 
        economies
    WHERE 
        country = 'Czech Republic'
),
combined AS (
    SELECT 
        f.year,
        c.gdp,
        f.average_wage,
        f.milk_litres,
        f.bread_kilos,
        LAG(c.gdp) OVER (ORDER BY f.year) AS prev_gdp,
        LAG(f.average_wage) OVER (ORDER BY f.year) AS prev_wage,
        LAG(f.milk_litres) OVER (ORDER BY f.year) AS prev_milk,
        LAG(f.bread_kilos) OVER (ORDER BY f.year) AS prev_bread
    FROM 
        t_andrii_lykhodid_project_SQL_primary_final f
    JOIN 
        czech_gdp c ON f.year = c.year
    WHERE 
        f.industry_branch_code = 'ALL'
),
final AS (
    SELECT 
        year,
        ROUND(((gdp - prev_gdp) * 100.0 / prev_gdp)::numeric, 2) AS gdp_growth_pct,
        ROUND(((average_wage - prev_wage) * 100.0 / prev_wage)::numeric, 2) AS wage_growth_pct,
        ROUND(((milk_litres - prev_milk) * 100.0 / prev_milk)::numeric, 2) AS milk_affordability_pct,
        ROUND(((bread_kilos - prev_bread) * 100.0 / prev_bread)::numeric, 2) AS bread_affordability_pct
    FROM 
        combined
    WHERE 
        prev_gdp IS NOT NULL
)
SELECT *
FROM final
WHERE NOT (
    gdp_growth_pct = 0 AND
    wage_growth_pct = 0 AND
    milk_affordability_pct = 0 AND
    bread_affordability_pct = 0
)
ORDER BY year;
