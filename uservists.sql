CREATE TABLE user_visits (
    user_id INT,
    visit_date DATE
);


-- This statement inserts multiple rows of data into the 'user_visits' table.
-- Each set of parentheses represents a single row with values for 'user_id' and 'visit_date'.
-- The values correspond to the order of the columns specified after the table name.

INSERT INTO user_visits (user_id, visit_date) VALUES
(1, '2020-11-28'),
(1, '2020-10-20'),
(1, '2020-12-03'),
(2, '2020-10-05'),
(2, '2020-12-09'),
(3, '2020-11-11');


select * from user_visits;
with cte as(
select *,
lag(visit_date,1,'2021-01-01')over(partition by user_id order by visit_date desc) as lag_date ,
datediff(visit_date,lag(visit_date,1,'2021-01-01')over(partition by user_id order by visit_date desc))*-1 as diff
from
user_visits)
select user_id,max(diff) from cte group by user_id;