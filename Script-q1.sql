/*Question 1:Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/
WITH wages_with_lag AS (
    SELECT 
        industry_branch_code,
        year,
        average_wage,
        LAG(average_wage) OVER (PARTITION BY industry_branch_code ORDER BY year) AS previous_year_wage
    FROM 
        t_andrii_lykhodid_project_SQL_primary_final
    WHERE 
        industry_branch_code <> 'all'
)
SELECT 
    industry_branch_code,
    year,
    average_wage,
    previous_year_wage,
    average_wage - previous_year_wage AS wage_difference
FROM 
    wages_with_lag
WHERE 
    previous_year_wage IS NOT NULL
    AND average_wage < previous_year_wage
ORDER BY 
    industry_branch_code, year;
