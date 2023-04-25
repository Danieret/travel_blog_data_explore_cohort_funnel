-- TRAVEL BLOG


CREATE TABLE first_time_readers (
my_date TEXT,
event_type TEXT,
country TEXT,
user_id BIGINT,
source TEXT,
continent TEXT);

COMMIT;

COPY first_time_readers FROM '/home/dataguy88/dilan_travel_guide/first_time_readers.csv' DELIMITER ';';

COMMIT;

SELECT * FROM first_time_readers LIMIT 10;

--------------------------------------------


CREATE TABLE returning_readers (
my_date TEXT,
event_type TEXT,
country TEXT,
user_id BIGINT,
continent TEXT);

COMMIT;


COPY returning_readers FROM '/home/dataguy88/dilan_travel_guide/returning_readers.csv' DELIMITER ';';


COMMIT;

SELECT * FROM returning_readers LIMIT 10;

-----------------------------------------------

CREATE TABLE subscribers (
my_date TEXT,
event_type TEXT,
user_id BIGINT);


COMMIT;


COPY subscribers FROM '/home/dataguy88/dilan_travel_guide/subscribers.csv' DELIMITER ';';


COMMIT;

SELECT * FROM subscribers LIMIT 10;
-----------------------------------

CREATE TABLE purchases (
my_date TEXT,
event_type TEXT,
user_id BIGINT,
paid INT);


COMMIT;


COPY purchases FROM '/home/dataguy88/dilan_travel_guide/purchases.csv' DELIMITER ';';


COMMIT;

SELECT * FROM purchases LIMIT 10;

------------------------------------------------





SELECT * FROM first_time_readers LIMIT 10;
SELECT * FROM returning_readers LIMIT 10;
SELECT * FROM subscribers LIMIT 10;
SELECT * FROM purchases LIMIT 10;


-- Dilan's want to focus only for one country!

-- first_time_readers segmentation : country, source, continent
SELECT COUNT (*) FROM first_time_readers; -- 210023

SELECT DATE(my_date), COUNT(*)
FROM first_time_readers
GROUP BY DATE(my_date)
ORDER BY DATE(first_time_readers.my_date);-- 1795 to 3013


SELECT country, COUNT(*) FROM first_time_readers GROUP BY country ORDER BY COUNT DESC; -- country_7	51791, country_2	50675, country_5	40349

SELECT source, COUNT(*) FROM first_time_readers GROUP BY source ORDER BY COUNT DESC; -- Reddit	105216, AdWords	63065, SEO	41742

SELECT continent, COUNT(*) FROM first_time_readers GROUP BY continent ORDER BY COUNT DESC; -- Asia	76092, Europe	39561, North America	37567

SELECT source, continent, country, COUNT(*) FROM first_time_readers GROUP BY source, continent, country ORDER BY COUNT DESC; -- Reddit	Asia	country_7	12950, Reddit	Asia	country_2	12857, Reddit	Asia	country_5	10065



-- returning_readers explore : country, source, continent
SELECT COUNT (*) FROM returning_readers; -- 371854

SELECT COUNT(DISTINCT returning_readers.user_id) FROM returning_readers; -- 66231 !!!

SELECT DATE(my_date), COUNT(*)
FROM returning_readers
GROUP BY DATE(my_date)
ORDER BY DATE(my_date); -- growing tendenci until the last day? 20180331 - 132? (not a completed day just 5 hours)

SELECT country, COUNT (*) FROM returning_readers GROUP BY country ORDER BY COUNT DESC ; -- country_5	109383, country_7	80276, country_2	79401

SELECT continent, COUNT (*) FROM returning_readers GROUP BY continent ORDER BY COUNT DESC ; --Asia	118833, North America	92767, Europe	54136, South America	51706

SELECT continent, country, COUNT (*) FROM returning_readers GROUP BY continent, country ORDER BY COUNT DESC ; -- Asia	country_5	35316, North America country_5	26660, Asia	country_2	25406, Asia	country_7	25399


-- SELECT * FROM first_time_readers JOIN returning_readers ON first_time_readers.user_id = returning_readers.user_id LIMIT 10;
-- SELECT DISTINCT returning_readers.user_id FROM first_time_readers JOIN returning_readers ON first_time_readers.user_id = returning_readers.user_id LIMIT 10;

-- returning readers comes from Reddit and SEO....from country...
SELECT source,
       country,
       COUNT(*)
FROM (SELECT DISTINCT returning_readers.user_id,
             first_time_readers.source,
             returning_readers.country
      FROM first_time_readers
        JOIN returning_readers ON first_time_readers.user_id = returning_readers.user_id) AS original_query
GROUP BY source, country
ORDER BY COUNT DESC; -- Reddit	country_5	9154, Reddit	country_7	7005, Reddit	country_2	6965, SEO	country_5	6420, SEO	country_7	5828, SEO	country_2	5723

-- from country 5,7...
SELECT country,
       COUNT(*)
FROM (SELECT DISTINCT returning_readers.user_id,
             returning_readers.country
      FROM first_time_readers
        JOIN returning_readers ON first_time_readers.user_id = returning_readers.user_id) AS original_query
GROUP BY country
ORDER BY COUNT DESC; -- country_5	19477, country_7	14417, country_2	14269, country_4	10167



-- subscribers: 

SELECT COUNT(*) FROM subscribers LIMIT 10; -- 7618 subscriber

SELECT continent, COUNT(*)
FROM first_time_readers
JOIN subscribers ON first_time_readers.user_id = subscribers.user_id GROUP BY continent ORDER BY COUNT DESC; -- subscribers first time visit was : Asia	4364, North America	1717, Europe	1033



SELECT *
FROM first_time_readers
JOIN subscribers ON first_time_readers.user_id = subscribers.user_id LIMIT 10;




SELECT DATE(first_time_readers.my_date), COUNT(*)
FROM first_time_readers
JOIN subscribers ON first_time_readers.user_id = subscribers.user_id
GROUP BY DATE(first_time_readers.my_date)
ORDER BY DATE(first_time_readers.my_date); -- Drastically decreasing subscriber count !!! last date is 2018 03 24


SELECT DATE(first_time_readers.my_date),first_time_readers.country, COUNT(*)
FROM first_time_readers
JOIN subscribers ON first_time_readers.user_id = subscribers.user_id
GROUP BY DATE(first_time_readers.my_date), first_time_readers.country
ORDER BY DATE(first_time_readers.my_date);


-- income 92.83% comes from subscribers
SELECT SUM(purchases.paid) FROM purchases RIGHT JOIN subscribers ON purchases.user_id = subscribers.user_id; --180544 dollars (full income : 194480 dollars )

-- subscribers income per day
SELECT DATE(purchases.my_date), SUM(purchases.paid) 
FROM purchases 
RIGHT JOIN subscribers ON purchases.user_id = subscribers.user_id 
GROUP BY DATE(purchases.my_date)
ORDER BY DATE(purchases.my_date);


-- purchases
SELECT * FROM purchases LIMIT 10;

SELECT COUNT(*) FROM purchases LIMIT 10; --8407

SELECT SUM(paid) FROM purchases LIMIT 10; --194480 dollars

SELECT SUM(paid) FROM purchases WHERE paid = 80 LIMIT 10; --141360 dollars from video course

SELECT SUM(paid) FROM purchases WHERE paid = 8 LIMIT 10; -- 53120 dollars from ebook

SELECT DATE (my_date),
       SUM(paid)
FROM purchases
GROUP BY DATE (my_date)
ORDER BY DATE (my_date); -- income per day (last day is also a full day 2018-03-30	1088 dollars 6 weeks deepest point)

SELECT DATE (my_date),
       SUM(paid)
FROM purchases
WHERE paid = 80
GROUP BY DATE (my_date)
ORDER BY DATE (my_date); -- daily income from video courses

SELECT DATE (my_date),
       SUM(paid)
FROM purchases
WHERE paid = 8
GROUP BY DATE (my_date)
ORDER BY DATE (my_date); -- daily income from ebook

---


SELECT first_time_readers.source, SUM(purchases.paid)
FROM first_time_readers
JOIN purchases ON first_time_readers.user_id = purchases.user_id
GROUP BY first_time_readers.source
ORDER BY SUM DESC; -- Reddit	89760, SEO	77056, AdWords	27664



SELECT first_time_readers.source, first_time_readers.country, SUM(purchases.paid)
FROM first_time_readers
JOIN purchases ON first_time_readers.user_id = purchases.user_id
GROUP BY first_time_readers.source, first_time_readers.country
ORDER BY SUM DESC; -- REDDIT SEO country 5,2,7


SELECT first_time_readers.continent, SUM(purchases.paid)
FROM first_time_readers
JOIN purchases ON first_time_readers.user_id = purchases.user_id
GROUP BY first_time_readers.continent
ORDER BY SUM DESC; -- Asia	112080, North America	43888

-----




--- costumers purchases and their registration day

SELECT DATE(first_time_readers.my_date), SUM(purchases.paid)
FROM first_time_readers
JOIN purchases ON first_time_readers.user_id = purchases.user_id
GROUP BY DATE(first_time_readers.my_date)
ORDER BY DATE(first_time_readers.my_date);
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--- What are the KPIs for this business? (We currently have no daily log files, so we will leave this question for now.)





---- FUNNEL ANALYSIS:
SELECT DATE (first_time_readers.my_date),
       continent,
       source,
       country,
       COUNT(user_id) AS first_time_readers,
       COUNT(CASE WHEN user_id IN (SELECT DISTINCT (user_id) FROM returning_readers) THEN user_id END)AS returnin_readers,
       COUNT(CASE WHEN user_id IN (SELECT user_id FROM subscribers) THEN user_id END) AS subscribers,
       COUNT(CASE WHEN user_id IN (SELECT DISTINCT (user_id) FROM purchases) THEN user_id END) AS customers
FROM first_time_readers
GROUP BY DATE (first_time_readers.my_date),
         continent,
         source,
         country
ORDER BY DATE (first_time_readers.my_date);




SELECT * FROM first_time_readers LIMIT 10;





-- Understanding extreme highs and lows

-- (no extra info)
SELECT DATE (purchases.my_date), first_time_readers.continent, SUM(purchases.paid)
FROM first_time_readers
RIGHT JOIN purchases ON first_time_readers.user_id = purchases.user_id
GROUP BY first_time_readers.continent, DATE (purchases.my_date)
ORDER BY DATE(purchases.my_date);-- 2018-03-05	Reddit	2504 | 2018-03-12	Reddit	2480	SEO	2288 |  2018-03-23	Reddit	3344	SEO	2680 




-------------------------------------------DRAFT START,  NO MORE USEFULL INFO HERE (i will continue in python)-------------------------------------------

-- What costumers read at the day of the purchases?

SELECT*FROM returning_readers FULL JOIN purchases ON returning_readers.user_id = purchases.user_id LIMIT 300;

SELECT * FROM first_time_readers FULL JOIN purchases ON first_time_readers.user_id = purchases.user_id LIMIT 300;



SELECT COUNT(purchases.paid) FROM returning_readers FULL JOIN purchases ON returning_readers.user_id = purchases.user_id; --153187 dollars from returning readers

SELECT COUNT(purchases.paid) FROM first_time_readers FULL JOIN purchases ON first_time_readers.user_id = purchases.user_id; -- 8407 dollars from first time readers

SELECT COUNT (*) FROM returning_readers; -- 371854
SELECT COUNT(*) FROM returning_readers FULL JOIN purchases ON returning_readers.user_id = purchases.user_id; --413025

SELECT COUNT (*) FROM first_time_readers; -- 210023
SELECT COUNT(*) FROM first_time_readers FULL JOIN purchases ON first_time_readers.user_id = purchases.user_id; --211782

-- JOIN them on my_date



SELECT * FROM first_time_readers FULL JOIN purchases ON first_time_readers.user_id = purchases.user_id LIMIT 200;

SELECT COUNT(DISTINCT returning_readers.user_id) FROM returning_readers; -- 66231 !!!
SELECT COUNT(*) FROM first_time_readers FULL JOIN purchases ON first_time_readers.user_id = purchases.user_id WHERE purchases.my_date IS NULL; --203375
SELECT COUNT(*) FROM returning_readers FULL JOIN purchases ON returning_readers.user_id = purchases.user_id WHERE purchases.my_date IS NULL;



SELECT * FROM returning_readers FULL JOIN purchases ON DISTINCT(returning_readers.user_id) = DISTINCT(purchases.user_id) LIMIT 40;


-- SELECT COUNT(*) FROM(
SELECT DISTINCT (purchases.my_date) as date_of_purchase,
       returning_readers.my_date as date_of_reading,
       returning_readers.continent,
       returning_readers.user_id,
       purchases.user_id,
       purchases.my_date,
       purchases.paid
FROM returning_readers
  FULL JOIN purchases ON returning_readers.user_id = purchases.user_id LIMIT 200;
  --) as original;

SELECT DISTINCT (purchases.my_date) as date_of_purchase,
       returning_readers.my_date as date_of_reading,
       returning_readers.continent,
       returning_readers.user_id,
       purchases.user_id,
       purchases.my_date,
       purchases.paid
FROM returning_readers
  FULL JOIN purchases ON returning_readers.user_id = purchases.user_id WHERE returning_readers.user_id IS NULL LIMIT 200; -- only two lines


SELECT * FROM first_time_readers WHERE first_time_readers.user_id = 2458151933;
SELECT * FROM first_time_readers WHERE first_time_readers.user_id = 2458152245;



SELECT (DATE(purchases.my_date)- DATE(returning_readers.my_date)) as days_reed_to_buy
FROM returning_readers
  FULL JOIN purchases ON returning_readers.user_id = purchases.user_id LIMIT 10;


SELECT *
FROM returning_readers
  FULL JOIN purchases ON DISTINCT(returning_readers.user_id) = DISTINCT(purchases.user_id) LIMIT 200;
  

--------------------------------------------------
-------------------------------------------------- i go with python with comlicated questions
SELECT COUNT(*)FROM(
SELECT user_id, SUM(paid) FROM purchases GROUP BY user_id) as original_query; -- 6648 paid users

SELECT MAX (total_paid) FROM(
SELECT user_id, SUM(paid) as total_paid  FROM purchases GROUP BY user_id) as original_query; -- MAX is 88/ user



SELECT user_id, SUM(paid) as total_paid  FROM purchases GROUP BY user_id LIMIT 10;

SELECT MAX(days_reed_to_buy)
FROM (SELECT purchases.user_id,
             DATE (purchases.my_date) - DATE (returning_readers.my_date) AS days_reed_to_buy
             FROM returning_readers
        FULL JOIN purchases ON returning_readers.user_id = purchases.user_id) AS original_query; -- 18 days max


SELECT MIN(days_reed_to_buy)
FROM (SELECT purchases.user_id,
             DATE (purchases.my_date) - DATE (returning_readers.my_date) AS days_reed_to_buy
             FROM returning_readers
        FULL JOIN purchases ON returning_readers.user_id = purchases.user_id) AS original_query; -- -23


-------------------------------------------------DRAFT END















