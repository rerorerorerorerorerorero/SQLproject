# Engeto-projekt

## Úvod
Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují **dostupnost základních potravin široké veřejnosti**. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.Potřebují k tomu **od vás připravit robustní datové podklady**, ve kterých bude možné vidět **porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období**Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací **dalších evropských států**ve stejném období, jako primární přehled pro ČR.
### Datové sady, které je možné použít pro získání vhodného datového podkladu

**Primární tabulky:**

*czechia_payroll* – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.

*czechia_payroll_calculation* – Číselník kalkulací v tabulce mezd.

*czechia_payroll_industry_branch* – Číselník odvětví v tabulce mezd.

*czechia_payroll_unit* – Číselník jednotek hodnot v tabulce mezd.

*czechia_payroll_value_type* – Číselník typů hodnot v tabulce mezd.

*czechia_price* – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.

*czechia_price_category* – Číselník kategorií potravin, které se vyskytují v našem přehledu.

**Číselníky sdílených informací o ČR:**

*czechia_region* – Číselník krajů České republiky dle normy CZ-NUTS 2.

*czechia_district* – Číselník okresů České republiky dle normy LAU.

**Dodatečné tabulky:**

*countries* - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.

*economies* - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

### Výzkumné otázky

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## Popis tvorby primární a sekundární tabulky
### Primární tabulka
V prvním kroku jsem si připravil data ze dvou oblastí – z oblasti mezd a z oblasti cen. Pro mzdy jsem použil tabulku czechia_payroll, kterou jsem sjednotil pomocí `JOIN` s tabulkou `czechia_payroll_value_type` a `czechia_payroll_industry_branch`. Toto sjednocení mi umožnilo získat popisné informace – tedy název typu mzdy a název odvětví, ke kterému mzda patří. Klíčovou roli zde hrál filtr `value_type_code = 5958`, který zajišťuje, že pracujeme pouze s mzdou.

Pro ceny jsem následně použil tabulku `czechia_price`, kterou jsem spojil s tabulkou `czechia_price_category`. Díky tomu jsem ke každé položce získal název kategorie a jednotku, ve které je cena uvedena. Zároveň jsem filtroval pouze ty záznamy, které nemají uveden region.

U obou těchto dílčích výběrů jsem použil `GROUP BY`, abych data sjednotil podle jednotlivých let – výstupem tak byla průměrná mzda za rok a průměrná cena za rok.

V druhém kroku jsem pak tyto dvě připravené tabulky spojil pomocí `JOIN`, a to na základě roku. Vznikla tak finální primární tabulka obsahující přehled, který v jednom řádku spojuje mzdu v určitém odvětví a cenu konkrétní kategorie zboží ve stejném roce. Díky tomu lze sledovat, jak se vyvíjely mzdy a ceny paralelně v čase a případně je porovnávat mezi sebou.
### Sekundární tabulka
Tato tabulka vznikla spojením dvou datových zdrojů: `economies`, kde se nachází ekonomická data jako HDP a populace, a tabulky `countries`, která obsahuje informace o jednotlivých státech. Propojení bylo provedeno přes název země.

Díky tomuto spojení bylo možné z každého řádku získat nejen ekonomická data, ale i informaci, jaké zemi patří, a filtrovat například podle polohy.

Vzhledem k tomu, že výsledná sekundární tabulka měla odpovídat rozsahu let v primární tabulce, byla doplněna podmínka WHERE, která vymezuje pouze roky mezi 2006 a 2018. Tak se zajistilo, že časový rozsah sekundární tabulky je srovnatelný s tou primární a data jsou tak lépe použitelná k dalšímu porovnávání.
## Výzkumné otázky:

### **1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

![image](https://github.com/user-attachments/assets/1b010ecc-9be4-45df-9626-77f2b34b7a7c)

Mzdy ve většině odvětví v průběhu let rostly, s výjimkou těchto 25 příkladů.


### **2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

![image](https://github.com/user-attachments/assets/2ea43e4d-9b6a-47bb-a586-09f6f3b76a3b)

Mzdy rostly rychleji než ceny potravin (+64 % oproti +43–50 %), což znamená, že se kupní síla těchto základních produktů za 12 let zlepšila.


### **3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

![image](https://github.com/user-attachments/assets/3f96af8c-5eec-4e4f-8309-efa218089d7a)

Tato tabulka ukazuje, které kategorie potravin zaznamenaly nejpomalejší růst cen (nejnižší roční procentuální růst). Nejméně vzrostly ceny krystalového cukru (98,08 %), následovaných jablky (99,25 %).

### **4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

![image](https://github.com/user-attachments/assets/894dece4-3d7e-4604-b83e-354b2ee0f4a0)

Ne, v letech 2006 až 2018 nebyl rok, kdy by ceny rostly o více než 10 % více než mzda.


### **5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

![image](https://github.com/user-attachments/assets/e3b7aca4-eac0-455c-ab73-587e9ec60b11)

Rok 2006 je počáteční rok, proto máme 2 sloupce s hodnotou NULL.Z dat vyplývá, že výška HDP skutečně ovlivňuje mzdy a ceny potravin, ale s různou intenzitou a časovým zpožděním. Největší dopad má HDP na mzdy (s 1-2letým zpožděním), zatímco ceny potravin jsou více ovlivněny jinimy faktory. Např. po ekonomické krize 2009 (-5,2% HDP) následoval mírný pokles mezd, ale ceny potravin nadále mírně rostly.


