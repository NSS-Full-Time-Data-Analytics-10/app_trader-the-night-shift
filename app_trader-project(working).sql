

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
SELECT CAST(TRIM(TRAILING '+' FROM REPLACE(install_count, ',', '')) AS integer) AS review_count
FROM play_store_apps;

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
FROM play_store_apps