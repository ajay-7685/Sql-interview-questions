-- =========================
-- Create the ORDERS table
-- =========================
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    item_id INT,
    buyer_id INT,
    seller_id INT
);

-- Insert sample data into orders
INSERT INTO orders (order_id, order_date, item_id, buyer_id, seller_id) VALUES
(1, '2019-08-01', 1, 1, 3),
(2, '2019-08-02', 2, 3, 1),
(3, '2019-08-03', 3, 2, 1),
(4, '2019-08-04', 1, 4, 2),
(5, '2019-08-04', 2, 2, 4),
(6, '2019-08-05', 4, 1, 4);

-- =========================
-- Create the USERS table
-- (renamed as users4 here)
-- =========================
CREATE TABLE users4 (
    user_id INT,
    join_date DATE,
    favorite_brand VARCHAR(50)
);

-- Insert sample data into users4
INSERT INTO users4 (user_id, join_date, favorite_brand) VALUES
(1, '2019-01-01', 'Lenovo'),
(2, '2019-02-09', 'Samsung'),
(3, '2019-01-19', 'LG'),
(4, '2019-05-21', 'HP');

-- =========================
-- Create the ITEMS table
-- =========================
CREATE TABLE items (
    item_id INT,
    item_brand VARCHAR(50)
);

-- Insert sample data into items
INSERT INTO items (item_id, item_brand) VALUES
(1, 'Samsung'),
(2, 'Lenovo'),
(3, 'LG'),
(4, 'HP');

-- =========================
-- Check the data inserted
-- =========================
SELECT * FROM orders;
SELECT * FROM users4;
SELECT * FROM items;

-- =========================================================
-- Query 1: Get the 2nd item sold by each seller
-- Using RANK() partitioned by seller_id and ordered by date
-- =========================================================
WITH ranked_orders AS (
    SELECT 
        o.*,
        RANK() OVER (PARTITION BY seller_id ORDER BY order_date) AS rnk
    FROM orders o
)
SELECT 
    ro.*,           -- all order details
    i.item_brand,   -- brand of the item sold
    u.favorite_brand -- seller’s favorite brand
FROM ranked_orders ro
INNER JOIN items i ON ro.item_id = i.item_id
INNER JOIN users4 u ON ro.seller_id = u.user_id
WHERE ro.rnk = 2;   -- pick only the 2nd item for each seller

-- =========================================================
-- Query 2: Show all sellers (even those with < 2 items)
-- LEFT JOIN ensures sellers with no 2nd sale still appear
-- Add a YES/NO check if 2nd item brand matches favorite
-- =========================================================
WITH ranked_orders AS (
    SELECT 
        o.*,
        RANK() OVER (PARTITION BY seller_id ORDER BY order_date) AS rnk
    FROM orders o
)
SELECT 
    ro.*,                        -- all order details for 2nd sale
    u.user_id,                   -- seller ID
    i.item_brand,                 -- item brand for 2nd sale
    u.favorite_brand,             -- seller’s favorite brand
    CASE 
        WHEN i.item_brand = u.favorite_brand THEN 'yes'
        ELSE 'no'
    END AS item_fav_brand         -- comparison result
FROM users4 u
LEFT JOIN ranked_orders ro 
    ON ro.seller_id = u.user_id AND rnk = 2  -- only 2nd sale
LEFT JOIN items i 
    ON ro.item_id = i.item_id;

-- =========================================================
-- Query 3: Simplified output
-- For each seller, show only YES/NO
-- If seller has < 2 sales, still included (LEFT JOIN)
-- =========================================================
WITH ranked_orders AS (
    SELECT 
        o.*,
        RANK() OVER (PARTITION BY seller_id ORDER BY order_date) AS rnk
    FROM orders o
)
SELECT 
    u.user_id AS seller_id,       -- seller
    CASE 
        WHEN i.item_brand = u.favorite_brand THEN 'yes'
        ELSE 'no'
    END AS item_fav_brand         -- check if 2nd sale matches favorite
FROM users4 u
LEFT JOIN ranked_orders ro  
    ON ro.seller_id = u.user_id AND rnk = 2
LEFT JOIN items i 
    ON ro.item_id = i.item_id;
