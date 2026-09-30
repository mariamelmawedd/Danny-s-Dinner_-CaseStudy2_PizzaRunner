
-- RUNNERS TABLE
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date) VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


-- CUSTOMER ORDERS TABLE
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(50),
  extras VARCHAR(50),
  order_time DATETIME
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


-- RUNNER ORDERS TABLE
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(20),
  distance VARCHAR(20),
  duration VARCHAR(20),
  cancellation VARCHAR(50)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', NULL);


-- PIZZA NAMES TABLE
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name VARCHAR(50)
);

INSERT INTO pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


-- PIZZA RECIPES TABLE
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(200)
);

INSERT INTO pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


-- PIZZA TOPPINGS TABLE
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name VARCHAR(50)
);

INSERT INTO pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

select * from runners;


update customer_orders set exclusions = NULL where exclusions = '' or exclusions = 'null';
update customer_orders set extras= NULL where extras= '' or extras= 'null';

select * from customer_orders;

update runner_orders set cancellation= NULL
where cancellation="";

UPDATE runner_orders
SET duration = CASE
    WHEN duration IS NULL THEN NULL
    ELSE CONCAT(REGEXP_REPLACE(duration, '[^0-9]', ''), ' minutes')
END;

UPDATE runner_orders
SET distance = CASE
    WHEN distance IS NULL THEN NULL
    ELSE CONCAT(REGEXP_REPLACE(distance, '[^0-9.]', ''), ' km')
END;

select * from runner_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

/* ============================
   A. PIZZA METRICS
   ============================ */

-- 1. How many pizzas were ordered?

select count(pizza_id) as nb_pizzas from customer_orders;

-- 2. How many unique customer orders were made?

select count(distinct(order_id)) as unique_customers_orders from customer_orders;

-- 3. How many successful orders were delivered by each runner?

select runner_id, count(order_id) as nb_orders from runner_orders
where cancellation is NUll group by runner_id; 

-- 4. How many of each type of pizza was delivered?

select pizza_id ,count(*) from( select c.order_id, c.pizza_id, r.runner_id, r.cancellation from customer_orders as c 
left join runner_orders as r on c.order_id=r.order_id where cancellation is null) as t1 group by pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, sum(CASE
  WHEN pizza_name='Vegetarian' THEN 1 ELSE 0 END) as count_veg, sum(CASE
    WHEN pizza_name='Meatlovers' THEN 1 ELSE 0 END) as count_meat from (select c.customer_id, c.pizza_id, p.pizza_name from customer_orders as c 
left join pizza_names as p on c.pizza_id=p.pizza_id) as t1  group by customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?

select max(count) as max_nb_pizzas from (
select count(c.pizza_id) as count, c.order_id from customer_orders as c left join 
runner_orders as r on c.order_id=r.order_id where r.pickup_time is not null group by c.order_id) as t1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id, sum(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_change,
sum(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS changee from customer_orders as c 
  left join runner_orders as r on c.order_id=r.order_id where cancellation is NULL group by customer_id; 


-- 8. How many pizzas were delivered that had both exclusions and extras?

select 
sum(CASE WHEN exclusions IS NOT NULL and extras IS NOT NULL THEN 1 ELSE 0 END) AS changee from customer_orders as c 
  left join runner_orders as r on c.order_id=r.order_id where cancellation is NULL ; 



-- 9. What was the total volume of pizzas ordered for each hour of the day?

select hour(order_time), count(pizza_id) from customer_orders group by hour(order_time);



-- 10. What was the volume of orders for each day of the week?


select date_format(order_time, '%W') as weekday_name, count(order_id) from customer_orders group by weekday_name ORDER BY FIELD(weekday_name,
'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');




/* ============================
   B. RUNNER & CUSTOMER EXPERIENCE
   ============================ */

-- 11. How many runners signed up for each 1 week period (week starts 2021-01-01)?

select floor(datediff(registration_date, '2021-01-01')/7)+1 as week_number, count(runner_id) as count_runner
from runners group by week_number; 

-- 12. What was the average time in minutes for each runner to arrive at HQ for pickup?


select r.runner_id, avg(timestampdiff(minute, o.order_time, r.pickup_time)) as avg_minutes
from runner_orders r
join (select distinct order_id, order_time from customer_orders) o on o.order_id = r.order_id
where r.pickup_time is not null
group by r.runner_id;


-- 13. Is there any relationship between number of pizzas and preparation time?

select c.order_id, count(c.pizza_id) as count_pizza, timestampdiff(minute,c.order_time,r.pickup_time) as prep_time 
from customer_orders as c left join runner_orders as r on c.order_id=r.order_id where r.pickup_time is NOT NULL group by c.order_id, c.order_time, r.pickup_time;

-- 14. What was the average distance travelled for each customer?

select customer_id, avg(distance) as avg_distance from (
  select distinct c.customer_id, c.order_id,
         cast(replace(r.distance, ' km', '') as decimal(10,2)) as distance
  from customer_orders c
  join runner_orders r on r.order_id = c.order_id
  where r.pickup_time is not null
) t group by customer_id;





-- 15. What is the difference between the longest and shortest delivery times?

select (maxx-minn) as diff_time from (
select max(duration) as maxx, min(duration) as minn from runner_orders) as t1;

-- 16. What was the average speed for each runner for each delivery?

select order_id, runner_id, avg(distance / (duration/60)) as avg_speed from runner_orders where pickup_time is not null group by order_id, runner_id;

-- 17. What is the successful delivery percentage for each runner?

select runner_id, (sum(CASE WHEN pickup_time is not null then 1 else 0 END)/count(order_id)) *100 as succ from runner_orders group by runner_id;


/* ============================
   C. INGREDIENT OPTIMISATION
   ============================ */

-- 18. What are the standard ingredients for each pizza?

select pr.pizza_id, group_concat(pt.topping_name order by pt.topping_name separator ', ') as ingredients
from pizza_recipes as pr
join pizza_toppings as pt on find_in_set(pt.topping_id, replace(pr.toppings, ' ', '')) > 0
group by pr.pizza_id;

-- 19. What was the most commonly added extra?

select pt.topping_name, count(*) as added_extras from 
customer_orders as c join pizza_toppings as pt on find_in_set(pt.topping_id, replace(c.extras,' ',''))>0
group by pt.topping_name order by added_extras desc limit 1;

-- 20. What was the most common exclusion?

select pt.topping_name, count(*) as exclusion from 
customer_orders as c join pizza_toppings as pt on find_in_set(pt.topping_id, replace(c.exclusions,' ',''))>0
group by pt.topping_name order by exclusion desc;

-- 21. Generate an order item description for each customer order.

select c.customer_id, c.order_id, c.pizza_id, p.pizza_name,
(select group_concat(pt.topping_name order by pt.topping_name separator ', ') from pizza_toppings as pt left join pizza_recipes as pr
on pr.pizza_id=p.pizza_id where find_in_set(pt.topping_id, replace(pr.toppings,' ',''))>0 and
 find_in_set(pt.topping_id, replace(ifnull(c.exclusions,''), ' ', '')) = 0 ) as toppings ,
(select group_concat(pt.topping_name order by pt.topping_name separator ', ') from pizza_toppings as pt
where find_in_set(pt.topping_id, replace(ifnull(c.extras,''), ' ','')) >0 )as extra_toppings,( select group_concat(pt.topping_name order by pt.topping_name separator ', ') from pizza_toppings as pt
where find_in_set(pt.topping_id, replace(ifnull(c.exclusions,''), ' ','')) >0) as exclusion_topping
 from customer_orders as c 
left join pizza_names as p on c.pizza_id=p.pizza_id;

-- 22. Generate alphabetically ordered ingredient list for each pizza order (with 2x for duplicates).

select c.order_id, c.pizza_id, (select group_concat(CASE
  when find_in_set(pt.topping_id, replace(pr.toppings, ' ', '')) > 0 
  and find_in_set(pt.topping_id, replace(ifnull(c.exclusions,''), ' ', '')) = 0 
  and find_in_set(pt.topping_id, replace(ifnull(c.extras,''), ' ', '')) > 0 then concat('2x', pt.topping_name)
  else pt.topping_name
end
order by pt.topping_name separator ', ') as toppings 
from pizza_toppings as pt left join pizza_recipes as pr on pr.pizza_id= c.pizza_id where find_in_set(pt.topping_id, replace(pr.toppings,' ',''))>0 and
find_in_set(pt.topping_id, replace(ifnull(c.exclusions,''), ' ', '')) = 0 
or find_in_set(pt.topping_id, replace(ifnull(c.extras,''), ' ', '')) > 0 ) as toppings  from customer_orders as c;

-- 23. What is the total quantity of each ingredient used in all delivered pizzas (sorted by most frequent)?

with all_toppings as (

  select c.order_id, pt.topping_name
  from customer_orders c
  join runner_orders r on r.order_id = c.order_id
  join pizza_recipes pr on pr.pizza_id = c.pizza_id
  join pizza_toppings pt
    on find_in_set(pt.topping_id, replace(pr.toppings, ' ', '')) > 0
  where r.pickup_time is not null
    and find_in_set(pt.topping_id, replace(ifnull(c.exclusions, ''), ' ', '')) = 0

  union all
  select c.order_id, pt.topping_name
  from customer_orders c
  join runner_orders r on r.order_id = c.order_id
  join pizza_toppings pt
    on find_in_set(pt.topping_id, replace(ifnull(c.extras, ''), ' ', '')) > 0
  where r.pickup_time is not null
)
select topping_name, count(*) as total_quantity
from all_toppings
group by topping_name
order by total_quantity desc;

/* ============================
   D. PRICING & RATINGS
   ============================ */

-- 24. Total revenue with Meat Lovers = $12, Vegetarian = $10, no extra charges.

select sum(CASE when pizza_name='Meatlovers' then 12 else 10 end) as total_revenue
from customer_orders as c left join pizza_names as p on c.pizza_id=p.pizza_id 
join runner_orders r on r.order_id = c.order_id
where r.pickup_time is not null;


-- 25. Revenue if extras cost $1 each (cheese also $1 extra).

select sum(pizza_price+extra_count) as total_revenue_extras from (
select c.order_id, (case when extras is null then 0 else length(extras) - length(replace(extras, ',', '')) + 1 end) as extra_count, 
case when pizza_name='Meatlovers' then 12 else 10 end as pizza_price 
from customer_orders as c left join pizza_names as p on p.pizza_id=c.pizza_id 
join runner_orders r on r.order_id = c.order_id
where r.pickup_time is not null) as t1;
 

-- 26. Create a ratings table schema and insert sample ratings (1–5).

create table ratings (
  rating_id int primary key auto_increment,
  order_id int,
  customer_id int,
  runner_id int, 
  rating int

);

insert into ratings (order_id, customer_id, runner_id, rating)
select c.order_id, c.customer_id, r.runner_id, floor(1+rand()*5) as rating from 
customer_orders as c left join runner_orders as r on c.order_id=r.order_id where r.pickup_time is not NULL group by c.order_id, c.customer_id, r.runner_id;
select * from ratings;


-- 27. Join all delivery information + ratings into one final table:
--     customer_id, order_id, runner_id, rating, order_time, pickup_time,
--     time between order & pickup, delivery duration, average speed,
--     total number of pizzas.



select r.customer_id, r.order_id, r.runner_id, r.rating, c.order_time, rr.pickup_time,
timestampdiff(minute,c.order_time,rr.pickup_time) as prep_time, rr.duration, avg(rr.distance / (rr.duration/60)) as avg_speed,
count(c.pizza_id) as total_pizzas from ratings as r left join customer_orders as c on r.order_id=c.order_id 
left join runner_orders as rr on r.order_id=rr.order_id where rr.pickup_time is not NULL group by r.customer_id, r.order_id, r.runner_id, r.rating, c.order_time, rr.pickup_time, rr.distance, rr.duration
order by r.order_id;

-- 28. Calculate remaining money after paying runners $0.30 per km.

with revenue_extras as (
  select c.order_id, (case when extras is null then 0 else length(extras) - length(replace(extras, ',', '')) + 1 end) as extra_count, 
  case when pizza_name='Meatlovers' then 12 else 10 end as pizza_price 
  from customer_orders as c left join pizza_names as p on p.pizza_id=c.pizza_id 
  join runner_orders r on r.order_id = c.order_id where r.pickup_time is not null
),

total_revenue as (
  select sum(pizza_price+extra_count) as total_revenue from revenue_extras
), 
runner_salary as (
  select sum(cast(replace(distance, ' km', '') as decimal (10,2))) *0.30 as salary from 
  runner_orders where pickup_time is not null
)

select tr.total_revenue- rs.salary as revenue_left from total_revenue as tr, runner_salary as rs;



-- perrunner
select runner_id, sum(cast(replace(distance, 'km', '') as decimal (10,2))) *0.30 as salary from 
  runner_orders where pickup_time is not null group by runner_id;

