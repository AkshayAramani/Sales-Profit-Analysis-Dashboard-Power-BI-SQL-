-- ===============================
-- DATABASE & TABLE SETUP
-- ===============================

CREATE DATABASE superstore_db;
USE superstore_db;

CREATE TABLE superstore_data (
    row_id INT,
    order_id VARCHAR(50),
    order_date TEXT,
    ship_date TEXT,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    `year_month` VARCHAR(10),
    delivery_days INT
);

-- ===============================
-- DATA CLEANING (IMPORTANT)
-- ===============================

-- Convert order_date to DATE format
UPDATE superstore_data
SET order_date = STR_TO_DATE(order_date, '%d-%m-%y');

ALTER TABLE superstore_data
MODIFY order_date DATE;

-- Convert ship_date to DATE format
UPDATE superstore_data
SET ship_date = STR_TO_DATE(ship_date, '%d-%m-%Y');

ALTER TABLE superstore_data
MODIFY ship_date DATE;
-- ===============================
-- BASIC BUSINESS QUERIES
-- ===============================

-- Total Sales
SELECT SUM(sales) AS total_sales
FROM superstore_data;

-- Sales by Category
SELECT category, SUM(sales) AS total_sales
FROM superstore_data
GROUP BY category
ORDER BY total_sales DESC;

-- Lowest Profit Sub-Category
SELECT sub_category, SUM(profit) AS total_profit
FROM superstore_data
GROUP BY sub_category
ORDER BY total_profit ASC
LIMIT 1;

-- Top 5 Customers by Sales
SELECT customer_name, SUM(sales) AS total_sales
FROM superstore_data
GROUP BY customer_name
ORDER BY total_sales DESC
LIMIT 5;

-- Region with Highest Profit
SELECT region, SUM(profit) AS total_profit
FROM superstore_data
GROUP BY region
ORDER BY total_profit DESC
LIMIT 1;

-- Average Delivery Days by Ship Mode
SELECT ship_mode, AVG(delivery_days) AS avg_delivery_days
FROM superstore_data
GROUP BY ship_mode;

-- ===============================
-- BUSINESS INSIGHT QUERIES
-- ===============================

-- Impact of Discount on Profit
SELECT discount,
       COUNT(*) AS total_orders,
       SUM(profit) AS total_profit,
       AVG(profit) AS avg_profit
FROM superstore_data
GROUP BY discount
ORDER BY discount;

-- High Sales but Low Profit Sub-Categories
SELECT sub_category,
       SUM(sales) AS total_sales,
       SUM(profit) AS total_profit
FROM superstore_data
GROUP BY sub_category
ORDER BY total_profit ASC;

-- Monthly Sales Trend
SELECT MONTH(order_date) AS month,
       SUM(sales) AS total_sales
FROM superstore_data
GROUP BY month
ORDER BY month;

-- ===============================
-- ADVANCED SQL (WINDOW FUNCTIONS)
-- ===============================

-- Top 3 Customers in Each Region
SELECT *
FROM (
    SELECT customer_name,
           region,
           SUM(sales) AS total_sales,
           RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rnk
    FROM superstore_data
    GROUP BY customer_name, region
) t
WHERE rnk <= 3;

-- Running Total of Sales (by Date)
SELECT order_date,
       SUM(sales) AS daily_sales,
       SUM(SUM(sales)) OVER (ORDER BY order_date) AS running_total
FROM superstore_data
GROUP BY order_date;

-- Previous Order Sales (LAG)
SELECT order_id,
       sales,
       LAG(sales, 1) OVER (ORDER BY order_date) AS previous_sales,
       sales - LAG(sales, 1) OVER (ORDER BY order_date) AS difference
FROM superstore_data;

-- Rank Sub-Categories by Profit within Category
SELECT category,
       sub_category,
       SUM(profit) AS total_profit,
       RANK() OVER (PARTITION BY category ORDER BY SUM(profit) DESC) AS rnk
FROM superstore_data
GROUP BY category, sub_category;

-- ===============================
-- ADVANCED BUSINESS METRICS
-- ===============================

-- Percentage Contribution of Each Region
SELECT region,
       SUM(sales) AS total_sales,
       ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 2) AS percentage_contribution
FROM superstore_data
GROUP BY region;

-- Find 2nd Highest Sales Value
SELECT MAX(sales) AS second_highest_sales
FROM superstore_data
WHERE sales < (SELECT MAX(sales) FROM superstore_data);

-- Customers with Sales Above Average
SELECT customer_name, sales
FROM superstore_data
WHERE sales > (SELECT AVG(sales) FROM superstore_data);

-- Duplicate Customers
SELECT customer_name, COUNT(*) AS total_orders
FROM superstore_data
GROUP BY customer_name
HAVING COUNT(*) > 1;
