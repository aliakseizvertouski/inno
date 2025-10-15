--1
select category.name, count (*) as film_count
from film_category 
join film on film.film_id=film_category.film_id
join category on category.category_id=film_category.category_id
group by category.name
order by (film_count) desc

--2 upd
with rental_film_actor as (
	select count (rental_id), first_name, last_name
	from rental
	join inventory using (inventory_id)
	join film_actor using (film_id)
	join actor using (actor_id)
	group by actor_id, first_name, last_name
	order by count desc
	limit 10
	)
select first_name, last_name
from rental_film_actor

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
select title
from film
left join inventory on film.film_id = inventory.film_id
where inventory.film_id is null

--5upd
with film_actor_category as (
	select first_name, last_name, count (film_id) as film_count,
		dense_rank () over (order by count (film_id) desc) as rnk
	from actor
	join film_actor using (actor_id)
	join film using (film_id)
	join film_category using (film_id)
	join category using (category_id)
	where name  = 'Children'
	group by actor_id, first_name, last_name
	order by film_count desc
	)
select first_name, last_name, film_count, rnk
from film_actor_category
where rnk < 4

--6upd
select city,
	count (case 
		when active = 1 then null
		else active = 1
	end) as inactive_customers,
	count (case 
		when active = 0 then null
		else active 
	end) as active_customers
from customer
join address using (address_id)
join city using (city_id)
group by city
order by inactive_customers desc

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