-- Create a new database called USSales
CREATE DATABASE USSales;

-- Switch to the USSales database
USE USSales;

-- View all records from the superstore table
SELECT * 
FROM superstore;

-- Get product sales per order with a row number (ID) for each order
SELECT 
    order_id,
    SUM(sales) AS product_sales,  -- Total sales per order
    ROW_NUMBER() OVER (ORDER BY order_id) AS id  -- Assign sequential ID based on order_id
FROM superstore
GROUP BY order_id;

-- CTE #1: Calculate total product sales per order
WITH order_wise_sales AS (
    SELECT 
        order_id,
        SUM(sales) AS product_sales
    FROM superstore
    GROUP BY order_id
),

-- CTE #2: Calculate running totals, total sales threshold, and assign IDs
cal_sales AS (
    SELECT 
        order_id,
        product_sales,
        
        -- Running total of sales in descending order of product_sales
        SUM(product_sales) OVER (
            ORDER BY product_sales DESC 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 0 PRECEDING
        ) AS running_total,
        
        -- 80% of total sales (Pareto principle threshold)
        0.8 * SUM(product_sales) OVER () AS total_sales,
        
        -- Sequential ID based on order_id
        ROW_NUMBER() OVER (ORDER BY order_id) AS id
    FROM order_wise_sales
)

-- Final selection: keep only those orders where cumulative sales 
-- are within 80% of total sales
SELECT *
FROM cal_sales
WHERE running_total <= total_sales;
