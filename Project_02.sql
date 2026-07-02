CREATE DATABASE Pizza_Mart;
USE Pizza_Mart;

CREATE TABLE orders (
	order_id INT PRIMARY KEY NOT NULL,
    order_date DATE NOT NULL, 
    oredr_time TIME NOT NULL
);
ALTER TABLE orders RENAME COLUMN oredr_time TO order_time;

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL
);

-- Basic
-- 1.Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- 2.Calculate the total revenue generated from pizza sales.
-- For Beautify the query CTRL+B
SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS Total_Revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id;

-- 3.Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- 4.Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.order_details_id) AS Order_Count
FROM
    pizzas p
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY Order_Count DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(o.quantity) AS Total_Quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY pt.name
ORDER BY Total_Quantity DESC
LIMIT 5;

-- Intermediate
-- 6.Join the necessary tables to find the total quantity of each pizza Category.
SELECT 
    pt.category, SUM(o.quantity) AS Total_Quantity
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY Total_Quantity DESC;

-- 7.Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category
ORDER BY COUNT(NAME) DESC;

-- 9.Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity),0) AS Avg_Pizza_Ordered_Per_Day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS Quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS Order_Quantity;

-- 10.Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 2) AS Total_Sales
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Total_Sales DESC
LIMIT 3;

-- Advanced:--
-- 11.Calculate the percentage contribution of each pizza type to total revenue.
SELECT pt.category ,ROUND(((SUM(od.quantity*p.price)/ (SELECT 
     SUM(od.quantity * p.price) AS Total_Sales
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id))*100),2) 
    AS Total_Revenue_in_Percentage
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    JOIN order_details od ON od.pizza_id=p.pizza_id
GROUP BY pt.category
ORDER BY Total_Revenue_in_Percentage DESC;

-- 12.Analyze the cumulative revenue generated over time.
SELECT order_date ,
SUM(Revenue) OVER (ORDER BY order_date) 
    AS Cumulative_Revenue FROM
    (SELECT o.order_date ,SUM(od.quantity*p.price)
    AS Revenue FROM 
		order_details od 
			JOIN 
		pizzas p ON od.pizza_id=p.pizza_id 
			JOIN 
		orders o ON o.order_id=od.order_id 
GROUP BY o.order_date) AS Sales;


-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name,Revenue FROM 
(SELECT category,name,Revenue,
RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS R_A_N_K
FROM
(SELECT 
    pt.category, pt.name, SUM(od.quantity * p.price) AS Revenue
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category , pt.name) AS Tab_1) AS Tab_2
WHERE R_A_N_K<=3;



