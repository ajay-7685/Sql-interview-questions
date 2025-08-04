-- ========================================
-- STEP 1: Select the database to use
-- ========================================
USE flight_schedule_db;

-- ========================================
-- STEP 2: Create the 'polls' table
-- Stores each user's vote, their chosen option, amount, and date.
-- ========================================
CREATE TABLE polls
(
  user_id VARCHAR(4),
  poll_id VARCHAR(3),
  poll_option_id VARCHAR(3),
  amount INT,
  created_date DATE
);

-- ========================================
-- STEP 3: Insert sample data into 'polls'
-- Simulates users voting for different options with different amounts.
-- ========================================
INSERT INTO polls (user_id, poll_id, poll_option_id, amount, created_date) VALUES
('id1', 'p1', 'A', 200, '2021-12-01'),
('id2', 'p1', 'C', 250, '2021-12-01'),
('id3', 'p1', 'A', 200, '2021-12-01'),
('id4', 'p1', 'B', 500, '2021-12-01'),
('id5', 'p1', 'C', 50, '2021-12-01'),
('id6', 'p1', 'D', 500, '2021-12-01'),
('id7', 'p1', 'C', 200, '2021-12-01'),
('id8', 'p1', 'A', 100, '2021-12-01'),
('id9', 'p2', 'A', 300, '2023-01-10'),
('id10', 'p2', 'C', 400, '2023-01-11'),
('id11', 'p2', 'B', 250, '2023-01-12'),
('id12', 'p2', 'D', 600, '2023-01-13'),
('id13', 'p2', 'C', 150, '2023-01-14'),
('id14', 'p2', 'A', 100, '2023-01-15'),
('id15', 'p2', 'C', 200, '2023-01-16');

-- ========================================
-- STEP 4: View all records in 'polls'
-- ========================================
SELECT * FROM polls;

-- ========================================
-- STEP 5: Create the 'poll_answers' table
-- Stores the correct answer for each poll.
-- ========================================
CREATE TABLE poll_answers
(
  poll_id VARCHAR(3),
  correct_option_id VARCHAR(3)
);

-- ========================================
-- STEP 6: Insert sample data into 'poll_answers'
-- Defines the correct option for each poll.
-- ========================================
INSERT INTO poll_answers (poll_id, correct_option_id) VALUES
('p1', 'C'),
('p2', 'A');

-- ========================================
-- STEP 7: View all records in 'poll_answers'
-- ========================================
SELECT * FROM poll_answers;

-- ========================================
-- STEP 8: Check total amount for wrong answers
-- Join polls with poll_answers and sum the amount where user chose the wrong option.
-- ========================================
WITH cte_wrong AS (
  SELECT 
    pp1.user_id,
    pp1.poll_id,
    pp1.poll_option_id,
    pp1.amount,
    pp2.correct_option_id
  FROM polls AS pp1
  JOIN poll_answers AS pp2 
    ON pp1.poll_id = pp2.poll_id
)
SELECT 
  poll_id, 
  SUM(amount) AS wrong_answer_total
FROM cte_wrong 
WHERE poll_option_id != correct_option_id 
GROUP BY poll_id;

-- ========================================
-- STEP 9: Check the full joined data
-- Shows each vote with its correct option for reference.
-- ========================================
SELECT 
  pp1.user_id,
  pp1.poll_id,
  pp1.poll_option_id,
  pp1.amount,
  pp1.created_date,
  pp2.correct_option_id
FROM polls AS pp1 
JOIN poll_answers AS pp2 
  ON pp1.poll_id = pp2.poll_id;

-- ========================================
-- STEP 10: Calculate proportional share for correct voters
-- For each user who chose the correct option:
--   - Calculate total correct pool and total wrong pool for that poll
--   - Distribute the wrong pool proportionally to correct voters
-- ========================================
WITH cte AS (
  SELECT 
    pp1.user_id,
    pp1.poll_id,
    pp1.amount,
    pp1.poll_option_id,
    pp2.correct_option_id
  FROM polls AS pp1
  JOIN poll_answers AS pp2 
    ON pp1.poll_id = pp2.poll_id
),

summary AS (
  SELECT
    poll_id,
    SUM(CASE WHEN poll_option_id = correct_option_id THEN amount ELSE 0 END) AS correct_sum,
    SUM(CASE WHEN poll_option_id != correct_option_id THEN amount ELSE 0 END) AS wrong_sum
  FROM cte
  GROUP BY poll_id
)

SELECT
  cte.user_id,
  cte.poll_id,
  cte.amount AS user_correct_amount,
  summary.correct_sum,
  summary.wrong_sum,
  ROUND(cte.amount / summary.correct_sum * summary.wrong_sum, 2) AS user_share
FROM cte
JOIN summary
  ON cte.poll_id = summary.poll_id
WHERE cte.poll_option_id = cte.correct_option_id;
