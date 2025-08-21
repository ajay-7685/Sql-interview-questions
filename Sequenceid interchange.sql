

CREATE TABLE Products1 (
    ProductID INT PRIMARY KEY,
    Product VARCHAR(255),
    Category VARCHAR(100)
);

INSERT INTO Products1 (ProductID, Product, Category)
VALUES
    (1, 'Laptop', 'Electronics'),
    (2, 'Smartphone', 'Electronics'),
    (3, 'Tablet', 'Electronics'),
    (4, 'Headphones', 'Accessories'),
    (5, 'Smartwatch', 'Accessories'),
    (6, 'Keyboard', 'Accessories'),
    (7, 'Mouse', 'Accessories'),
    (8, 'Monitor', 'Accessories'),
    (9, 'Printer', 'Electronics');
    
select * from Products1;
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY ProductID) AS rn1,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY ProductID DESC) AS rn2
    FROM Products1
)
SELECT a.Category,
       a.Product,
       a.ProductID 
FROM cte a
INNER JOIN cte b 
    ON a.Category = b.Category   -- fixed typo (was cateogry)
   AND a.rn1 = b.rn2;



CREATE TABLE user_visits (
    user_id INT,
    visit_date DATE
);
