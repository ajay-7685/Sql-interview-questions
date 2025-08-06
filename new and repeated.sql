-- Step 1: Select the database to use
USE flight_schedule_db;

-- Step 2: Create the 'orders' table
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    order_amount INT
);

-- Step 3: Insert sample data into the 'orders' table
INSERT INTO orders (order_id, customer_id, order_date, order_amount) VALUES
(1, 100, '2022-01-01', 2000),
(2, 200, '2022-01-01', 2500),
(3, 300, '2022-01-01', 2100),
(4, 100, '2022-01-02', 2000),
(5, 400, '2022-01-02', 2200),
(6, 500, '2022-01-02', 2700),
(7, 100, '2022-01-03', 1000),
(8, 400, '2022-01-03', 3000),
(9, 600, '2022-01-03', 3000);

-- View all data in the orders table
SELECT * FROM orders;

-- Step 4: Find the first order date for each customer
WITH first_order AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date 
    FROM 
        orders 
    GROUP BY 
        customer_id
)
-- Step 5: Join orders table with first_order to retrieve all orders for each customer's first order
SELECT 
    o.* 
FROM 
    orders AS o 
INNER JOIN 
    first_order AS fo 
    ON o.customer_id = fo.customer_id;

-- Step 6: Tag each order as 'new_customer' if it's the customer's first order, otherwise as 'repeated_customer'
WITH first_order AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM 
        orders
    GROUP BY 
        customer_id
),
visted AS (
    SELECT 
        o.*, 
        fo.first_order_date,
        -- If order_date is the same as first_order_date, it's a new customer's order
        CASE 
            WHEN o.order_date = fo.first_order_date THEN 1 
            ELSE 0 
        END AS new_customer,         
        -- Otherwise, it's a repeat customer order
        CASE 
            WHEN o.order_date != fo.first_order_date THEN 1 
            ELSE 0 
        END AS repeated_customer 
    FROM 
        first_order fo
    INNER JOIN  
        orders o ON o.customer_id = fo.customer_id
)

-- Step 7: For each date, count new and repeated customers' orders
SELECT 
    order_date,
    SUM(new_customer) AS ncc,          -- Number of new customer orders on that date
    SUM(repeated_customer) AS rpc      -- Number of repeated customer orders on that date
FROM 
    visted 
GROUP BY 
    order_date;
