--1
select category.name, count (*) as film_count
from film_category 
join film on film.film_id=film_category.film_id
join category on category.category_id=film_category.category_id
group by category.name
order by (film_count) desc

--2
select count (film_id) as rental_count, actor.first_name, actor.last_name
from film_actor
join actor on actor.actor_id=film_actor.actor_id
group by actor.first_name, actor.last_name
order by count (film_id) desc
limit 10


--3
select SUM (amount), name
from payment
join rental using (rental_id)
join inventory using (inventory_id)
join film_category using (film_id)
join category using (category_id)
group by category_id, name
order by sum desc 
limit 1


--4
select title --, film.film_id as film_film_id, inventory.film_id as inventory_film_id
from film
left join inventory on film.film_id = inventory.film_id
where inventory.film_id is null


--5.1
select film_actor.actor_id, count (category_id) as film_count
from film_actor
join film_category on film_category.film_id = film_actor.film_id
where category_id = 3
group by film_actor.actor_id 
order by film_count desc 
limit 3


--5.2
select first_name, last_name, film_count
from actor
join (
	select film_actor.actor_id, count (category_id) as film_count
	from film_actor
	join film_category on film_category.film_id = film_actor.film_id
	where category_id = 3
	group by film_actor.actor_id 
) using (actor_id)
order by film_count desc 
limit 3


--6
select city.city, inactive_customers, active_customers
from city
left join (
	select count (active) as inactive_customers, city.city
	from customer
	join address on customer.address_id=address.address_id 
	join city on address.city_id=city.city_id
	where active = 0
	group by city
) using (city)
left join (
	select count (active) as active_customers, city.city
	from customer
	join address on customer.address_id=address.address_id 
	join city on address.city_id=city.city_id
	where active = 1
	group by city
) using (city)
order by inactive_customers asc


--7
with rental_hours as (
	select city, name as category_name, extract(epoch from (return_date-rental_date))/3600 as hours
	from rental
	join customer using (customer_id)
	join address using (address_id)
	join city using (city_id)
	join inventory using (inventory_id)
	join film_category using (film_id)
	join category using (category_id)
	where city ilike 'a%' or city like '%-%'
),
category_totals as (
	select city, category_name, sum(hours) as total_hours,
	rank()over (partition by city order by sum (hours) desc) as rnk
	from rental_hours
	group by city, category_name
)
(select city, category_name, total_hours
from category_totals
where rnk = 1 and city like '%-%'
order by total_hours desc
limit 1)
union 
(select city, category_name, total_hours
from category_totals
where rnk = 1 and city ilike 'a%'
order by total_hours desc
limit 1)