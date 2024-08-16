-- 1. Retrieve the total number of orders placed.

SELECT 
    COUNT(*) as total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- 3. Identify the highest-priced pizza.
SELECT 
    name
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
ORDER BY price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.

SELECT size
    FROM
	order_details o
    LEFT JOIN pizzas p ON o.pizza_id = p.pizza_id
GROUP BY size
ORDER BY COUNT(size) DESC
LIMIT 1;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, SUM(quantity) AS total_qty
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY total_qty DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(quantity) AS Quantity
FROM
    order_details
        LEFT JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY category
ORDER BY Quantity DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    COUNT(order_id), HOUR(order_time) AS hour_of_day
FROM
    pizzahut.orders
GROUP BY hour_of_day;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(*) AS count_category
FROM
    pizza_types
GROUP BY category
ORDER BY count_category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

with daily_qty as(SELECT 
    order_date, SUM(quantity) AS QTY_per_day
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY order_date)

SELECT 
    ROUND(SUM(QTY_per_day) / COUNT(order_date), 0) AS average_pizzas
FROM
    daily_qty

-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT name, SUM(quantity * price) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

with revenue_per_pizza as (SELECT category, sum(quantity*price) as revenue_pizza
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    group by category)
SELECT 
    category,
    ROUND(100 * revenue_pizza / (SELECT 
                    SUM(revenue_pizza)
                FROM
                    revenue_per_pizza),
            2) AS percentage
FROM
    revenue_per_pizza;



-- 12. Analyze the cumulative revenue generated over time.

with revenue_time as (SELECT 
    order_date, SUM(quantity * price) AS revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY order_date)
select order_date,
round(sum(revenue) over(order by order_date),2) as cumulative_revenue
from revenue_time;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with total_revenue as (SELECT 
    category, name, ROUND(SUM(quantity * price), 2) AS revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category, name),
rnk_revenue as (select category, revenue, name, 
dense_rank() over(partition by category order by revenue desc) as rnk
from total_revenue)
SELECT 
    category, name, revenue
FROM
    rnk_revenue
WHERE
    rnk <= 3;

