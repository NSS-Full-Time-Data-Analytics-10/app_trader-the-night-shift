-- 2. Assumptions
-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- 	a. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

-- 	b. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

-- 	c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

-- 	d. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

-- 	e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

select * from app_store_apps;
select distinct name from play_store_apps where name = 'YAKALA AY'

--games that are in both tables
(SELECT name FROM app_store_apps)
INTERSECT
(SELECT name FROM play_store_apps)
ORDER BY name DESC

WITH averages AS (SELECT ROUND(AVG(ps.review_count), 2) AS play_avg, ROUND(AVG(aps.review_count::integer), 2) as appstore_avg 
FROM play_store_apps AS ps INNER JOIN app_store_apps AS aps ON ps.name = aps.name);


--purchase price for games in both tables
WITH fixed_price AS (SELECT DISTINCT name, TRIM(LEADING '$' FROM price)::numeric(5,2) AS trimmed
					FROM play_store_apps 
					ORDER BY  trimmed DESC)
SELECT DISTINCT name, 
				CASE WHEN trimmed BETWEEN 0.00 AND 2.50 THEN 25000
				WHEN trimmed > 2.50 THEN trimmed * 10000
				END AS calc
FROM fixed_price 
WHERE name IN (SELECT DISTINCT name FROM app_store_apps)
ORDER BY name DESC

					
	


