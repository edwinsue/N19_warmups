-- Get a list of the 3 long-standing customers for each country

SELECT 
*
FROM 
(SELECT 
RANK() OVER(PARTITION BY country ORDER BY first_order ASC),
*
FROM
(SELECT 
c.customerid,
c.companyname,
MIN(o.orderdate) AS first_order,
c.country
FROM customers c
INNER JOIN orders o ON c.customerid = o.customerid
GROUP BY c.customerid, c.companyname
ORDER BY country ASC) AS ranked) AS top_ranked
WHERE rank <= 3

-- Modify the previous query to get the 3 newest customers in each each country.

SELECT 
*
FROM 
(SELECT 
RANK() OVER(PARTITION BY country ORDER BY latest_order DESC),
*
FROM
(SELECT 
c.customerid,
c.companyname,
MAX(o.orderdate) AS latest_order,
c.country
FROM customers c
INNER JOIN orders o ON c.customerid = o.customerid
GROUP BY c.customerid, c.companyname
ORDER BY country ASC) AS ranked) AS top_ranked
WHERE rank <= 3

-- Get the 3 most frequently ordered products (ie. highest number of total units ordered within a country) in each city

WITH top_3 AS (
	WITH most_popular AS 
		(SELECT
		od.productid,
		p.productname,
		SUM(od.quantity) AS total_ordered,
		o.shipcountry
		FROM orders o 
		INNER JOIN orderdetails od ON od.orderid=o.orderid
		INNER JOIN products p ON p.productid=od.productid
		GROUP BY od.productid, p.productname, o.shipcountry
		ORDER BY o.shipcountry, total_ordered DESC)
	SELECT 
	ROW_NUMBER() OVER(PARTITION BY shipcountry ORDER BY total_ordered DESC) AS rank,
	*
	FROM most_popular )
SELECT * 
FROM top_3
WHERE rank <= 3
