use retail_orders;
select * from df_orders;
drop table df_orders;
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(50),
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2),
    quantity INT,
    discount_percent DECIMAL(5,2),
    discount DECIMAL(10,2),
    sale_price DECIMAL(10,2),
    profit DECIMAL(10,2)
);

select * from df_orders;

-- Which are the top 10 products that generated the highest revenue?
SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;
-- What are the top 5 highest selling products in each region?
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT region, product_id, sales
FROM (
    SELECT region, product_id, sales,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;

-- How do sales in each month of 2022 compare with the same month in 2023?
with cte as (
    select year(order_date) as order_year,
           month(order_date) as order_month,
           sum(sale_price) as sales
    from df_orders
    group by year(order_date), month(order_date)
)
select order_month,
       sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
       sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;
-- For each category, which month recorded the highest sales?
WITH cte AS (
    SELECT category,
           DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
)
SELECT category, order_year_month, sales
FROM (
select category, order_year_month, sales,
row_number()over(partition by category order by sales) as rn from cte
) A where rn=1;

-- Which sub-category experienced the highest sales growth from 2022 to 2023?
WITH cte AS (
    SELECT sub_category,
           YEAR(order_date) AS order_year,
           SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT sub_category, sales_2022, sales_2023,
       (sales_2023 - sales_2022) AS growth
FROM cte2
ORDER BY growth DESC
LIMIT 1;