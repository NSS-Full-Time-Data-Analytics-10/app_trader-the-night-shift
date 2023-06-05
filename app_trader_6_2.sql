SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps


SELECT name, MAX(install_count)
FROM play_store_apps
GROUP BY name, install_count 
ORDER BY install_count

SELECT AVG(review_count)
FROM play_store_apps
--444153

SELECT ROUND(AVG(rating),1)
FROM app_store_apps 
INNER JOIN USING (name)
--3.5 app
--4.2 play

--*** Genre filter
SELECT name, category, genres, app_store_apps.primary_genre
FROM play_store_apps INNER JOIN app_store_apps USING (name)
WHERE play_store_apps.genres ILIKE ('%food & drink%' '%travel%' '%weather%' '%shopping%')
	AND app_store_apps.primary_genre ILIKE ('%food & drink%' '%travel%' '%weather%' '%shopping%')
GROUP BY name, category, genres, app_store_apps.primary_genre

--top 4 list of 22, 9 compared to AVG rating 4.2
SELECT name, category, genres, play_store_apps.rating, app_store_apps.primary_genre, app_store_apps.rating
FROM play_store_apps INNER JOIN app_store_apps USING (name)
WHERE play_store_apps.genres ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
	AND play_store_apps.rating > (SELECT ROUND(AVG(rating),1) FROM play_store_apps) 
	AND app_store_apps.primary_genre ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
	AND app_store_apps.rating > (SELECT ROUND(AVG(rating),1) FROM app_store_apps) 
GROUP BY name, category, genres, play_store_apps.rating, app_store_apps.primary_genre, app_store_apps.rating
ORDER BY play_store_apps.rating, app_store_apps.rating DESC

(SELECT MAX(rating) FROM play_store_apps)
(SELECT MAX(rating) FROM app_store_apps) 
--
--ADAM 3C
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
FROM genre_revenue
ORDER BY profit DESC)
(SELECT *
	FROM top_genres
	WHERE app_genre ='Food & Drink'
	ORDER BY profit DESC
	LIMIT 1
	OFFSET 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Shopping'
	ORDER BY profit DESC
	LIMIT 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Travel'
	ORDER BY profit DESC
	LIMIT 1)
UNION
	(SELECT *
	FROM top_genres
	WHERE app_genre ='Weather'
	ORDER BY profit DESC
	LIMIT 1)
--

--JOHN
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
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY)) AS profit
--profit is calculated as a 1 year profit
FROM genre_revenue
ORDER BY profit DESC
LIMIT 10;

--**
SELECT name, genres
FROM play_store_apps
WHERE genres ILIKE '%Event%'
Group BY name, category, genres
--*

SELECT name, rating, install_count
FROM play_store_apps
GROUP BY name, rating, install_count 
ORDER BY install_count

SELECT name, price, review_count
FROM app_store_apps
GROUP BY name, price, review_count
ORDER BY price DESC

-- trims + ,
SELECT (TRIM(TRAILING '+' FROM review_count))::integer AS converted 
FROM app_store_apps

WITH trimmed_installs AS (
	
SELECT TRIM('+' FROM install_count)
FROM play_store_apps

SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
FROM play_store_apps;
	


SELECT name, price, CAST(review_count as int)
FROM app_store_apps
GROUP BY name, price, review_count
ORDER BY review_count DESC NULLS LAST

SELECT name, rating, primary_genre
FROM app_store_apps 
INTERSECT
SELECT name, rating, genres
FROM play_store_apps
--7 includes microsoft excel & word

SELECT name, rating
FROM app_store_apps 
INTERSECT
SELECT name, rating
FROM play_store_apps
--51, ratings >4

SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating, 
genres, 
primary_genre,
play.price AS play_price,
app.price AS app_price
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
AND primary_genre LIKE 'Games'
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price;
--52 @ 4.5 --123 @ avg rating 3.85

WITH instalations AS (SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
FROM play_store_apps)

SELECT AVG(review_count)
FROM instalations;	
--AVG installs 15464339
		
--WITH instalations AS (SELECT install_count, CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM play_store_apps)
	
--SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating, 
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
AND primary_genre LIKE 'Games'
AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
AND installation_count > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, installation_count
ORDER BY app_rating DESC, play_rating DESC;	
	
ROUND(play.rating/25,2)*25 AS play_rating
ROUND((app_rating+play_rating)/25, 2)*25
	
SELECT name, ROUND(((app.rating + play.rating)/2)/25,2)*25
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name);	
--

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


--Nick's first code
WITH instalations AS (SELECT install_count, CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM play_store_apps)

SELECT name, 
app.rating AS app_rating, 
play.rating AS play_rating, 
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
AND primary_genre LIKE 'Games'
AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
AND installation_count > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, installation_count
ORDER BY app_rating DESC, play_rating DESC;


--6/5/23 John
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


--NICKS TOP 10 life_app
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

SELECT name, ROUND((((avg_rating/.25)*6)/12)+1,2) AS avg_years_in_store, 
(price + 25000)::MONEY AS intial_cost,
(((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_advertising_cost_life_app,
(price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_cost_life_app,
((((avg_rating/.25)*6)/12)+1)*12*5000::MONEY AS revenue_life_app,
(((((((avg_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY))/2) AS profit_life_app
FROM top_10_apps;


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
ROUND((((app_rating/.25)*6)/12)+1,2) AS years_in_app_store, (price + 25000)::MONEY AS intial_cost_app,
(((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_app_cost,
--years in play store, intial cost, ad cost, total cost
--add cost dropped to $500 to split between app stores
ROUND((((play_rating/.25)*6)/12)+1,2) AS years_in_play_store, (price + 25000)::MONEY AS intial_cost_play,
(((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_advertising_cost_year,
(price + 25000)::MONEY + (((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_play_cost,
--revenue is app_rating + play_rating
(((((app_rating/.25)*6)/12)+1)*12*5000::MONEY +                  --AS app_revenue
((((play_rating/.25)*6)/12)+1)*12*5000::MONEY) AS total_revenue, --AS play_revenue
--profit is app_revenue - (intial+ad) + play_revenue - (intial+ad)
((((((app_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY) +
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY)) AS profit
--profit is calculated as a 1 year profit
FROM genre_revenue
ORDER BY profit DESC
)
select name,
	   app_genre,
	   years_in_app_store,
	   intial_cost_app,
	   intial_cost_play,
	   total_advertising_cost,
	   total_app_cost,
	   total_play_cost,
	   years_in_play_store,
	   intial_cost_app,
	   CASE WHEN years_in_app_store > years_in_play_store THEN (total_advertising_cost_year * years_in_app_store)
	   ELSE (total_advertising_cost * years_in_play_store)
	   END AS total_ad_cost
FROM top_genres


