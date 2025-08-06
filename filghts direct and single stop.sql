CREATE DATABASE flight_schedule_db;


-- 2. Use the new database
USE flight_schedule_db;

-- 3. Create the ports table
CREATE TABLE ports (
    port_code VARCHAR(10) PRIMARY KEY,
    city_name VARCHAR(100)
);

-- 4. Insert values into ports
INSERT INTO ports (port_code, city_name) VALUES
('EWR', 'New York'),
('HND', 'Tokyo'),
('JFK', 'New York'),
('KIX', 'Osaka'),
('LAX', 'Los Angeles'),
('LGA', 'New York'),
('NRT', 'Tokyo'),
('ORD', 'Chicago'),
('SFO', 'San Francisco');

-- 5. Create the flights table
CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    start_port VARCHAR(10),
    end_port VARCHAR(10),
    start_time DATETIME,
    end_time DATETIME,
    FOREIGN KEY (start_port) REFERENCES ports(port_code),
    FOREIGN KEY (end_port) REFERENCES ports(port_code)
);

-- 6. Insert values into flights
INSERT INTO flights (flight_id, start_port, end_port, start_time, end_time) VALUES
(1, 'JFK', 'HND', '2025-06-15 06:00:00.000', '2025-06-15 18:00:00.000'),
(2, 'JFK', 'LAX', '2025-06-15 07:00:00.000', '2025-06-15 10:00:00.000'),
(3, 'LAX', 'NRT', '2025-06-15 10:00:00.000', '2025-06-15 22:00:00.000'),
(4, 'JFK', 'LAX', '2025-06-15 08:00:00.000', '2025-06-15 11:00:00.000'),
(5, 'LAX', 'KIX', '2025-06-15 11:30:00.000', '2025-06-15 22:00:00.000'),
(6, 'LGA', 'ORD', '2025-06-15 09:00:00.000', '2025-06-15 11:00:00.000'),
(7, 'ORD', 'HND', '2025-06-15 11:30:00.000', '2025-06-15 23:30:00.000'),
(8, 'EWR', 'SFO', '2025-06-15 09:00:00.000', '2025-06-15 13:00:00.000'),
(9, 'LAX', 'HND', '2025-06-15 13:00:00.000', '2025-06-15 23:00:00.000'),
(10, 'KIX', 'NRT', '2025-06-15 08:00:00.000', '2025-06-15 10:00:00.000');

select * from ports;
select * from flights;


with flight_details as(
SELECT 
    f.flight_id,
    f.start_port,
    sp.city_name AS start_city,
    f.end_port,
    ep.city_name AS end_city,
    f.start_time,
    f.end_time
FROM 
    flights AS f
INNER JOIN ports AS sp ON f.start_port = sp.port_code
INNER JOIN ports AS ep ON f.end_port = ep.port_code
)
,direct as(
select start_city,null as middle_city,end_city,flight_id,TIMESTAMPDIFF(MINUTE, start_time, end_time) AS time_taken from flight_details where start_city="New York" and end_city="Tokyo"
)
select a.start_city as trip_start_city,a.end_city as middle_city,b.end_city as trip_end_city,concat(a.flight_id,";",b.flight_id) as flight_id,
timestampdiff(MINUTE,a.start_time,b.end_time) as time_taken  from
(select *   from flight_details where start_city="New York") as a 

inner join 

(select *  from flight_details where end_city="Tokyo" ) as b

on a.end_city=b.start_city
where b.start_time>=a.end_time

union all

select * from direct;


-- optimized
with flight_details as(
SELECT 
    f.flight_id,
    f.start_port,
    sp.city_name AS start_city,
    f.end_port,
    ep.city_name AS end_city,
    f.start_time,
    f.end_time
FROM 
    flights AS f
INNER JOIN ports AS sp ON f.start_port = sp.port_code
INNER JOIN ports AS ep ON f.end_port = ep.port_code
)
,direct as(
select start_city,null as middle_city,end_city,flight_id,TIMESTAMPDIFF(MINUTE, start_time, end_time) AS time_taken from flight_details where start_city="New York" and end_city="Tokyo"
)
select a.start_city as trip_start_city,a.end_city as middle_city,b.end_city as trip_end_city,concat(a.flight_id,";",b.flight_id) as flight_id,
timestampdiff(MINUTE,a.start_time,b.end_time) as time_taken  from
flight_details  as a inner join 
flight_details  b on a.end_city=b.start_city
and a.start_city="new York" and b.end_city="Tokyo" where b.start_time>=a.end_time
union all
select * from direct;