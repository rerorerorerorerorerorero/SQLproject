/*Question 4:Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/
SELECT year, hyperinflation_year 
FROM t_andrii_lykhodid_project_sql_primary_final 
WHERE hyperinflation_year = true;
