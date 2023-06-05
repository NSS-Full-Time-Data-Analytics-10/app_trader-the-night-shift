-- 2. Assumptions
-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- 	a. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

-- 	b. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

-- 	c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

-- 	d. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

-- 	e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

select * from app_store_apps;
select * from play_store_apps;



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

WITH top_revenue_apps AS (SELECT name,
app.rating AS app_rating,
ROUND(play.rating/25,2)*25 AS play_rating,
ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
genres,
primary_genre,
play.price::NUMERIC + app.price AS price--,
--CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
--AND primary_genre LIKE 'Games'
--AND primary_genre IN('Weather', 'Travel', 'Music', 'Navigation', 'Entertainment', 'Food & Drink')					
--AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
--AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
--AND app.content_rating LIKE '4+'
--AND play.content_rating LIKE 'Everyone'
--AND CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price--, installation_count
ORDER BY app_rating DESC, play_rating DESC)
SELECT name, 
--years in app store, intial cost, ad cost, total cost
--ad cost dropped to $500 to split between app stores
ROUND((((app_rating/.25)*6)/12)+1,2) AS years_in_app_store, (price + 25000)::MONEY AS intial_cost,
(((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_cost,
--years in play store, intial cost, ad cost, total cost
--add cost dropped to $500 to split between app stores
ROUND((((play_rating/.25)*6)/12)+1,2) AS years_in_play_store, (price + 25000)::MONEY AS intial_cost,
(((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_cost,
--revenue is app_rating + play_rating
(((((app_rating/.25)*6)/12)+1)*12*5000::MONEY +                  --AS app_revenue
((((play_rating/.25)*6)/12)+1)*12*5000::MONEY) AS total_revenue, --AS play_revenue
--profit is app_revenue - (intial+ad) + play_revenue - (intial+ad)
((((((app_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY) +
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY)) AS profit
--profit is calculated as a 1 year profit
FROM top_revenue_apps;

(select * from app_store_apps where name ILIKE '%AIRbnb%')
UNION
(select * From play_store_apps where name ILIKE '%airbnb%')


SELECT name, category, genres, app.primary_genre, play.rating, app.rating, app.price, play.price
FROM play_store_apps AS play INNER JOIN app_store_apps AS app USING (name)
WHERE play.genres ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
	AND app.primary_genre ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
GROUP BY name, category, genres, app.primary_genre, play.rating, app.rating, app.price, play.price
ORDER BY app.rating DESC, play.rating DESC

--4th of july apps
WITH july_app AS (SELECT distinct name, price, primary_genre
				 FROM app_store_apps),
app_price AS (SELECT DISTINCT name, 
				CASE WHEN price BETWEEN 0.00 AND 2.50 THEN 25000
				WHEN price > 2.50 THEN price * 10000
				END AS app_calc
FROM july_app
WHERE name IN (SELECT DISTINCT name
			   FROM play_store_apps) 
			   AND primary_genre ILIKE ANY (SELECT unnest(ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%']))
			   ORDER BY name DESC),

july_play AS (SELECT DISTINCT name, TRIM(LEADING '$' FROM price)::numeric(5,2) AS trimmed, genres
					FROM play_store_apps 
					ORDER BY  trimmed DESC),
play_price AS (SELECT DISTINCT name, 
				CASE WHEN trimmed BETWEEN 0.00 AND 2.50 THEN 25000
				WHEN trimmed > 2.50 THEN trimmed * 10000
				END AS play_calc
FROM july_play
WHERE name IN (SELECT DISTINCT name FROM app_store_apps) AND genres ILIKE ANY (SELECT unnest(ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%']))
ORDER BY name DESC)

SELECT DISTINCT play_price.name, play_price.play_calc, app_price.app_calc, july_app.primary_genre, july_play.genres 
FROM play_price INNER JOIN app_price USING (name)
				INNER JOIN july_app USING (name)
				INNER JOIN july_play USING (name)
	
	
	
	
	
----------------------
--query for top genres related to 4th of july
WITH genre_revenue AS
(SELECT name, category, genres, app.primary_genre AS app_genre,
app.rating AS app_rating,
ROUND(play.rating/25,2)*25 AS play_rating,
ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
play.price::NUMERIC + app.price AS price
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE play.price = '0' AND app.price = 0
AND play.genres ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
	AND app.primary_genre ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
GROUP BY name, category, genres, app.primary_genre, app.rating, play.rating, play.price,
		app.price),

WITH genre_revenue AS
					(SELECT name, category, genres, app.primary_genre AS app_genre,
					app.rating AS app_rating,
					ROUND(play.rating/25,2)*25 AS play_rating,
					ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
					play.price::NUMERIC + app.price AS price
					FROM app_store_apps AS app
					INNER JOIN play_store_apps AS play
					USING (name)
					WHERE play.price = '0' AND app.price = 0
						AND play.genres ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
						AND app.primary_genre ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
					GROUP BY name, category, genres, app.primary_genre, app.rating, play.rating, play.price, app.price),

top_genres AS (SELECT name, app_genre,
				ROUND((((app_rating/.25)*6)/12)+1,2) AS years_in_app_store, (price + 25000)::MONEY AS intial_cost_app,
				(((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost,
				(price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_app_cost,
				ROUND((((play_rating/.25)*6)/12)+1,2) AS years_in_play_store, (price + 25000)::MONEY AS intial_cost_play,
				(((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost_year,
				(price + 25000)::MONEY + (((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_play_cost,
				(((((app_rating/.25)*6)/12)+1)*12*5000::MONEY +                  --AS app_revenue
				((((play_rating/.25)*6)/12)+1)*12*5000::MONEY) AS total_revenue, --AS play_revenue
				((((((app_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY) +
				(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY)) AS profit
				FROM genre_revenue
				ORDER BY profit DESC),

total_profit AS (select name, 
	   			app_genre, 
	   			years_in_app_store,
	   			years_in_play_store,
	   			intial_cost_app AS  purchase_price, 
	   			CASE WHEN years_in_app_store > years_in_play_store THEN ((1000 * 12) * years_in_app_store)
	   			ELSE ((1000*12) * years_in_play_store)
	   			END AS total_ad_cost,	
	   			intial_cost_app::numeric + CASE WHEN years_in_app_store > years_in_play_store THEN ((1000 * 12) * years_in_app_store)
	   			ELSE ((1000*12) * years_in_play_store)
	   			END AS total_cost, 
	   			(((5000*12)*years_in_app_store) + ((5000*12)*years_in_play_store)) AS total_revenue
				FROM top_genres),     
				
final_table AS (SELECT *, ((total_revenue - total_cost) / 2)::money AS total_profit
				FROM total_profit)
				

-- SELECT * 
-- FROM final_table 
-- ORDER BY total_profit 
-- DESC LIMIT 12

-- SELECT AVG(total_profit::numeric), app_genre 
-- FROM final_table 
-- GROUP BY app_genre

(SELECT * 
	FROM final_table 
	WHERE app_genre ='Food & Drink'
	ORDER BY total_profit DESC
	LIMIT 1
	OFFSET 1)
UNION
	(SELECT * 
	FROM final_table 
	WHERE app_genre ='Shopping'
	ORDER BY total_profit DESC
	LIMIT 1)
UNION
	(SELECT * 
	FROM final_table 
	WHERE app_genre ='Travel'
	ORDER BY total_profit DESC
	LIMIT 1)
UNION
	(SELECT * 
	FROM final_table 
	WHERE app_genre ='Weather'
	ORDER BY total_profit DESC
	LIMIT 1)

