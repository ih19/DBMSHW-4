set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

use `Assignment #4`;

alter table actor add primary key (actor_id);

alter table address add primary key (address_id);

alter table category add primary key (category_id);

alter table city add primary key (city_id);

alter table country add primary key (country_id);

alter table customer add primary key (customer_id);

alter table film add primary key (film_id);

alter table film_actor add primary key (actor_id, film_id);

alter table film_category add primary key (film_id, category_id);

alter table inventory add primary key (inventory_id);

alter table language add primary key (language_id);

alter table payment add primary key (payment_id);

alter table rental add primary key (rental_id);

alter table staff add primary key (staff_id);

alter table store add primary key (store_id);


describe rental;

alter table rental 
modify column rental_date datetime;

alter table rental
add constraint uq_rental unique (rental_date, inventory_id, customer_id);

select table_name, constraint_name, constraint_type
from information_schema.table_constraints
where table_schema = 'assignment_4';

-- add unique constraints (only where “u” was marked)
alter table rental 
add constraint unique_rental unique (rental_date, inventory_id, customer_id);

-- add foreign keys
alter table address add constraint fk_address_city foreign key (city_id) references city(city_id);
alter table city add constraint fk_city_country foreign key (country_id) references country(country_id);
alter table customer add constraint fk_customer_store foreign key (store_id) references store(store_id);
alter table customer add constraint fk_customer_address foreign key (address_id) references address(address_id);
alter table film add constraint fk_film_language foreign key (language_id) references language(language_id);
alter table film_actor add constraint fk_fa_actor foreign key (actor_id) references actor(actor_id);
alter table film_actor add constraint fk_fa_film foreign key (film_id) references film(film_id);
alter table film_category add constraint fk_fc_film foreign key (film_id) references film(film_id);
alter table film_category add constraint fk_fc_category foreign key (category_id) references category(category_id);
alter table rental add constraint fk_rental_inventory foreign key (inventory_id) references inventory(inventory_id);
alter table rental add constraint fk_rental_customer foreign key (customer_id) references customer(customer_id);
alter table rental add constraint fk_rental_staff foreign key (staff_id) references staff(staff_id);
alter table staff add constraint fk_staff_address foreign key (address_id) references address(address_id);
alter table staff add constraint fk_staff_store foreign key (store_id) references store(store_id);
alter table store add constraint fk_store_address foreign key (address_id) references address(address_id);
alter table inventory add constraint fk_inventory_film foreign key (film_id) references film(film_id);
alter table inventory add constraint fk_inventory_store foreign key (store_id) references store(store_id);
alter table payment add constraint fk_payment_customer foreign key (customer_id) references customer(customer_id);
alter table payment add constraint fk_payment_staff foreign key (staff_id) references staff(staff_id);
alter table payment add constraint fk_payment_rental foreign key (rental_id) references rental(rental_id);

-- Query #1: Average Film Length by Category
select category.name as category_name, 
       avg(film.length) as average_length
from category
join film_category on category.category_id = film_category.category_id
join film on film_category.film_id = film.film_id
group by category.name
order by category.name;

# This query finds the average movie length for each film category. 
# It joins the category, film_category, and film tables to connect each movie with its category. 
# The results are grouped by category name and sorted alphabetically.

-- Query #2: Longest and Shortest Average Film Length

-- longest average length
select category.name as category_name, 
       avg(film.length) as average_length
from category
join film_category on category.category_id = film_category.category_id
join film on film_category.film_id = film.film_id
group by category.name
order by average_length desc
limit 1;

-- shortest average length
select category.name as category_name, 
       avg(film.length) as average_length
from category
join film_category on category.category_id = film_category.category_id
join film on film_category.film_id = film.film_id
group by category.name
order by average_length asc
limit 1;

# These two queries show the categories that have the longest and shortest average film lengths. 
# The first orders the averages from highest to lowest and takes the top one, the second does the same but from lowest to highest.

-- Query #3: Customers who Rented Action but not Comedy or Classics
select distinct customer.first_name, customer.last_name
from customer
where customer.customer_id in (
    select rental.customer_id
    from rental
    join inventory on rental.inventory_id = inventory.inventory_id
    join film_category on inventory.film_id = film_category.film_id
    join category on film_category.category_id = category.category_id
    where category.name = 'action'
)
and customer.customer_id not in (
    select rental.customer_id
    from rental
    join inventory on rental.inventory_id = inventory.inventory_id
    join film_category on inventory.film_id = film_category.film_id
    join category on film_category.category_id = category.category_id
    where category.name in ('comedy', 'classics')
)
order by customer.last_name, customer.first_name;

-- This query lists customers who rented at least one action movie but never rented comedy or classic movies. 
-- It uses two subqueries, one to find action renters and another to exclude those who rented comedy or classics.

-- Query #4: Actor who appeared in the most English - Language Movies
select actor.first_name, actor.last_name, count(*) as number_of_movies
from actor
join film_actor on actor.actor_id = film_actor.actor_id
join film on film_actor.film_id = film.film_id
join language on film.language_id = language.language_id
where language.name = 'english'
group by actor.actor_id, actor.first_name, actor.last_name
order by number_of_movies desc
limit 1;

-- This query counts how many english language movies each actor has appeared in. 
-- It groups by actor and sorts from the largest to smallest count, returning the actor with the most english language roles.


-- Query #5: 
select count(distinct inventory.film_id) as number_of_movies
from rental
join inventory on rental.inventory_id = inventory.inventory_id
join staff on inventory.store_id = staff.store_id
where staff.first_name = 'mike'
  and datediff(rental.return_date, rental.rental_date) = 10;
  
  -- This query counts how many different movies were rented for exactly ten days from the store that employee Mike works at. 
  -- It calculates the number of days between the rental and return dates.
  
-- Query #6: Actors who Appeared in Movies with the Largest number of Actors
select actor.first_name, actor.last_name
from actor
join film_actor on actor.actor_id = film_actor.actor_id
where film_actor.film_id = (
    select film_actor.film_id
    from film_actor
    group by film_actor.film_id
    order by count(film_actor.actor_id) desc
    limit 1
)
order by actor.last_name, actor.first_name;

# This query finds the movie that has the largest cast and lists all actors who appeared in it.
# It identifies the film with the highest number of actors using a subquery, then lists those actors alphabetically.
