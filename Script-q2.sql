/*Question 2:Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?*/
SELECT 
    payroll_year,
    category_name,
    avg_salary,
    ROUND(avg_price, 2),
    FLOOR(avg_salary / avg_price) AS quantity
FROM t_andrii_lykhodid_project_SQL_primary_final
WHERE 
    industry_branch_name IS NULL  
    AND category_name IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
    AND payroll_year IN (2006, 2018)
ORDER BY 
    category_name,
    payroll_year;
