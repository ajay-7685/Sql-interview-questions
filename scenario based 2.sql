-- Step 1: Create a CTE to calculate each person's total friends' score and number of friends
WITH score_details AS (
    SELECT 
        f.personid,                           -- The person whose friends we are calculating for
        SUM(p.score) AS total_friend_score,   -- Sum of all friends' scores
        COUNT(1) AS no_of_friends              -- Count of how many friends they have
    FROM friend f
    INNER JOIN person p                       -- Join to get friend's score from the person table
        ON f.friendid = p.personid
    GROUP BY f.personid                       -- Group by person to aggregate friends' data
    HAVING SUM(p.score) > 100                  -- Only include people whose friends' total score > 100
)

-- Step 2: Join the aggregated friend data back with the person table to get their names
SELECT 
    s.personid,        -- Person ID
    p.name AS person_name,  -- Person's name
    s.no_of_friends,   -- Number of friends they have
    s.total_friend_score  -- Sum of their friends' scores
FROM person p
INNER JOIN score_details s 
    ON p.personid = s.personid;  -- Match the aggregated friend score data to the correct person
