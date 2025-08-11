CREATE TABLE visits (
    name VARCHAR(10),
    address VARCHAR(100),
    email VARCHAR(100),
    floor INT,
    resources VARCHAR(100)
);
INSERT INTO visits (name, address, email, floor, resources) VALUES
('A', 'Bangalore', 'A@gmail.com', 1, 'CPU'),
('A', 'Bangalore', 'A1@gmail.com', 1, 'CPU'),
('A', 'Bangalore', 'A2@gmail.com', 2, 'DESKTOP'),
('B', 'Bangalore', 'B@gmail.com', 2, 'DESKTOP'),
('B', 'Bangalore', 'B1@gmail.com', 2, 'DESKTOP'),
('B', 'Bangalore', 'B2@gmail.com', 1, 'MONITOR');



-- Step 1: Get distinct combinations of name and resources from the visits table
WITH distinct_resources AS (
    SELECT DISTINCT name, resources FROM visits
),

-- Step 2: Aggregate all distinct resources used by each person into a comma-separated string
agg_resources AS (
    SELECT 
        name, 
        GROUP_CONCAT(resources) AS used_resources 
    FROM distinct_resources 
    GROUP BY name
),

-- Step 3: Count total visits and aggregate all resources (with possible duplicates) used by each person
total_visits AS (
    SELECT 
        name, 
        COUNT(1) AS total_visits, 
        GROUP_CONCAT(resources) AS resources_used 
    FROM visits 
    GROUP BY name
),

-- Step 4: Count number of visits per floor for each person and rank floors by visit count (most visited = rank 1)
floor_visit AS (
    SELECT 
        name,
        floor,
        COUNT(1) AS no_of_floor_visit,
        RANK() OVER (PARTITION BY name ORDER BY COUNT(1) DESC) AS rn
    FROM visits
    GROUP BY name, floor
)

-- Step 5: Final selection of results
-- Select each person's name, their most visited floor, total visits, and all distinct resources used
SELECT 
    fv.name, 
    fv.floor AS most_visited_floor,
    tv.total_visits,
    ar.used_resources
FROM floor_visit fv
JOIN total_visits tv ON fv.name = tv.name
JOIN agg_resources ar ON fv.name = ar.name
WHERE fv.rn = 1; -- Only include the most visited floor (rank = 1) for each person

