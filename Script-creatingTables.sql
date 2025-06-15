
CREATE TABLE t_andrii_lykhodid_payroll AS
SELECT
    cp.payroll_year,
    cpvt.code AS value_type_code,
    cpvt.name AS value_type_name,
    cpib.code AS industry_branch_code,
    cpib.name AS industry_branch_name,
    AVG(cp.value) AS average_value
FROM czechia_payroll cp
LEFT JOIN czechia_payroll_value_type cpvt
    ON cp.value_type_code = cpvt.code
LEFT JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code
WHERE cp.value IS NOT NULL
  AND cp.value_type_code = 5958  
  AND cp.calculation_code = 200  
GROUP BY
    cp.payroll_year,
    cpvt.code,
    cpvt.name,
    cpib.code,
    cpib.name
ORDER BY
    cp.payroll_year,
    cpib.code;

CREATE TABLE t_andrii_lykhodid_price AS 
SELECT
    p.category_code,
    c.name AS category_name,
    c.price_unit,
    EXTRACT(YEAR FROM p.date_from) AS year,
    AVG(p.value) AS avg_price
FROM czechia_price p
JOIN czechia_price_category c
    ON p.category_code = c.code
WHERE p.region_code IS NULL
GROUP BY
    p.category_code,
    c.name,
    c.price_unit,
    EXTRACT(YEAR FROM p.date_from);

CREATE TABLE t_andrii_lykhodid_project_SQL_primary_final AS
SELECT
    pay.payroll_year,
    pay.value_type_name,
    pay.industry_branch_name,
    pay.average_value AS avg_salary,
    prc.year,
    prc.category_name,
    prc.price_unit,
    prc.avg_price
FROM t_andrii_lykhodid_payroll pay
JOIN t_andrii_lykhodid_price prc
    ON pay.payroll_year = prc.year;


SELECT * FROM t_andrii_lykhodid_project_SQL_primary_final;

CREATE TABLE t_andrii_lykhodid_project_sql_secondary_final AS
SELECT
	c.country AS country_name,
	e.year,
	e.gdp,
	e.population
FROM
	countries c
LEFT JOIN 
	economies e 
	ON c.country = e.country
WHERE
	e.year BETWEEN 2006 AND 2018;
SELECT * FROM t_andrii_lykhodid_project_SQL_secondary_final;
