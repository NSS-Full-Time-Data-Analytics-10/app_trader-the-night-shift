--3B 
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
						--AND play.genres ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
						--AND app.primary_genre ILIKE ANY (ARRAY['%food & drink%', '%travel%', '%weather%', '%shopping%'])
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
				
SELECT * FROM final_table
LIMIT 10;

--3B #2 (ad costs are not correct)
WITH top_revenue_apps AS (SELECT name,
app.rating AS app_rating,
ROUND(play.rating/25,2)*25 AS play_rating,
ROUND(((app.rating + play.rating)/2)/25,2)*25 AS avg_rating,
genres,
primary_genre,
play.price::NUMERIC + app.price AS price
FROM app_store_apps AS app
INNER JOIN play_store_apps AS play
USING (name)
WHERE app.rating >= 4.5 AND play.rating >= 4.5
AND play.price = '0' AND app.price = 0
GROUP BY name, app.rating, play.rating, genres, primary_genre, play.price, app.price
ORDER BY app_rating DESC, play_rating DESC)
SELECT name,
ROUND((((app_rating/.25)*6)/12)+1,2) AS years_in_app_store, (price + 25000)::MONEY AS intial_cost,
((((((app_rating/.25)*6)/12)+1) * 1000)* ROUND((((app_rating/.25)*6)/12)+1,2))::MONEY AS total_advertising_cost,
(price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY AS total_cost,
ROUND((((play_rating/.25)*6)/12)+1,2) AS years_in_play_store, (price + 25000)::MONEY AS intial_cost,
((((((play_rating/.25)*6)/12)+1) * 500 *12)* ROUND((((play_rating/.25)*6)/12)+1,2))::MONEY AS total_lifespan_advertising_cost,
(price + 25000)::MONEY + (((((play_rating/.25)*6)/12)+1) * 500)::MONEY AS total_cost,
(((((app_rating/.25)*6)/12)+1)*12*5000::MONEY +
((((play_rating/.25)*6)/12)+1)*12*5000::MONEY) AS total_revenue,
((((((app_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY) +
(((((play_rating/.25)*6)/12)+1)*12*5000)::MONEY - ((price + 25000)::MONEY + (((((app_rating/.25)*6)/12)+1) * 500)::MONEY))/2 AS profit
FROM top_revenue_apps
LIMIT 10;




--3C TOP 4 based on summer July 4th theme/genre
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
--select * from final_table
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



