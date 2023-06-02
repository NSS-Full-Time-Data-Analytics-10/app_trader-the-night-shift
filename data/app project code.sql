-- TOP 10 LIST
SELECT name, 
app.rating AS app_rating, 
-- making every rating rounded to .25
ROUND(play.rating/25,2)*25 AS play_rating, 
ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
genres, 
primary_genre,
play.price::NUMERIC + app.price AS price, 
-- fixing the install_count so it can actually be used
CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS installation_count
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
-- adding criteria to narrow down selection
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
AND primary_genre LIKE 'Games'
AND app.review_count::NUMERIC > (SELECT AVG(review_count::NUMERIC) FROM app_store_apps)
AND play.review_count > (SELECT AVG(review_count) FROM play_store_apps)
AND app.content_rating LIKE '4+'
AND play.content_rating LIKE 'Everyone'
AND CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) > 50000000
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price, installation_count
ORDER BY app_rating DESC, play_rating DESC;



-- Analysis on top 10 list
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

SELECT name, 
-- calculating years in the store
ROUND((((avg_rating/.25)*6)/12)+1,2) AS years_in_store, 
-- calculating purchase cost
(price + 25000)::MONEY AS intial_cost,
-- calculating advertising cost for life of app
(((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_advertising_cost,
-- combining intial and adertising cost
(price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY AS total_cost,
-- calculating revenue
((((avg_rating/.25)*6)/12)+1)*12*5000::MONEY AS revenue,
-- calculating profit
(((((avg_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((avg_rating/.25)*6)/12)+1) * 1000)::MONEY) AS profit
FROM top_10_apps;











