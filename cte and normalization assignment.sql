-- First Normal Form (1NF):

-- 1. Identify a table in sakila database that violates 1NF. Explain how would you normalize it to achieve 1NF.
use mavenmovies;



-- Solution 

/* In the sakila database actor_award is a table and in actor_award table has a column name awards 
 awards column is containing more than one values in a cell. So this is breaking the 1NF(first Normal form of atomicity)
 
 So for solving this first we will make a table name awards_name and It will contain award_name
  and actor_award_id as primary key in this table and foreign key for the actor_award table*/

-- Second Normal Form (2NF):

-- 2. Choose a table in sakila and describe how you would determine whether it is in 2NF. If it violetes 2NF
-- explain the steps to normalize it. 

  -- Solution
  
/* If I take actor_award table from sakila database 
 table should have only one primary key (Means every column should dependent on only one key)
So this table is not in 2NF beacause award depends on actor_award_id and first_name , last_name depends on actor_id 

For fixing this we will make a seprate table named actors and it will contain actor_id and first_name , last_name
actor_id will be primary Key for actors and foreign key for awards table  
*/

-- Third Normal Form(3NF):
-- 3. Identify a table in Sakila that violates 3NF. Descibe the transitive dependencies present and outline the 
-- steps to normalize the table to 3NF. 

/* In actor_award table awards are dependent on actor_award_id but this should be dependent on actor_id So these are non key atribute and 
depending on each other So this table is voilating 3NF 

For solving this We will make a seprate table awards and It will contain award_id (primary key , foreign key) 
, awards */

-- Normalization Process:
-- 4. Take a specific table in Sakila and guide through the process of normalizing it from the initial
-- unnormalized form up to at least 2NF. 


/* The "rental" table is already in 1NF because each column contains atomic values, and there are no repeating groups.

2. 2NF (Second Normal Form):
Identify and remove partial dependencies.
Move the attributes that are dependent on only part of the primary key to a new table.
In this case, the primary key of the "rental" table is "rental_id." 

The "rental_date," "inventory_id," and "return_date" depend on the whole primary key.
The "customer_id" and "staff_id" do not depend on the whole primary key.
So, for solving this we need to create two tables to eliminate partial dependencies:


-- rental_info table
CREATE TABLE rental_info (
    rental_id INT PRIMARY KEY,
    rental_date DATETIME,
    inventory_id INT,
    return_date DATETIME
    
);

-- rental_staff table
CREATE TABLE rental_staff (
    rental_id INT PRIMARY KEY,
    staff_id INT,
    last_update DATETIME
    customer_id int
);
Now, the "rental_info" table contains information about the rental itself, and the "rental_staff" table contains information 
about the staff involved in the rental.

*/



-- CTE Basics:
-- 5. Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have
--  acted in from the actor and film_actor tables. 

with actor_acted as(
select a.actor_id,
a.first_name, a.last_name, fa.film_id
 from actor as a 
inner join film_actor as fa 
on a.actor_id = fa.actor_id)

select  first_name , last_name , count(film_id) as film_count from actor_acted group by  actor_id, first_name ,last_name;

-- Recursive CTE:
-- 6. Use a recursive CTE to generate a hierarchical list of categories and their subcategory from the category
-- table in Sakila.

with recursive category_hirarchy as (
select category_id , name 
from category)
select * from category_hirarchy;



-- CTE with Joins:
-- 7. Create a CTE that combines information from the film and language tables to display the film title , language
-- name , and rental rate. 

with film_language_combined as (
select f.title , l.name , f.rental_rate from film as f 
inner join language as l on l.language_id = f.language_id )

select title , name , rental_rate from film_language_combined;

-- CTE for Aggregation:
-- 8. Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from
-- the customer and payment tables. 

with customer_revenue as (
select c.customer_id, c.first_name , c.last_name , p.amount
from customer as c 
inner join 
payment as p on p.customer_id = c.customer_id)

select first_name , last_name, sum(amount) Total_revenue from customer_revenue group by first_name , last_name; 

-- CTE with Window Functions:
-- 9. Utilize a CTE with a window function to rank films based on their rental duration from film table.

with film_rank as( 
select film_id , title , rental_duration
 from film)

select title, rental_duration, rank() over(order by rental_duration) as ranked_rental_duration from film;


-- CTE and Filtering:
-- 10. Create a CTE to list customers who have made more than two rentals, and then join this CTE with the 
-- customer table to retrieve additional customer details. 


WITH customer_rentals AS (
    SELECT
        r.customer_id,
        COUNT(r.rental_id) AS rental_count
    FROM
        rental AS r
    GROUP BY
        r.customer_id
    HAVING
        COUNT(r.rental_id) > 2
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cr.rental_count
FROM
    customer AS c
    INNER JOIN customer_rentals AS cr ON c.customer_id = cr.customer_id;
    
    
-- CTE For Date Calculations:
-- 11. Write a query using CTE to find the total number of rentals made each month, considering the rental_date
-- from rental table. 

with rental_month as (
select rental_id , monthname(rental_date) as month 
from rental)

select month , count(rental_id) as rental_count 
from rental_month group by month;


-- CTE for pivot Operations:
-- 12. Use a CTE to pivot the data from the payment table to display the total payments made by each
-- customer in seprate columns for different payment methods.



WITH Payment_Pivot AS (
  SELECT
    customer_id,
    SUM(amount) AS total_payment
  FROM
    payment
  GROUP BY
    customer_id
)

SELECT *
FROM Payment_Pivot;



-- CTE and Self-Join: 
-- 13. Create a CTE to generate a report showing pairs of actors who have appeared in the same film together,
-- using the film_actor table. 

 


WITH actor_pairs AS (
    SELECT
        fa.actor_id AS actor1_id,
        a.first_name AS actor1_first_name,
        a.last_name AS actor1_last_name,
        fb.actor_id AS actor2_id,
        b.first_name AS actor2_first_name,
        b.last_name AS actor2_last_name,
        f.film_id,
        f.title AS film_title
    FROM
        film_actor AS fa
    JOIN
        actor AS a ON a.actor_id = fa.actor_id 
    JOIN
        film_actor AS fb ON fa.film_id = fb.film_id AND fa.actor_id <> fb.actor_id
    JOIN
        actor AS b ON b.actor_id = fb.actor_id
    JOIN
        film AS f ON fa.film_id = f.film_id
)

SELECT * FROM actor_pairs;             


 -- CTE for Recursive Search: 
 -- 14. Implement a recursive CTE to find all employee in the staff table who report to a specific
 -- manager, considering the reports_to column. 
 select * from staff;
WITH RECURSIVE employee_hierarchy AS (
    
    SELECT 
        s.staff_id, 
        s.first_name, 
        s.last_name
    FROM 
        staff s
    JOIN 
        store st ON s.staff_id = st.manager_staff_id 
    WHERE 
        st.manager_staff_id = 1 

    UNION ALL

    
    SELECT 
        s.staff_id, 
        s.first_name, 
        s.last_name
    FROM 
        staff s
    JOIN 
        employee_hierarchy eh ON s.staff_id = eh.staff_id 
    WHERE
        s.staff_id != eh.staff_id  
)

-- Final selection: Retrieve the complete hierarchy of employees.
SELECT 
    staff_id, 
    first_name, 
    last_name
FROM 
    employee_hierarchy;


  
  