-- Question 1
-- Topic: Distinct
-- Task: Create a list of all different (distinct) replacement costs of the films
SELECT DISTINCT replacement_cost FROM film ORDER BY 1 

-- Question: What's the lowest replacement cost?
-- Answer: 9.99
SELECT MIN (replacement_cost) FROM film 
SELECT DISTINCT replacement_cost FROM film ORDER BY 1 LIMIT 1

-- Question 2:
-- Level: Moderate
-- Topic: CASE + GROUP BY
-- Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
-- low: 9.99 - 19.99
-- medium: 20.00 - 24.99
-- high: 25.00 - 29.99
-- Question: How many films have a replacement cost in the "low" group?
-- Answer: 514
SELECT 
CASE 
WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'Low'
WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'Medium'
WHEN replacement_cost BETWEEN 25.00 AND 29.99 THEN 'High'
END AS cost_range,
COUNT(*)
FROM film
GROUP BY cost_range

-- Question 3:
-- Level: Moderate
-- Topic: JOIN
-- Task: Create a list of the film titles including their title, length, and category name ordered descendingly by length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
-- Question: In which category is the longest film and how long is it?
-- Answer: Sports and 184

SELECT title, length, c.name AS category
FROM film f
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c on fc.category_id = c.category_id
WHERE c.name IN ('Drama', 'Sports')
ORDER BY 2 DESC
LIMIT 1

-- Question 4:
-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of how many movies (titles) there are in each category (name).
-- Question: Which category (name) is the most common among the films?
-- Answer: Sports with 74 titles

SELECT Count(*) AS no_of_movie, c.name AS category
FROM film f
LEFT JOIN film_category fc ON fc.film_id = f.film_id
LEFT JOIN category c on fc.category_id = c.category_id
GROUP BY category
ORDER BY 1 DESC
LIMIT 1


-- Question 5:
-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of the actors' first and last names and in how many movies they appear in.
-- Question: Which actor is part of most movies??
-- Answer: Susan Davis with 54 movies

SELECT first_name,last_name, COUNT(*)
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id=a.actor_id
LEFT JOIN film f ON fa.film_id=f.film_id
GROUP BY first_name, last_name
ORDER BY COUNT(*) DESC

-- Question 6:
-- Level: Moderate
-- Topic: LEFT JOIN & FILTERING
-- Task: Create an overview of the addresses that are not associated to any customer.
-- Question: How many addresses are that?
-- Answer: 4

SELECT COUNT(*)
FROM customer c
FULL OUTER JOIN address a on c.address_id = a.address_id
WHERE customer_id is null

-- Question 7:
-- Level: Moderate
-- Topic: JOIN & GROUP BY
-- Task: Create the overview of the sales  to determine the from which city (we are interested in the city in which the customer lives, not where the store is) most sales occur.
-- Question: What city is that and how much is the amount?
-- Answer: Cape Coral with a total amount of 221.55

SELECT SUM(amount), ct.city
FROM payment p 
LEFT JOIN customer c ON c.customer_id = p.customer_id
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ct ON ct.city_id = a.city_id
GROUP BY ct.city
ORDER BY 1 DESC
LIMIT 1

-- Question 8:
-- Level: Moderate to difficult
-- Topic: JOIN & GROUP BY
-- Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
-- Question: Which country, city has the least sales?
-- Answer: United States, Tallahassee with a total amount of 50.85.

SELECT ctry.country, ct.city, SUM(amount)
FROM payment p 
LEFT JOIN customer c ON c.customer_id = p.customer_id
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city ct ON ct.city_id = a.city_id
LEFT JOIN country ctry ON ctry.country_id = ct.country_id
GROUP BY ctry.country, ct.city
ORDER BY 3 ASC
LIMIT 1

SELECT country ||', ' ||city, SUM(amount)
FROM payment p
LEFT JOIN customer c ON p.customer_id=c.customer_id
LEFT JOIN address a ON a.address_id=c.address_id
LEFT JOIN city ci ON ci.city_id=a.city_id
LEFT JOIN country co ON co.country_id=ci.country_id
GROUP BY country ||', ' ||city
ORDER BY 2 ASC LIMIT 1

-- Question 9:
-- Level: Difficult
-- Topic: Uncorrelated subquery
-- Task: Create a list with the average of the sales amount each staff_id has per customer.
-- Question: Which staff_id makes on average more revenue per customer?
-- Answer: staff_id 2 with an average revenue of 56.64 per customer.
SELECT staff_id, ROUND(AVG(total),2) as avg_amount 
FROM (
SELECT SUM(amount) as total,customer_id,staff_id
FROM payment
GROUP BY customer_id, staff_id) 
GROUP BY staff_id

-- Question 10:
-- Level: Difficult to very difficult
-- Topic: EXTRACT + Uncorrelated subquery
-- Task: Create a query that shows average daily revenue of all Sundays.
-- Question: What is the daily average revenue of all Sundays?
-- Answer: 1410.65

SELECT AVG(total)
FROM 
	(SELECT
	 SUM(amount) as total,
	 DATE(payment_date),
	 EXTRACT(dow from payment_date) as weekday
	 FROM payment
	 WHERE EXTRACT(dow from payment_date)=0
	 GROUP BY DATE(payment_date),weekday) daily
-- sum amount group by date and a column add a collumn dow by using extract where extract a dow 
	--  we need column date to group by every different sunday and we need column extract dow to get all the sunday in where
	
-- Question 11:
-- Level: Difficult to very difficult
-- Topic: Correlated subquery
-- Task: Create a list of movies - with their length and their replacement cost - that are longer than the average length in each replacement cost group.
-- Question: Which two movies are the shortest on that list and how long are they?
-- Answer: CELEBRITY HORN and SEATTLE EXPECTATIONS with 110 minutes.

SELECT title, length FROM film f1
WHERE length >
(SELECT AVG(length) FROM film f2 
WHERE f1.replacement_cost=f2.replacement_cost)
ORDER BY length ASC


-- Question 12:
-- Level: Very difficult
-- Topic: Uncorrelated subquery
-- Task: Create a list that shows the "average customer lifetime value" grouped by the different districts.
-- Example:
-- If there are two customers in "District 1" where one customer has a total (lifetime) spent of $1000 and the second customer has a total spent of $2000 then the "average customer lifetime spent" in this district is $1500.
-- So, first, you need to calculate the total per customer and then the average of these totals per district.
-- Question: Which district has the highest average customer lifetime value?
-- Answer: Saint-Denis with an average customer lifetime value of 216.54.
select * from customer 
select * from payment 
select * from address

SELECT ROUND(AVG(total), 2) as avg_customer_lifetime_value, district
FROM
(SELECT first_name, last_name, district, SUM(amount) AS total
FROM customer c 
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN payment p ON p.customer_id = c.customer_id
GROUP BY first_name, last_name, district)
GROUP BY district
ORDER BY avg_customer_lifetime_value DESC LIMIT 1


-- Question 13:
-- Level: Very difficult
-- Topic: Correlated query
-- Task: Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.
-- Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?
-- Answer: Total revenue in the category 'Action' is 4375.85 and the lowest payment_id in that category is 16055.
 payment_id, amount, and the film category (name) plus the total amount that was made in this category
SELECT * FROM payment --   payment_id, amount, rental_id - connect with rental (1)
SELECT * FROM film_category (4)
SELECT * FROM category (5)
SELECT * FROM rental --  inventory_id - connect with inventory (2)
SELECT * FROM inventory --  film_id -connect with film_category(3)

SELECT title, amount, name, payment_id,
(SELECT SUM(amount) FROM payment p
LEFT JOIN rental r ON r.rental_id=p.rental_id
LEFT JOIN inventory i ON i.inventory_id=r.inventory_id
LEFT JOIN film f ON f.film_id=i.film_id
LEFT JOIN film_category fc ON fc.film_id=f.film_id
LEFT JOIN category c1 ON c1.category_id=fc.category_id
WHERE c1.name=c.name)
FROM payment p
LEFT JOIN rental r ON r.rental_id=p.rental_id
LEFT JOIN inventory i ON i.inventory_id=r.inventory_id
LEFT JOIN film f ON f.film_id=i.film_id
LEFT JOIN film_category fc ON fc.film_id=f.film_id
LEFT JOIN category c ON c.category_id=fc.category_id
ORDER BY name


-- Bonus question 14:
-- Level: Extremely difficult
-- Topic: Correlated and uncorrelated subqueries (nested)
-- Task: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).
-- Question: Which is the top-performing film in the animation category?
SELECT * FROM payment --   payment_id, amount, rental_id - connect with rental (1)
SELECT * FROM film_category (4)
SELECT * FROM category (5)
SELECT * FROM rental --  inventory_id - connect with inventory (2)
SELECT * FROM inventory --  film_id -connect with film_category(3)
SELECT title, name, SUM(amount) AS total
FROM payment p
LEFT JOIN rental r ON r.rental_id=p.rental_id
LEFT JOIN inventory i ON i.inventory_id=r.inventory_id
LEFT JOIN film f ON f.film_id=i.film_id
LEFT JOIN film_category fc ON fc.film_id=f.film_id
LEFT JOIN category c ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) = 
	(SELECT MAX(total)
	FROM (SELECT title, name,SUM(amount) as total
	FROM payment p
	LEFT JOIN rental r ON r.rental_id=p.rental_id
	LEFT JOIN inventory i ON i.inventory_id=r.inventory_id
	LEFT JOIN film f ON f.film_id=i.film_id
	LEFT JOIN film_category fc ON fc.film_id=f.film_id
	LEFT JOIN category c1 ON c1.category_id=fc.category_id
	GROUP BY name,title) sub
	WHERE c.name=sub.name)
