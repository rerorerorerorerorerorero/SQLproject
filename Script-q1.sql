/* Question 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? */
WITH salary_with_change AS (
    SELECT
        payroll_year,
        industry_branch_name,
        ROUND(AVG(avg_salary), 2) AS avg_salary,
        LAG(ROUND(AVG(avg_salary), 2)) OVER (
            PARTITION BY industry_branch_name
            ORDER BY payroll_year
        ) AS prev_year_salary
    FROM t_andrii_lykhodid_project_SQL_primary_final
    GROUP BY payroll_year, industry_branch_name
)
SELECT
    payroll_year,
    industry_branch_name,
    avg_salary,
    prev_year_salary,
    ROUND(avg_salary - prev_year_salary, 2) AS salary_change,
    ROUND(((avg_salary - prev_year_salary) / prev_year_salary) * 100, 2) AS salary_change_pct
FROM salary_with_change
WHERE prev_year_salary IS NOT NULL
  AND avg_salary < prev_year_salary
ORDER BY industry_branch_name, payroll_year;
