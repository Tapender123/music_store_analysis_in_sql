SELECT * FROM album
---Q1. Who is the senio most employee based on job title?

SELECT * FROM employee
ORDER BY levels desc
limit 1;

---Q.2 Which country have have the most invoices?
SELECT * FROM invoice


SELECT COUNT(*) AS c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC

---Q3. What are top 3 values of total invoices?
SELECT * FROM invoice

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

--- Q4. Which city has the best customers? We would like to throw a promotional
--Music festival in the city we made the most money write a query that returns one
--city that has highest sum of invoice totals. Return both the city name and sum of 
--all invoice totals.
SELECT * FROM invoice


select sum(total) AS invoice_total, billing_city 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc
limit 1;

--Q5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent
-- the most money.
SELECT * FROM invoice
SELECT * FROM customer

select customer.customer_id, customer.first_name,
customer.last_name,SUM(invoice.total) AS total
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1;

--Q. Write query to return the email, first name, last name and genre of all 
-- Rock music listners. Return your list ordered aphabatically by email starting
--with A

--check schema png file 
select * from invoice
select * from invoice_line
select * from track
select * from customer
--- without genre name
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id =	invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
SELECT track_id 
FROM track
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email ASC
);
---with genre name

SELECT DISTINCT email, first_name, last_name, genre.name AS genre_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY customer.email ASC;

--Q. Lets invite the artist who have written the most rock music in our dataset 
--Write a query that return the artist name and total track count of the  
-- total 10 rock bands

-- check schema file
SELECT * FROM artist
SELECT * FROM album
SELECT * FROM track
SELECT * FROM genre

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY  number_of_songs
LIMIT 10

--Q. Return all the tracks name that have a song length longer than the average 
--song length. Return the Name and Milliseconds for each track. Order by the song
-- length with the longest song listed first
SELECT * FROM track


SELECT name, milliseconds
FROM track
WHERE milliseconds >(
                select AVG(milliseconds) AS average_track_length
				FROM track)
				ORDER BY milliseconds DESC;


--Q1Find how much amount spent by each customer on artists? write a query to return
--customer name, artist name and total spent 

--check schema 

SELECT * FROM customer
SELECT * FROM invoice
SELECT * FROM artist
--inq
WITH best_selling_artist AS(
SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1

)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--we want to find out the most popular music genre for each country. We determine
-- the most popular genre as the genre with the highest amount of purchases. Write
--a query that returns each country along with the top genre. For countries where
-- the maximum number of purchases is shared return all genres.

--check schema
SELECT * FROM invoice
SELECT * FROM customer
SELECT * FROM track
SELECT * FROM genre

WITH popular_genre AS(
SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name,
genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)
DESC) AS RowNo
FROM invoice_line
JOIN invoice ON  invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = 	invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC)
SELECT * FROM popular_genre WHERE RowNo <=1

-- write a query that determines the customer that has spent the most on music for 
--every country. Write a query that returns the country along with the top
-- customers and how much they spent. For countries where top amount spent is 
--shared, provide all customers who spent this amount

--check schema
	
WITH RECURSIVE
    customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country,
	SUM(total) AS total_spending
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 2,3 DESC),

	country_max_spending AS(
	SELECT billing_country, MAX(total_spending) AS max_spending
	FROM customer_with_country
	GROUP BY billing_country)
	
	SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name,
	cc.customer_id
	FROM customer_with_country cc
	JOIN country_max_spending AS ms ON cc.billing_country = ms.billing_country
	ORDER BY 1;



	--another method with help of cte

	WITH customer_with_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country,
	SUM(total) AS total_spending, ROW_NUMBER() OVER(PARTITION BY billing_country
	ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC)
		SELECT * FROM customer_with_country WHERE RowNo <= 1




