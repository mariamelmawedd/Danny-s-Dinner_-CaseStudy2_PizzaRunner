# Danny-s-Dinner_-CaseStudy2_PizzaRunner

# Pizza-Runner_-CaseStudy-2

# 8 Week SQL Challenge — Case Study #2 (Pizza Runner)

🔗 Original challenge: [8weeksqlchallenge.com/case-study-2](https://8weeksqlchallenge.com/case-study-2/)

## About the project

Pizza Runner is a pizza delivery business where customers order Meat Lovers or Vegetarian pizzas, freelance runners deliver them, and some orders get cancelled. 
The goal is to clean the messy data and answer business questions to help improve operations. 
This case study works through 28 questions using six tables (`runners`, `customer_orders`, `runner_orders`, `pizza_names`, `pizza_recipes`, `pizza_toppings`), covering things like:
- Pizza volumes, delivered orders and orders with extras or exclusions
- Runner pickup times, distance, speed and delivery success rate
- Standard ingredients, most common extras and exclusions, and total ingredient quantities
- Revenue with and without extras, a new ratings table, and how much money is left after paying runners

It's a practical exercise in data cleaning, joins, string functions and CTEs on a realistic relational dataset.

## Tools

SQL (MySQL syntax), using `WITH` (CTEs), `FIND_IN_SET`, `CAST`, `REPLACE`, `GROUP_CONCAT` and `CASE WHEN`.

## Files

[`pizza_runner.sql`](./pizza_runner.sql)

## Key learnings

- Cleaned the data before answering anything: turned blank and `'null'` text into real `NULL` values, and removed the text from `distance` and `duration` (like `km` and `minutes`) so they could be used as numbers.
- Used `FIND_IN_SET` to work with columns that store several IDs in one field (like `'1, 5'`), instead of joining on a single value.
- Used `CAST` to change text into numbers so I could calculate averages, speed and runner pay.
- Used `WITH` (CTEs) to split longer queries into steps, for example the total ingredient quantities and the money left after paying runners.
- Learned that `NULL` is never equal to anything, so a `WHERE` condition on a `NULL` value drops the row. `IFNULL` fixes this.
- Learned to watch for duplicated rows, `customer_orders` has one row per pizza, so joining it to per-order data repeats values and changes averages unless you use `DISTINCT` first.
- Practised filtering out cancelled orders for anything about deliveries and revenue.
