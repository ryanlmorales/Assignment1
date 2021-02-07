-- Assignment1.sql

DROP TABLE IF EXISTS airlines;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS weather;

CREATE TABLE airlines (
  carrier varchar(2) PRIMARY KEY,
  name varchar(30) NOT NULL
  );
  
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/airlines.csv' 
INTO TABLE airlines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE airports (
  faa char(3),
  name varchar(100),
  lat double precision,
  lon double precision,
  alt integer,
  tz integer,
  dst char(1)
  );
  
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/airports.csv' 
INTO TABLE airports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE flights (
year integer,
month integer,
day integer,
dep_time integer,
dep_delay integer,
arr_time integer,
arr_delay integer,
carrier char(2),
tailnum char(6),
flight integer,
origin char(3),
dest char(3),
air_time integer,
distance integer,
hour integer,
minute integer
);

LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/flights.csv' 
INTO TABLE flights
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(year, month, day, @dep_time, @dep_delay, @arr_time, @arr_delay,
 @carrier, @tailnum, @flight, origin, dest, @air_time, @distance, @hour, @minute)
SET
dep_time = nullif(@dep_time,''),
dep_delay = nullif(@dep_delay,''),
arr_time = nullif(@arr_time,''),
arr_delay = nullif(@arr_delay,''),
carrier = nullif(@carrier,''),
tailnum = nullif(@tailnum,''),
flight = nullif(@flight,''),
air_time = nullif(@air_time,''),
distance = nullif(@distance,''),
hour = dep_time / 100,
minute = dep_time % 100
;

CREATE TABLE planes (
tailnum char(6),
year integer,
type varchar(50),
manufacturer varchar(50),
model varchar(50),
engines integer,
seats integer,
speed integer,
engine varchar(50)
);

LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/planes.csv' 
INTO TABLE planes
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(tailnum, @year, type, manufacturer, model, engines, seats, @speed, engine)
SET
year = nullif(@year,''),
speed = nullif(@speed,'')
;

CREATE TABLE weather (
origin char(3),
year integer,
month integer,
day integer,
hour integer,
temp double precision,
dewp double precision,
humid double precision,
wind_dir integer,
wind_speed double precision,
wind_gust double precision,
precip double precision,
pressure double precision,
visib double precision
);

LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/weather.csv' 
INTO TABLE weather
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(origin, @year, @month, @day, @hour, @temp, @dewp, @humid, @wind_dir,
@wind_speed, @wind_gust, @precip, @pressure, @visib)
SET
year = nullif(@year,''),
month = nullif(@month,''),
day = nullif(@day,''),
hour = nullif(@hour,''),
temp = nullif(@temp,''),
dewp = nullif(@dewp,''),
humid = nullif(@humid,''),
wind_dir = FORMAT(@wind_dir, 0),
wind_speed = nullif(@wind_speed,''),
wind_gust = nullif(@wind_gust,''),
precip = nullif(@precip,''),
pressure = nullif(@pressure,''),
visib = FORMAT(@visib,0)
;

SET SQL_SAFE_UPDATES = 0;
UPDATE planes SET engine = SUBSTRING(engine, 1, CHAR_LENGTH(engine)-1);

SELECT 'airlines', COUNT(*) FROM airlines
  UNION
SELECT 'airports', COUNT(*) FROM airports
  UNION
SELECT 'flights', COUNT(*) FROM flights
  UNION
SELECT 'planes', COUNT(*) FROM planes
  UNION
SELECT 'weather', COUNT(*) FROM weather;

-- Finding out how many flights have speeds which are listed--
SELECT planes.tailnum, planes.speed
from flights.planes
where planes.speed is not null;

-- Finding the count for planes which have speeds listed --                                                                                                                                  
SELECT COUNT(*)
from flights.planes
where planes.speed is not null;

-- Finding out the distance for all aircrafts in January 2013--

SELECT SUM(distance)
from flights.flights
where flights.month = 1;

-- -- Finding out the distance for all aircrafts and manufacturers in January 2013-- 
SELECT flights.month, flights.tailnum, planes.manufacturer, flights.distance 
from flights.flights
inner join flights.planes
on planes.tailnum = flights.tailnum
where flights.month = 1;

-- Creating a table for the total distance of January -- 

DROP TABLE IF EXISTS JanuaryDistance;

CREATE TABLE JanuaryDistance (
month integer,
tailnum char(6),
manufacturer varchar(50),
distance integer
);

-- Importing data into JanuaryDistance table -- 
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/JanuaryDistance.csv' 
INTO TABLE JanuaryDistance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Displaying Information from JanuaryDistance -- 
SELECT * from JanuaryDistance;

-- Calculating the total distance flown in January 2013 based off of Manufacturer --
SELECT JanuaryDistance.manufacturer, SUM(distance) AS Distance
from flights.JanuaryDistance
GROUP BY JanuaryDistance.manufacturer;

-- Calculating the total distance flown in January 2013 based off of tailnum --

SELECT JanuaryDistance.tailnum, SUM(distance) AS Distance
from flights.JanuaryDistance
GROUP BY JanuaryDistance.tailnum;

-- Finding out the distance for all aircrafts and manufacturers in January 2013 without a tailnum--
SELECT flights.month, flights.tailnum, flights.distance 
from flights.flights
where flights.month = 1;

-- Creating a table for the result of the previous statement -- 
DROP TABLE IF EXISTS NoTailNumDistance;

CREATE TABLE NoTailNumDistance (
month integer,
tailnum char(6),
distance integer
);

-- Importing data into NoTailNumDistance table -- 
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/NoTailNumDistance.csv' 
INTO TABLE NoTailNumDistance
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Displaying the contents of the NoTailNumDistance table -- 
SELECT * FROM NoTailNumDistance;

-- Calculating the total distance where the tailnum is missing -- 
SELECT NoTailNumDistance.tailnum, SUM(distance) AS Distance
from flights.NoTailNumDistance
GROUP BY NoTailNumDistance.tailnum
ORDER BY NoTailNumDistance.tailnum;

-- Finding the planes which have flown on July 5, 2013 Using the INNER JOIN-- 

SELECT flights.month, flights.day, flights.tailnum, planes.manufacturer, flights.distance 
from flights.flights
inner join flights.planes
on planes.tailnum = flights.tailnum
where flights.month = 7 and flights.day = 5;

-- Creating a table for the result of the previous statement -- 

DROP TABLE IF EXISTS July05_INNER;

CREATE TABLE July05_INNER (
month integer,
day integer,
tailnum char(6),
manufacturer varchar(50),
distance integer
);

-- Importing data into July05_INNER table -- 
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/July05_INNER.csv' 
INTO TABLE July05_INNER
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Displaying the contents of the July05_INNER table -- 

SELECT * FROM July05_INNER;

-- Calculating the total distance for the aircrafts flown on this date -- 
SELECT July05_INNER.manufacturer, SUM(distance) AS Distance
from flights.July05_INNER
GROUP BY July05_INNER.manufacturer
ORDER BY July05_INNER.manufacturer;

-- Finding the planes which have flown on July 5, 2013 Using the LEFT OUTER JOIN-- 

SELECT flights.month, flights.day, flights.tailnum, planes.manufacturer, flights.distance 
from flights.flights
LEFT OUTER JOIN flights.planes
on planes.tailnum = flights.tailnum
where flights.month = 7 and flights.day = 5;

-- Creating a table for the result of the previous statement -- 

DROP TABLE IF EXISTS July05_OUTER;

CREATE TABLE July05_OUTER (
month integer,
day integer,
tailnum char(6),
manufacturer varchar(50),
distance integer
);

-- Importing data into July05_OUTER table -- 
LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/July05_OUTER.csv' 
INTO TABLE July05_OUTER
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Displaying the contents of the July05_INNER table -- 

SELECT * FROM July05_OUTER;

-- Calculating the total distance for the aircrafts flown on this date -- 
SELECT July05_OUTER.manufacturer, SUM(distance) AS Distance
from flights.July05_OUTER
GROUP BY July05_OUTER.manufacturer
ORDER BY July05_OUTER.manufacturer;

-- Using the RIGHT and LEFT JOIN to find the total distance flown of all aicrafts in 2013 --
SELECT flights.month, flights.day, airlines.carrier, airlines.name, flights.tailnum, flights.distance, planes.manufacturer
FROM flights.airlines
LEFT JOIN flights.flights 
ON flights.carrier = airlines.carrier
RIGHT JOIN flights.planes
ON planes.tailnum = flights.tailnum
where flights.month = 9;

-- Creating a table for the result of the previous statement --
DROP TABLE IF EXISTS AirlineTotal;

CREATE TABLE AirlineTotal (
month integer,
day integer,
carrier varchar(2),
name varchar(30),
tailnum char(6),
distance integer,
manufacturer varchar(50)
);

LOAD DATA LOCAL INFILE '/home/rm14219072/Documents/Flights/AirlineTotal.csv' 
INTO TABLE AirlineTotal
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Displaying the contents of the ManufacturerTotal table --
SELECT * FROM AirlineTotal;

-- Calculating the total distance which has been flown -- 

SELECT AirlineTotal.name, SUM(distance) AS Distance
from flights.AirlineTotal
GROUP BY AirlineTotal.name
ORDER BY Distance;
