-- Table for people information
CREATE TABLE Persons (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    Score INT
);

INSERT INTO Persons (PersonID, Name, Email, Score) VALUES
(1, 'Alice', 'alice2018@hotmail.com', 88),
(2, 'Bob', 'bob2018@hotmail.com', 11),
(3, 'Davis', 'davis2018@hotmail.com', 27),
(4, 'Tara', 'tara2018@hotmail.com', 45),
(5, 'John', 'john2018@hotmail.com', 63);

-- Table for friendships
CREATE TABLE Friends (
    PersonID INT,
    FriendID INT,
    FOREIGN KEY (PersonID) REFERENCES Persons(PersonID),
    FOREIGN KEY (FriendID) REFERENCES Persons(PersonID)
);

INSERT INTO Friends (PersonID, FriendID) VALUES
(1, 2),
(2, 1),
(2, 3),
(3, 1),
(3, 4),
(4, 5),
(4, 3),
(5, 4);


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

