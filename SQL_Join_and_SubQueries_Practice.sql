use mavenmovies;

-- **Join Practice:**
-- Write a query to display the customer's first name, last name, email, and city they live in.

select * from customer;
select * from address;
select * from city;

SELECT 
    c.first_name, c.last_name, c.email, ci.city
FROM
    customer c
        INNER JOIN
    address a ON c.address_id = a.address_id
        INNER JOIN
    city ci ON a.address_id = ci.city_id; 
    

-- *Subquery Practice (Single Row):**
-- Retrieve the film title, description, and release year for the film that has the longest duration.
select * from film;
select max(length) from film;
SELECT 
    title, description, release_year, length
FROM
    film
WHERE
    length = (SELECT 
            MAX(length)
        FROM
            film);


-- Join Practice (Multiple Joins):**
-- List the customer name, rental date, and film title for each rental made. Include customers
-- who have never rented a film.

select * from customer; -- customer name
select * from rental; -- rental date
select * from inventory; -- film_id
select * from film; -- file title

SELECT 
    c.first_name, c.last_name, r.rental_date, f.title
FROM
    customer c
        left JOIN
    rental r ON c.customer_id = r.customer_id
        left JOIN
    inventory i ON r.inventory_id = i.inventory_id
        left JOIN
    film f ON i.film_id = f.film_id;
    
-- *Subquery Practice (Multiple Rows):**
-- Find the number of actors for each film. Display the film title and the number of actors for each film

select * from film; -- title
select * from film_actor; -- actor_id, film_id

SELECT 
    f.title, COUNT(actor_id) AS actor_count
FROM
    film f
        INNER JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.title;


-- Join Practice (Using Aliases):**
-- Display the first name, last name, and email of customers along with the rental date, film title, and rental return date.
select * from customer; -- first_name, last_name, email
select * from rental; -- rental_date , rental return date
select * from film; -- film title
select * from inventory; -- film id

SELECT 
    c.first_name, c.last_name, c.email, r.rental_date, f.title, r.return_date
FROM
    customer AS c
        INNER JOIN
    rental AS r ON c.customer_id = r.customer_id
        INNER JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
        INNER JOIN
    film AS f ON i.film_id = f.film_id;
    
-- **Subquery Practice (Conditional):**
-- Retrieve the film titles that are rented by customers whose email domain ends with '.net'.
select * from customer;
select customer_id from customer where email like '%.net';
select * from film;
select * from inventory;

SELECT 
    title
FROM
    film
WHERE
    film_id IN ((SELECT 
            film_id
        FROM
            inventory
        WHERE
            store_id IN (SELECT 
                    store_id
                FROM
                    customer
                WHERE
                    email LIKE '%.net')));
                    
                    
-- **Join Practice (Aggregation):**
-- Show the total number of rentals made by each customer, along with their first and last names.
select * from customer; -- first_name, last_name, customer id
select * from payment; -- custoemr id
SELECT 
    c.first_name,
    c.last_name,
    COUNT(p.rental_id) AS count_of_rental
FROM
    customer AS c
        INNER JOIN
    payment AS p ON c.customer_id = p.customer_id
GROUP BY first_name, last_name;


 -- **Subquery Practice (Aggregation):**
-- List the customers who have made more rentals than the average number of rentals made by all customers.

select * from customer;
select * from film;
select * from rental;

SELECT 
    first_name, last_name
FROM
    customer
WHERE
    customer_id IN (SELECT 
            customer_id
        FROM
            rental
        GROUP BY customer_id
        HAVING COUNT(rental_id) > (SELECT 
                AVG(rental_count)
            FROM
                (SELECT 
                    COUNT(rental_id) AS rental_count
                FROM
                    rental
                GROUP BY customer_id) AS avg_rentals));


-- Display the customer first name, last name, and email along with the names of other customers living in the same city.
select * from customer;
select * from address;

SELECT 
    c.first_name, c.last_name, c.email, c2.first_name as other_first_name, c2.last_name as other_last_name
FROM
    customer c
        INNER JOIN
    address a ON c.address_id = a.address_id
        INNER JOIN
    address a2 ON a.city_id = a2.city_id
        AND a.address_id != a2.address_id
        INNER JOIN
    customer c2 ON c2.address_id = a2.address_id;
    

-- **Subquery Practice (Correlated Subquery):**
-- Retrieve the film titles with a rental rate higher than the average rental rate of films in the same category.

select * from film;
select avg(rental_rate) from film;
select * from film_category;
select * from category;
SELECT 
    title, rental_rate
FROM
    film f
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate) from film);
            

-- Retrieve the film titles along with their descriptions and lengths that have a rental rate greater
-- than the average rental rate of films released in the same year

select * from film; -- title descrption lenght
select avg(rental_rate) from film;
SELECT 
    title, description, length, release_year
FROM
    film as f
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film
        WHERE
            release_year = f.release_year);
            

-- **Subquery Practice (IN Operator):**
-- List the first name, last name, and email of customers who have rented at least one film in the 'Documentary' category.
select * from customer;
select * from rental;
select * from inventory;
select * from category;
select * from film_category;

SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    customer_id IN (SELECT 
				c.customer_id
        FROM
				customer c
                INNER JOIN
            rental r ON c.customer_id = r.customer_id
                INNER JOIN
            inventory i ON r.inventory_id = i.inventory_id
                INNER JOIN
            film_category fc ON i.film_id = fc.film_id
                INNER JOIN
            category ca ON fc.category_id = ca.category_id where ca.name = 'Documentary');


-- Show the title, rental rate, and difference from the average rental rate for each film
select * from film;
select avg(rental_rate) from film;

SELECT 
    title, rental_rate, (SELECT 
            AVG(rental_rate)
        FROM
            film) - rental_rate as differance
FROM
    film;
    
-- Retrieve the titles of films that have never been rented.

select * from film;

SELECT 
    title
FROM
    film
WHERE
    film_id NOT IN (SELECT DISTINCT
            film_id
        FROM
            inventory
        WHERE
            film_id IS NOT NULL);

-- List the titles of films whose rental rate is higher than the average rental rate of films released
-- in the same year and belong to the 'Sci-Fi' category.

SELECT 
    title
FROM
    film f
WHERE
    rental_rate > (SELECT 
            AVG(rental_rate)
        FROM
            film
        WHERE
            release_year = f.release_year)
        AND film_id IN (SELECT 
            fc.film_id
        FROM
            film_category fc
                JOIN
            category c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Sci-Fi');
            
-- Find the number of films rented by each customer, excluding customers who have rented fewer than five films.

SELECT 
    customer_id, COUNT(rental_id) AS film_count
FROM
    rental
GROUP BY customer_id
HAVING COUNT(rental_id) >= 5;