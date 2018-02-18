USE sakila;

# 1a. Display the first and last names of all actors from the table `actor`. 

SELECT first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 

SELECT upper(concat(actor.first_name, ' ', actor.last_name)) AS 'Actor Name' FROM actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
  	
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';    
    
# 2b. Find all actors whose last name contain the letters `GEN`:

SELECT * FROM actor WHERE last_name LIKE '%GEN%';
  	
# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country WHERE country in ('Afghanistan', 'Bangladesh', 'China');

# 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.

ALTER TABLE actor ADD middle_name varchar(45) AFTER first_name;
  	
# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.

ALTER TABLE actor MODIFY middle_name BLOB;

# 3c. Now delete the `middle_name` column.

ALTER TABLE actor MODIFY middle_name char(1);
ALTER TABLE actor DROP middle_name;

# 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name) AS 'count last_name' FROM actor GROUP BY last_name;
  	
# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
  	
SELECT last_name, count(last_name) AS 'count last_name' FROM actor GROUP BY last_name HAVING count(last_name) > 1;  
    
# 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
  	
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";
    
# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

SELECT actor_id FROM actor WHERE first_name = "HARPO" and last_name = "WILLIAMS";
UPDATE actor SET first_name = IF(first_name = "HARPO", "GROUCHO", "MUCHO GROUCHO") WHERE actor_id = 172;

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? 

SHOW CREATE TABLE address;
#I commented out the following CREATE statement since this table does not need to be recreated: 
#CREATE TABLE address (
#  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
#  address VARCHAR(50) NOT NULL,
#  address2 VARCHAR(50) DEFAULT NULL,
#  district VARCHAR(20) NOT NULL,
#  city_id SMALLINT UNSIGNED NOT NULL,
#  postal_code VARCHAR(10) DEFAULT NULL,
#  phone VARCHAR(20) NOT NULL,
#  /*!50705 location GEOMETRY NOT NULL,*/
#  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  PRIMARY KEY  (address_id),
#  KEY idx_fk_city_id (city_id),
#  /*!50705 SPATIAL KEY `idx_location` (location),*/
#  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
#)ENGINE=InnoDB DEFAULT CHARSET=utf8;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT a.first_name, a.last_name, b.address FROM staff a JOIN address b ON a.address_id=b.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 

SELECT concat(a.first_name, ' ', a.last_name) as 'Associate', b.TotalSales FROM staff a 
JOIN (SELECT staff_id, SUM(amount) AS 'TotalSales' FROM payment GROUP BY staff_id) b
ON a.staff_id=b.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT a.title, count(b.actor_id) AS 'total_actors' FROM film a JOIN film_actor b ON a.film_id=b.film_id GROUP BY a.title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT a.title, count(b.inventory_id) AS 'total_inventory' FROM film a JOIN inventory b ON a.film_id=b.film_id GROUP BY a.title;

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT concat(a.first_name, ' ', a.last_name) AS 'Customer', sum(b.amount) AS 'Total Sales' FROM customer a JOIN payment b
ON a.customer_id=b.customer_id GROUP BY a.customer_id ORDER BY a.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

SELECT a.title FROM film a JOIN language b ON a.language_id=b.language_id WHERE a.title LIKE 'K%' OR 'Q%' AND b.name = "English";

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT concat(d.first_name, ' ', d.last_name) AS 'Actors in Alone Trip'
FROM (SELECT b.actor_id FROM film a JOIN film_actor b ON a.film_id=b.film_id WHERE a.title = "Alone Trip") c
JOIN actor d ON c.actor_id=d.actor_id ;
   
# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT e.first_name, e.last_name, e.email
FROM customer e
JOIN (SELECT c.address_id
	  FROM address c 
	  JOIN (SELECT a.city_id
			FROM city a JOIN country b
			ON a.country_id=b.country_id
			WHERE b.country = "Canada") d
		ON c.city_id=d.city_id) f
ON e.address_id=f.address_id; 

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT a.title AS 'Family Films' FROM film a JOIN film_category b ON a.film_id=b.film_id WHERE b.category_id = 8;

# 7e. Display the most frequently rented movies in descending order.

SELECT c.title, d.TotalRentals
FROM film c
JOIN (SELECT a.film_id, SUM(b.rentals) as 'TotalRentals'
	  FROM inventory a
	  JOIN (SELECT inventory_id, count(rental_id) AS rentals
			FROM rental
			GROUP BY inventory_id) b
	  ON a.inventory_id=b.inventory_id
	  GROUP BY a.film_id) d
ON c.film_id=d.film_id
ORDER BY TotalRentals DESC;
  	
# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT c.store_id, sum(d.amount) AS 'total_sales'
FROM (SELECT a.inventory_id, a.store_id, b.rental_id
	  FROM inventory a 
	  JOIN rental b
	  ON a.inventory_id=b.inventory_id) c
JOIN payment d
ON c.rental_id=d.rental_id
GROUP BY c.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT e.store_id, f.city, f.country
FROM store e
JOIN (SELECT c.address_id, d.city, d.country
	  FROM address c
	  JOIN (SELECT a.city_id, a.city, b.country
			FROM city a
			JOIN country b
			ON a.country_id=b.country_id) d
	  ON c.city_id=d.city_id) f
ON e.address_id=f.address_id; 
  	
# 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT g.name, sum(h.amount) AS 'sales'
FROM category g
JOIN (SELECT e.category_id, f.amount
	  FROM film_category e
	  JOIN (SELECT c.film_id, d.amount
			FROM inventory c
			JOIN (SELECT a.inventory_id, b.amount
				  FROM rental a 
				  JOIN payment b
				  ON a.rental_id=b.rental_id) d
			ON c.inventory_id=d.inventory_id) f
	  ON e.film_id=f.film_id) h
ON g.category_id=h.category_id
GROUP BY g.name
ORDER BY sales DESC
LIMIT 5;
  	
# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top5_genres AS
SELECT g.name, sum(h.amount) AS 'sales'
FROM category g
JOIN (SELECT e.category_id, f.amount
	  FROM film_category e
	  JOIN (SELECT c.film_id, d.amount
			FROM inventory c
			JOIN (SELECT a.inventory_id, b.amount
				  FROM rental a 
				  JOIN payment b
				  ON a.rental_id=b.rental_id) d
			ON c.inventory_id=d.inventory_id) f
	  ON e.film_id=f.film_id) h
ON g.category_id=h.category_id
GROUP BY g.name
ORDER BY sales DESC
LIMIT 5;
  	
# 8b. How would you display the view that you created in 8a?

SELECT * FROM top5_genres;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top5_genres;
