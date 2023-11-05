# EDA

-- Let's have a first view about our data
SELECT * 
FROM `sixth-oxygen-351515.global_superstore.orders` 
LIMIT 10;

-- Count number of rows
SELECT count(*) no_rows
FROM `sixth-oxygen-351515.global_superstore.orders`;

-- Understand my schema
SELECT column_name, data_type
FROM `sixth-oxygen-351515.global_superstore`.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'orders';

-- Statistics for numeric values
SELECT   
  COUNT(*) AS num_records,
  ROUND(AVG(Sales),2) AS avg_sales,
  MIN(Sales) AS min_sales,
  MAX(Sales) AS max_sales
FROM `sixth-oxygen-351515.global_superstore.orders` ;

-- Check for missing values
SELECT
  Order_ID,
  COUNT(*) AS missing_count
FROM `sixth-oxygen-351515.global_superstore.orders` 
WHERE Order_ID IS NULL
GROUP BY Order_ID;

-- Can the Order_ID be used as a PK? KO, Order_ID is not unique,
SELECT Order_ID, COUNT(*) no_rows
FROM `sixth-oxygen-351515.global_superstore.orders` 
GROUP BY 1
HAVING no_rows>1
ORDER BY no_rows DESC;

-- Can we use a combination of ids? 
SELECT row_id, order_id, COUNT(*) no_rows
FROM `sixth-oxygen-351515.global_superstore.orders` 
GROUP BY 1,2
HAVING no_rows>1;

-- Calculate the total sales
SELECT SUM(Sales) AS total_sales
FROM `sixth-oxygen-351515.global_superstore.orders`;

-- Find the top 10 products sold
SELECT product_name, SUM(Sales) AS total_sales
FROM `sixth-oxygen-351515.global_superstore.orders`
GROUP BY 1
ORDER BY total_sales desc
LIMIT 10;

-- Top 10 categories and subcategories by sales
WITH total_sales AS (
  SELECT SUM(Sales) AS total_sales
  FROM `sixth-oxygen-351515.global_superstore.orders`
), total_profit AS (
  SELECT SUM(Profit) AS total_profit
  FROM `sixth-oxygen-351515.global_superstore.orders`
)
SELECT category, sub_category, 
  SUM(Sales) AS total_sales, 
  ROUND(SUM(Sales) / s.total_sales * 100, 2) AS perc_of_sales,
  SUM(profit) AS total_profit,
  ROUND(SUM(profit) / p.total_profit * 100, 2) AS perc_of_profit,
  COUNT(*) AS count
FROM `sixth-oxygen-351515.global_superstore.orders`
CROSS JOIN total_sales s, total_profit p
GROUP BY 1, 2, s.total_sales, p.total_profit
ORDER BY total_sales DESC
LIMIT 10;

-- How many items are usually sold in each order?
WITH articles_per_order AS (
  SELECT Customer_ID, Order_ID, COUNT(Product_ID) no_articles
  FROM `sixth-oxygen-351515.global_superstore.orders` 
  GROUP BY 1,2
  ORDER BY 1
)
SELECT ROUND(AVG(no_articles),2) AS avg_art_per_order
FROM articles_per_order;

-- Explore sales trends over time
SELECT
  DATE_TRUNC(order_date, MONTH) AS month,
  SUM(sales) AS monthly_sales
FROM `sixth-oxygen-351515.global_superstore.orders` 
GROUP BY 1
ORDER BY 1;

-- Calculate the average profit margin
SELECT ROUND(AVG(profit / sales),2) AS avg_profit_margin
FROM `sixth-oxygen-351515.global_superstore.orders`;

-- Order by the best performing regions
SELECT region, SUM(sales) AS total_sales
FROM `sixth-oxygen-351515.global_superstore.orders`
GROUP BY region
ORDER BY total_sales DESC;

-- Do customers order multiple times?
WITH customers_and_orders AS
(
  SELECT Customer_ID, COUNT(DISTINCT Order_ID) no_orders
  FROM `sixth-oxygen-351515.global_superstore.orders` 
  GROUP BY 1
  ORDER BY 2 DESC
)
SELECT 
  CASE WHEN no_orders = 1 THEN 'first_contact'
  WHEN no_orders > 1 THEN 'regular_customer'
  ELSE 'review_query'
  END type_of_client,
  COUNT (Customer_ID) as no_customers
FROM customers_and_orders
GROUP BY 1
;

-- How many orders do customers usually do? 
WITH customers_and_orders AS
(
  SELECT Customer_ID, COUNT(DISTINCT Order_ID) no_orders
  FROM `sixth-oxygen-351515.global_superstore.orders` 
  GROUP BY 1
  ORDER BY 2 DESC
)
SELECT ROUND(AVG(no_orders),2) avg_no_orders, MAX(no_orders) max_no_orders
FROM customers_and_orders;

-- Most common customer segments
SELECT segment, COUNT(*) AS count
FROM `sixth-oxygen-351515.global_superstore.orders` 
GROUP BY segment
ORDER BY 2 desc;

-- Top customers by total spending
SELECT customer_name, SUM(sales) AS total_spending
FROM `sixth-oxygen-351515.global_superstore.orders` 
GROUP BY customer_name
ORDER BY total_spending DESC
LIMIT 10;

-- Which ship modes do we have and how it is distributed? 
SELECT ship_mode, COUNT(*) AS count
FROM `sixth-oxygen-351515.global_superstore.orders`
GROUP BY ship_mode;

-- Calculate the average shipping time
-- since the order is created, how long it takes to be shipped?
SELECT ROUND(AVG(DATE_DIFF(ship_date, order_date, DAY)),2) AS avg_shipping_time
FROM `sixth-oxygen-351515.global_superstore.orders`;

-- Quick check on the dates
SELECT COUNT(*) as invalid_dates
FROM`sixth-oxygen-351515.global_superstore.orders`
WHERE ship_date < order_date;
