\c bar
--- Get the top 3 product types that have proven most profitable
SELECT product_line 
FROM products 
INNER JOIN measures 
USING(product_code) 
GROUP BY product_line 
ORDER BY SUM(profit) DESC LIMIT(3);

--- Get the top 3 products by most items sold
SELECT product_name 
FROM products 
INNER JOIN measures 
USING(product_code) 
GROUP BY product_code 
ORDER BY SUM(quantity_ordered) DESC LIMIT(3);


--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium
--- this is a very ugly solution, but it works :)
(SELECT customer_country as country, product_name as prod_name, product_code as prod_code, SUM(quantity_ordered) as quantity
    FROM products AS p 
    INNER JOIN measures AS m 
    USING(product_code) 
    INNER JOIN customers AS c 
    USING (customer_number) 
    WHERE customer_country = 'Spain'
    GROUP BY product_name,product_code,customer_country
    ORDER BY SUM(quantity_ordered) DESC LIMIT (3))
UNION ALL
(SELECT customer_country as country, product_name as prod_name, product_code as prod_code, SUM(quantity_ordered) as quantity
    FROM products AS p 
    INNER JOIN measures AS m 
    USING(product_code) 
    INNER JOIN customers AS c 
    USING (customer_number) 
    WHERE customer_country = 'USA'
    GROUP BY product_name,product_code,customer_country
    ORDER BY SUM(quantity_ordered) DESC LIMIT (3))
UNION ALL
(SELECT customer_country as country, product_name as prod_name, product_code as prod_code, SUM(quantity_ordered) as quantity
    FROM products AS p 
    INNER JOIN measures AS m 
    USING(product_code) 
    INNER JOIN customers AS c 
    USING (customer_number) 
    WHERE customer_country = 'Belgium'
    GROUP BY product_name,product_code,customer_country
    ORDER BY SUM(quantity_ordered) DESC LIMIT (3))
;




--- Get the most profitable day of the week
SELECT day_of_week 
FROM measures 
INNER JOIN dates 
ON (measures.order_date=dates.dates) 
GROUP BY day_of_week 
ORDER BY SUM(profit) DESC LIMIT(1);
--- result 4 means that this is friday

--- Get the top 3 city-quarters with the highest average profit margin in their sales
SELECT office_city,quarter 
FROM measures 
INNER JOIN offices 
USING(office_code) 
INNER JOIN dates 
ON (measures.order_date = dates.dates) 
GROUP BY office_city, quarter 
ORDER BY AVG(margin) DESC LIMIT(3);

-- List the employees who have sold more goods (in $ amount) than the average employee.

select employee_number, last_name as l_n, first_name as f_n
	from empl as e
	join measures as m
	on m.sales_rep_employee_number = e.employee_number
	group by employee_number
	having sum(revenue) > (
		select sum(revenue)/count(distinct(employee_number))
		from measures as m 
        INNER JOIN empl as e
        ON (m.sales_rep_employee_number = e.employee_number)
	);

-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts (BONUS: Add the employee number)
SELECT order_number as order_num, SUM(revenue)as sum_revenue,sales_rep_employee_number AS empl_nr
    FROM orders AS o
    INNER JOIN measures AS m
    USING(order_number)
    GROUP BY o.order_number,m.sales_rep_employee_number
    ORDER BY SUM(revenue) DESC LIMIT (SELECT (count(*) / 10) AS top10 FROM orders );

