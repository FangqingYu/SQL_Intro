-- 1a
SELECT first_name, last_name FROM sakila.actor;

-- 1b
SELECT upper(concat(first_name, ' ', last_name)) AS actor_name FROM sakila.actor;

-- 2a
SELECT * FROM sakila.actor
WHERE first_name = "Joe";

-- 2b
SELECT * FROM sakila.actor
WHERE last_name LIKE "%GEN";

-- 2c
SELECT * FROM sakila.actor
WHERE last_name LIKE "%LI"
ORDER BY last_name, first_name;

-- 2d
SELECT country_id, country FROM sakila.country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a
ALTER TABLE sakila.actor
ADD COLUMN description BLOB;

-- 3b
ALTER TABLE sakila.actor
DROP COLUMN description;

-- 4a
SELECT last_name, COUNT(last_name) FROM sakila.actor
GROUP BY last_name;

-- 4b
SELECT last_name, COUNT(last_name) FROM sakila.actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c
UPDATE sakila.actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d
UPDATE sakila.actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 5a
DROP DATABASE IF EXISTS address;
CREATE DATABASE address;

-- 6a
SELECT * FROM sakila.address;
SELECT * FROM sakila.staff;
SELECT * FROM sakila.payment;

SELECT first_name, last_name, address
FROM sakila.staff s
INNER JOIN sakila.address a ON 
s.address_id = a.address_id;


-- 6b
SELECT first_name, last_name, SUM(amount) AS august_2005_total FROM
(
	SELECT s.first_name, s.last_name, s.staff_id, p.payment_date, p.amount FROM
	sakila.staff s INNER JOIN 
	sakila.payment p ON
	s.staff_id = p.staff_id
	HAVING p.payment_date LIKE '2005-05%'
    )Sub
GROUP BY staff_id;


-- 6c
SELECT * FROM sakila.film;
SELECT * FROM sakila.film_actor;

SELECT  f.title, COUNT(fa.actor_id) AS total_actors  FROM 
sakila.film_actor fa JOIN
sakila.film f ON
fa.film_id = f.film_id
GROUP BY actor_id;


-- 6d
SELECT * FROM inventory;

SELECT f.title, COUNT(i.film_id) AS inventory_count FROM
sakila.inventory i JOIN
sakila.film f ON
i.film_id = f.film_id
WHERE title = "Hunchback Impossible";


-- 6e
SELECT * FROM sakila.customer;

SELECT c.first_name, c.last_name, SUM(p.amount) FROM
sakila.customer c, sakila.payment p WHERE
c.customer_id = p.customer_id
GROUP BY p.customer_id
ORDER BY c.last_name ASC;


-- 7a
SHOW TABLES;
SELECT * FROM sakila.film;
SELECT * FROM sakila.language;

SELECT * FROM
(
	SELECT f.title, l.name FROM
	sakila.film f INNER JOIN
	sakila.language l ON
	f.language_id = l.language_id
	WHERE l.name = 'English'
    )Sub
HAVING title LIKE 'K%' OR title LIKE 'Q%';


-- 7b
SELECT f.title, Sub.first_name, Sub.last_name FROM
sakila.film f INNER JOIN 
(
	SELECT a.first_name, a.last_name, fa.film_id FROM
	sakila.actor a INNER JOIN
	sakila.film_actor fa ON
	a.actor_id = fa.actor_id
	) Sub 
ON
f.film_id = Sub.film_id
HAVING f.title = 'Alone Trip';


-- 7c
SELECT * FROM customer;
-- by address_id
SELECT * FROM address;

-- by city_id
SELECT * FROM city;
-- by country_id;
SELECT * FROM country;


SELECT first_name, last_name, country FROM 
(
	SELECT c.first_name, c.last_name, a.city_id FROM
	sakila.customer c INNER JOIN 
	sakila.address a ON
	c.address_id = a.address_id
    )Sub1
 INNER JOIN   
(
	SELECT city.city_id, country.country FROM
	sakila.city INNER JOIN
	sakila.country ON
	city.country_id = country.country_id
    )Sub2
ON
Sub1.city_id = Sub2.city_id
HAVING country = 'Canada';

-- 7d
-- by film_id
SELECT*FROM sakila.film;
SELECT*FROM sakila.film_category;
-- by category_id
SELECT*FROM sakila.category;

SELECT f.title, category_name FROM
sakila.film f INNER JOIN 
(
	SELECT fc.film_id, c.name AS category_name FROM
	sakila.film_category fc INNER JOIN
	sakila.category c ON
	fc.category_id = c.category_id
	HAVING name = 'Family'
    )Sub
ON f.film_id = Sub.film_id;


-- 7e
SELECT*FROM sakila.rental;
-- rental id, film id
-- by inventory id
SELECT*FROM sakila.inventory;
-- by film id
SELECT*FROM sakila.film;

SELECT f.title, number_rented FROM
sakila.film f INNER JOIN
(
	SELECT i.film_id, COUNT(r.rental_id) AS number_rented FROM
	sakila.rental r INNER JOIN
	sakila.inventory i ON
	r.inventory_id = i.inventory_id
	GROUP BY i.film_id
    )Sub
ON
f.film_id = Sub.film_id
ORDER BY number_rented DESC;


-- 7f
-- payment (by customer id) customer (store id -- by customer id) store
SELECT c.store_id, SUM(p.amount) AS total_amount FROM
sakila.customer c INNER JOIN
sakila.payment p ON
c.customer_id = p.customer_id
GROUP BY c.store_id;


-- 7g
-- STORE <-address_id-> Address <-city_id-> CITY <-country_id-> COUNTRY
SELECT store_id, city, country FROM
(

	SELECT s.store_id, a.city_id FROM
	sakila.store s INNER JOIN
	sakila.address a ON
	s.address_id = a.address_id
	)Sub1
INNER JOIN
(
	SELECT city.city, country.country, city.city_id FROM
	sakila.city INNER JOIN
	sakila.country ON
	city.country_id = country.country_id
    )Sub2
ON
Sub1.city_id = Sub2.city_id;


-- 7h
-- CATEGRY <-category_id-> FILM_CATEGORY <-film_id-> INVENTORY <-inventory_id-> RENTAL <-rental_id-> PAYMENT
SELECT c.name, SUM(Sub3.amount) AS total_amount_by_genre FROM
sakila.category c INNER JOIN
(
	SELECT  fc.category_id, Sub2.amount FROM
	sakila.film_category fc INNER JOIN
	(SELECT i.film_id, Sub1.amount FROM
		sakila.inventory i INNER JOIN
		(
			SELECT p.amount, r.inventory_id FROM
			sakila.payment p INNER JOIN
			sakila.rental r ON
			p.rental_id = r.rental_id
			)Sub1
		ON
		i.inventory_id = Sub1.inventory_id
		)Sub2
	ON
	fc.film_id = Sub2.film_id
	)Sub3
ON
c.category_id =  Sub3.category_id
GROUP BY name
ORDER BY total_amount_by_genre DESC
LIMIT 5;


-- 8a
CREATE VIEW Top_Five_Genre AS
	SELECT c.name, SUM(Sub3.amount) AS total_amount_by_genre FROM
	sakila.category c INNER JOIN
	(
		SELECT  fc.category_id, Sub2.amount FROM
		sakila.film_category fc INNER JOIN
		(SELECT i.film_id, Sub1.amount FROM
			sakila.inventory i INNER JOIN
			(
				SELECT p.amount, r.inventory_id FROM
				sakila.payment p INNER JOIN
				sakila.rental r ON
				p.rental_id = r.rental_id
				)Sub1
			ON
			i.inventory_id = Sub1.inventory_id
			)Sub2
		ON
		fc.film_id = Sub2.film_id
		)Sub3
	ON
	c.category_id =  Sub3.category_id
	GROUP BY name
	ORDER BY total_amount_by_genre DESC
	LIMIT 5;


-- 8b
SELECT * FROM sakila.top_five_genre;

-- 8c
DROP VIEW sakila.top_five_genre;