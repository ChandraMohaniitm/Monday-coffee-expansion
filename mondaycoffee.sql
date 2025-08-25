-- ========Table Schema=======
CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);


CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
);
--==================== ANALYSIS =====================

--Q1. City wise Coffee Consumers.
SELECT
	CITY_NAME,
	ROUND((POPULATION * 0.25) / 1000000, 2) AS IN_MILLIONS,
	CITY_RANK
FROM
	CITY ORDER BY
	2 DESC

--Q2. TOP Trending Coffee Product. 
SELECT
	PRODUCT_NAME,
	COUNT(*)
FROM
	PRODUCTS P
	JOIN SALES S ON P.PRODUCT_ID = S.PRODUCT_ID
GROUP BY
	1
ORDER BY	2 DESC

--Q3. Coffee Product Sale Behaviour.
SELECT
	P.PRODUCT_NAME,
	COUNT(*),
	SUM(TOTAL)
FROM
	PRODUCTS P
	NATURAL JOIN SALES
GROUP BY
	1
ORDER BY
	2 DESC
limit 5

--Q4. Customer Satisfaction with Coffee(Avg Rating).
SELECT 
    c.city_name,
    ROUND(AVG(s.rating), 2) AS avg_coffee_rating
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
WHERE p.product_name ILIKE '%coffee%'
GROUP BY c.city_name
ORDER BY avg_coffee_rating 

--Q5. Revenue Potential by City(coffee_revenue).
SELECT 
    c.city_name,
    SUM(s.total) AS coffee_revenue
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
WHERE p.product_name ILIKE '%coffee%'
GROUP BY c.city_name
ORDER BY coffee_revenue desc

--Q6. City wise spent per customer.
SELECT
	CI.CITY_NAME,
	COUNT(DISTINCT C.CUSTOMER_ID),
	SUM(TOTAL),
	SUM(TOTAL) / COUNT(DISTINCT C.CUSTOMER_ID) AS AVG_PER_CUSTOMER
FROM
	SALES S
	JOIN CUSTOMERS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
	JOIN CITY CI ON CI.CITY_ID = C.CITY_ID
GROUP BY
	1
ORDER BY
	3 DESC

--Q7. Rent vs Profit Trade-off.
SELECT 
    c.city_name,
    SUM(s.total) AS coffee_revenue,
    c.estimated_rent,
    ROUND((SUM(s.total) - c.estimated_rent)::numeric, 2) AS profit_after_rent
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
WHERE p.product_name ILIKE '%coffee%'
GROUP BY c.city_name, c.estimated_rent
ORDER BY profit_after_rent DESC;
	
--Q8. Top 3 Selling Product in each City.
SELECT
	*
FROM
	(
		SELECT
			CI.CITY_NAME,
			P.PRODUCT_NAME,
			COUNT(S.SALE_ID),
			DENSE_RANK() OVER (
				PARTITION BY
					CI.CITY_NAME
				ORDER BY
					COUNT(S.SALE_ID) DESC
			)
		FROM
			CITY CI
			JOIN CUSTOMERS C ON CI.CITY_ID = C.CITY_ID
			JOIN SALES S ON C.CUSTOMER_ID = S.CUSTOMER_ID
			JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			1,
			2
		ORDER BY
			1,
			3
	)
WHERE
	DENSE_RANK <= 3

--Q9. how many unique customer in each city who purchase coffee 
SELECT
	CI.CITY_NAME,
	COUNT(DISTINCT C.CUSTOMER_ID)
FROM
	CITY CI
	JOIN CUSTOMERS C ON CI.CITY_ID = C.CITY_ID
	JOIN SALES S ON C.CUSTOMER_ID = S.CUSTOMER_ID
	JOIN PRODUCTS P ON S.PRODUCT_ID = P.PRODUCT_ID
WHERE
	P.PRODUCT_ID IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)GROUP BY
	1
ORDER BY
	2 DESC

--Q10. Coffee Sales Trend(Day)
SELECT 
    TO_CHAR(s.sale_date, 'Day') AS day_name,
    COUNT(*) AS coffee_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
WHERE p.product_name ILIKE '%coffee%'
GROUP BY TO_CHAR(s.sale_date, 'Day')
ORDER BY coffee_sales
desc

--Q11. Coffee Sales Trend(Month)
SELECT 
    TO_CHAR(s.sale_date, 'Month') AS month_name,
    COUNT(*) AS coffee_sales
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city c ON cu.city_id = c.city_id
JOIN products p ON s.product_id = p.product_id
WHERE p.product_name ILIKE '%coffee%'
GROUP BY TO_CHAR(s.sale_date, 'Month')
ORDER BY month_name

--Q12. Avg Sale avg Rent per Customer
SELECT
	CITY.CITY_NAME,
	AVG_PER_CUSTOMER,
	(CITY.ESTIMATED_RENT / C) as est_rent
FROM
	(
		SELECT
			CI.CITY_NAME,
			COUNT(DISTINCT C.CUSTOMER_ID) AS C,
			SUM(TOTAL),
			SUM(TOTAL) / COUNT(DISTINCT C.CUSTOMER_ID) AS AVG_PER_CUSTOMER
		FROM
			SALES S
			JOIN CUSTOMERS C ON S.CUSTOMER_ID = C.CUSTOMER_ID
			JOIN CITY CI ON CI.CITY_ID = C.CITY_ID
		GROUP BY
			1
		ORDER BY
			3 DESC
	) AS CI
	JOIN CITY ON CI.CITY_NAME = CITY.CITY_NAME
	
