-- 2. Assumptions
-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- 	a. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

-- 	b. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

-- 	c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

-- 	d. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

-- 	e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

select * from app_store_apps;
select * from play_store_apps;

WITH review_convert AS (SELECT (TRIM(TRAILING '+' FROM review_count))::integer AS converted FROM app_store_apps)

--average review count
select ROUND(avg(review_count), 2), 'play store average' from play_store_apps
UNION
SELECT ROUND(AVG(review_count::integer)), 'app store average' FROM app_store_apps

select MIN(review_count::integer) from app_store_apps

--games that are in both tables
(SELECT name FROM app_store_apps)
INTERSECT
(SELECT name FROM play_store_apps)
ORDER BY name DESC

--purchase price for games in both tables
					FROM play_store_apps 
					ORDER BY  trimmed DESC)
SELECT DISTINCT name, 
				CASE WHEN trimmed BETWEEN 0.00 AND 2.50 THEN 25000
				WHEN trimmed > 2.50 THEN trimmed * 10000
				END AS calc
FROM fixed_price 
WHERE name IN (SELECT name FROM app_store_apps)
ORDER BY name DESC

--top games
SELECT DISTINCT name, 
app.rating AS app_rating, 
ROUND(play.rating/25, 2) * 25 AS play_rating, 
genres, 
primary_genre,
play.price AS play_price,
app.price AS app_price,
play.review_count AS play_reviews
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
AND primary_genre ILIKE 'Games'
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, play.review_count
ORDER BY app_rating DESC, play_rating DESC
					
--top games with review count
WITH instalations AS (SELECT install_count, CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM play_store_apps)

SELECT name, 
		(play.rating + app.rating) / 2 AS average_rating,
		genres, 
		primary_genre,
		play.price AS play_price,
		app.price AS app_price,
		installation_count
FROM app_store_apps AS app
		INNER JOIN play_store_apps AS play
		USING (name)
		INNER JOIN instalations
		USING (install_count)
	WHERE app.rating >= 4.5 AND play.rating >= 4.5
		AND play.price = '0' AND app.price = 0
-- 		AND primary_genre LIKE 'Games'
		AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
		AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
-- 		AND app.content_rating LIKE '4+'
-- 		AND play.content_rating LIKE 'Everyone'
		AND installation_count >= 1000000
GROUP BY name, 
		app.rating, 
		play.rating, 
		genres, 
		primary_genre, 
		play.price, 
		app.price, 
		installation_count
ORDER BY average_rating DESC;

select name, play.genres, app.primary_genre, (app.rating + play.rating) /2 AS average_rating
FROM play_store_apps AS play
	INNER JOIN app_store_apps AS app USING (name)

select * FROM play_store_apps
INNER JOIN app_store_apps USING (name)


------------------------------

WITH top_10_apps AS (SELECT name, 
app.rating AS app_rating, 
ROUND(play.rating/25,2)*25 AS play_rating, 
ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
genres, 
primary_genre,
play.price::NUMERIC + app.price AS price, 
CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
AND primary_genre LIKE 'Games'
AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
AND CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, installation_count
ORDER BY app_rating DESC, play_rating DESC)

SELECT name, ROUND((((avg_rating/.25)*6)/12)+1,2) AS years_in_store, 
(price + 25000)::MONEY AS intial_cost,
(((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_cost,
((((avg_rating/.25)*6)/12)+1)*12*5000::MONEY AS revenue,
(((((avg_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY) AS profit
FROM top_10_apps;

