

SELECT name, app_store_apps.review_count::integer AS ap_review, play_store_apps.review_count AS pl_review,
app_store_apps.rating AS ap_rating, play_store_apps.rating AS pl_rating, 
app_store_apps.price:: money AS ap_price, play_store_apps.price:: money AS pl_price
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
ORDER BY pl_review DESC, pl_rating;


SELECT name
FROM app_store_apps
INTERSECT 
SELECT name 
FROM play_store_apps;



SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating,
--play.price AS play_price,
--app.price AS app_price, 
genres, primary_genre, app.content_rating, play.content_rating
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
GROUP BY name, app.rating, play.rating, play.price, app.price, genres, primary_genre, app.content_rating, play.content_rating
ORDER BY app_rating DESC;
--top 15 based on those conditions

WITH instalations AS (SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
FROM play_store_apps),
gg AS
(SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating,
--play.price AS play_price,
--app.price AS app_price, 
genres, primary_genre, app.content_rating, play.content_rating, (SELECT ROUND(AVG(review_count), 0)
FROM instalations)

FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
GROUP BY name, app.rating, play.rating, genres, primary_genre, app.content_rating, play.content_rating, install_count
ORDER BY install_count DESC)

SELECT name, ROUND(((app_rating+play_rating)/2)/25, 2)*25 
FROM gg
ORDER BY round DESC
--average rating between both for the query above it


--average install count
--SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
--FROM play_store_apps;

WITH instalations AS (SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
FROM play_store_apps)
SELECT ROUND(AVG(review_count), 0)
FROM instalations;
--average install count


--clean up below
WITH instalations AS (SELECT install_count, CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM play_store_apps) --this is changing install count to an integer

SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating, 
genres, 
primary_genre,
--play.price AS play_price,
--app.price AS app_price,
installation_count
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
INNER JOIN instalations
USING (install_count)
WHERE app.rating > ROUND(((app.rating+play.rating)/2)/25, 2)*25
--WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
--AND primary_genre LIKE 'Games'
AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
--AND installation_count > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, installation_count
--ORDER BY app_rating DESC, play_rating DESC;
ORDER BY ROUND(((app.rating+play.rating)/2)/25, 2)*25 DESC

SELECT name, genres, primary_genre
FROM app_store_apps
INNER JOIN play_store_apps
USING(name)
WHERE 

--START WORKING FROM HERE

SELECT name, rating, primary_genre
FROM app_store_apps
WHERE primary_genre IN('Weather', 'Travel', 'Music', 'Navigation', 'Entertainment', 'Food & Drink')
	AND rating >= '4.5'
	AND price = '0'
	AND content_rating = '4+'
	ORDER BY rating DESC;
--shows top rated apps in app store for those conditions


SELECT name, rating, genres, install_count
FROM play_store_apps
WHERE genres IN('Weather', 'Travel%', '%Music%', '%Navigation%', 'Entertainment%', 'Food & Drink', 'Events')
	AND rating >= '4.5'
	AND price = '0'
	AND content_rating = 'Everyone'
	ORDER BY rating DESC;

SELECT DISTINCT genres
FROM play_store_apps;



WITH top_10_apps AS (SELECT name, 
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
AND primary_genre IN('Weather', 'Travel', 'Music', 'Navigation', 'Entertainment', 'Food & Drink')					 
--AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
--AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
--AND CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price--, installation_count
ORDER BY app_rating DESC, play_rating DESC)

SELECT name, ROUND((((avg_rating/.25)*6)/12)+1,2) AS years_in_store, 
(price + 25000)::MONEY AS intial_cost,
(((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_cost,
((((avg_rating/.25)*6)/12)+1)*12*5000::MONEY AS revenue,
(((((avg_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY) AS profit
FROM top_10_apps;




--USE THIS CODE
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
--pulls top 72 apps that are in both stores and orders them by total revenue


--pulls top apps in both based on genres
WITH genre_revenue AS
(SELECT name, category, genres, app.primary_genre, 
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
		app.price)

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
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY))/2 AS profit

--profit is calculated as a 1 year profit
FROM genre_revenue
ORDER BY profit DESC
LIMIT 10;

--picking 4 from the list above

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
top_genres AS (SELECT name, app_genre,
--years in app store, intial cost, ad cost, total cost
--ad cost dropped to $500 to split between app stores
ROUND((((app_rating/.25)*6)/12)+1,2) AS years_in_app_store, (price + 25000)::MONEY AS intial_cost,
((((((app_rating/.25)*6)/12)+1) * 500)* ROUND((((app_rating/.25)*6)/12)+1,2))::MONEY AS total_lifespan_advertising_cost,
(price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_lifespan_cost,
--years in play store, intial cost, ad cost, total cost
--add cost dropped to $500 to split between app stores
ROUND((((play_rating/.25)*6)/12)+1,2) AS years_in_play_store, (price + 25000)::MONEY AS intial_cost,
((((((play_rating/.25)*6)/12)+1) * 500)* ROUND((((play_rating/.25)*6)/12)+1,2))::MONEY AS total_lifespan_advertising_cost,
(price + 25000)::MONEY + (((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_lifespan_cost,
--revenue is app_rating + play_rating
(((((app_rating/.25)*6)/12)+1)*12*5000::MONEY +                  --AS app_revenue
((((play_rating/.25)*6)/12)+1)*12*5000::MONEY) AS total__lifespan_revenue, --AS play_revenue
--profit is app_revenue - (intial+ad) + play_revenue - (intial+ad)
((((((app_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY) +
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY))/2 AS lifespan_profit,
--ROUND((((app_rating/.25)*6)/12)+1,2) + ROUND((((play_rating/.25)*6)/12)+1,2)*12*5000

FROM genre_revenue
ORDER BY lifespan_profit DESC)
(SELECT *
	FROM top_genres
	WHERE app_genre ='Food & Drink'
	ORDER BY lifespan_profit DESC
	LIMIT 1
	OFFSET 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Shopping'
	ORDER BY lifespan_profit DESC
	LIMIT 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Travel'
	ORDER BY lifespan_profit DESC
	LIMIT 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Weather'
	ORDER BY lifespan_profit DESC
	LIMIT 1);