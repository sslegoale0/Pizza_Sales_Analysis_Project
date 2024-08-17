SET sql_safe_update = 0;

SET sql_mode = "Traditional";

/* ---------------------------------------------------------------------------------------------------------------------------- */

/* Pizza Sales Data Cleaning */

CREATE DATABASE pizza_sales;



USE pizza_sales;



SELECT *
FROM orders;



EXEC sp_columns orders;



/* 1. Removal of duplicate rows. */

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY pizza_id
ORDER BY pizza_id) AS row_num
FROM orders;

WITH duplicate_orders AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY pizza_id
ORDER BY pizza_id) AS row_num
FROM orders)
SELECT *
FROM duplicate_orders
WHERE row_num > 1;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
order_id,
pizza_name_id,
quantity,
order_date,
order_time,
unit_price,
total_price,
pizza_size,
pizza_category,
pizza_ingredients,
pizza_name
ORDER BY pizza_id) AS row_num
FROM orders;

WITH duplicate_orders AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
order_id,
pizza_name_id,
quantity,
order_date,
order_time,
unit_price,
total_price,
pizza_size,
pizza_category,
pizza_ingredients,
pizza_name
ORDER BY pizza_id) AS row_num
FROM orders)
SELECT *
FROM duplicate_orders
WHERE row_num > 1;



/* 2. Data formatting & standardisation. */

SELECT DISTINCT pizza_id
FROM orders
ORDER BY pizza_id;

ALTER TABLE orders
RENAME COLUMN pizza_id TO row_id;

SELECT DISTINCT row_id
FROM orders
ORDER BY row_id;



SELECT DISTINCT order_id
FROM orders
ORDER BY order_id;



SELECT DISTINCT pizza_name_id
FROM orders
ORDER BY pizza_name_id;



SELECT DISTINCT quantity
FROM orders
ORDER BY quantity;



SELECT DISTINCT order_date
FROM orders
ORDER BY order_date ASC;

SELECT DISTINCT order_date,
STR_TO_DATE(order_date, "%d-%m-%Y", "%Y-%m-%d")
FROM orders
ORDER BY order_date ASC;

UPDATE orders
SET order_date = STR_TO_DATE(order_date, "%d-%m-%Y", "%Y-%m-%d");

ALTER TABLE orders
MODIFY COLUMN order_date DATE;



SELECT DISTINCT order_time
FROM orders
ORDER BY order_time ASC;

SELECT order_date,
order_time,
CONCAT(order_date, ' ', order_time) AS order_datetime
FROM orders;

ALTER TABLE orders
ADD order_datetime DATETIME;

UPDATE orders
SET order_datetime = CONCAT(order_date, ' ', order_time);

SELECT order_date,
order_time,
order_datetime
FROM orders
ORDER BY order_datetime;



SELECT DISTINCT unit_price
FROM orders
ORDER BY unit_price;

ALTER TABLE orders
MODIFY COLUMN unit_price FLOAT;



SELECT DISTINCT total_price
FROM orders
ORDER BY total_price;

ALTER TABLE orders
MODIFY COLUMN total_price FLOAT;

SELECT DISTINCT total_price,
unit_price * quantity
FROM orders
WHERE total_price <> unit_price * quantity;



SELECT DISTINCT pizza_size
FROM orders
ORDER BY pizza_size;

SELECT DISTINCT RIGHT(pizza_name_id, 1),
pizza_size
FROM orders
WHERE pizza_size NOT IN ('XL', 'XXL');

SELECT DISTINCT RIGHT(pizza_name_id, 2),
pizza_size
FROM orders
WHERE pizza_size = 'XL';

SELECT DISTINCT RIGHT(pizza_name_id, 3),
pizza_size
FROM orders
WHERE pizza_size = 'XXL';



SELECT DISTINCT pizza_category
FROM orders
ORDER BY pizza_category;



SELECT DISTINCT pizza_ingredients
FROM orders
ORDER BY pizza_ingredients;

SELECT DISTINCT pizza_ingredients,
REPLACE(pizza_ingredients, '?duja', 'Nduja')
FROM orders
WHERE pizza_ingredients LIKE '?duja%';

UPDATE orders
SET pizza_ingredients = REPLACE(pizza_ingredients, '?duja', 'Nduja')
WHERE pizza_ingredients LIKE '?duja%';



SELECT DISTINCT pizza_name
FROM orders
ORDER BY pizza_name;

SELECT DISTINCT pizza_name,
pizza_name_id
FROM orders
ORDER BY pizza_name;



/* 3. Imputation of null/blank values. */

-- There are no blank or values in the dataset.



/* 4. Removal of irrelevant/redundant columns. */

-- There are no irrelevant or redundant columns in the dataset.



-----------------------------------------------------------------------------------------------------------------

/* Pizza Sales Data Analysis */

/* 1. Total Revenue by Month */

SELECT DATENAME(MONTH, order_date) AS "month",
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY MONTH(order_date), DATENAME(MONTH, order_date)
ORDER BY MONTH(order_date);



/* 2. Total Revenue by Weekday */

SELECT DATENAME(WEEKDAY, order_date) AS "weekday",
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY DATEPART(WEEKDAY, order_date), DATENAME(WEEKDAY, order_date)
ORDER BY DATEPART(WEEKDAY, order_date);



/* 3. Total Revenue by Hour */

SELECT DATENAME(HOUR, order_time) AS "hour",
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY DATEPART(HOUR, order_time), DATENAME(HOUR, order_time)
ORDER BY DATEPART(HOUR, order_time);



/* 4. Total Revenue by Pizza Name */

SELECT pizza_name,
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY pizza_name
ORDER BY pizza_name;



/* 5. Total Revenue by Pizza Size */

SELECT pizza_size,
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY pizza_size
ORDER BY pizza_size;



/* 6. Total Revenue by Pizza Category */

SELECT pizza_category,
ROUND(SUM(total_price), 0) AS total_revenue,
SUM(quantity) AS total_sales,
COUNT(DISTINCT order_id) AS total_orders,
ROUND(SUM(total_price)/COUNT(DISTINCT order_id), 2) AS "average order value",
ROUND(SUM(total_price)/SUM(quantity), 2) AS "average pizza price",
ROUND(SUM(quantity)/COUNT(DISTINCT order_id), 2) AS "average pizzas per order"
FROM orders
GROUP BY pizza_category
ORDER BY pizza_category;
