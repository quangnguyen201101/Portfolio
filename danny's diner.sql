--total amount for each customer--
SELECT customer_id, SUM(price) AS total_spent
FROM sales join menu on sales.product_id = menu.product_id
GROUP BY customer_id;

--How many days has each customer visited the restaurant?--
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;

--What was the first item from the menu purchased by each customer?--
SELECT distinct customer_id, MIN(order_date) AS first_visit, product_name AS first_item
FROM sales join menu on sales.product_id = menu.product_id
GROUP BY customer_id, product_name;

--What is the most purchased item on the menu and how many times was it purchased by all customers?--
SELECT menu.product_name, COUNT(menu.product_id) AS total_purchases
FROM menu join sales on sales.product_id = menu.product_id
GROUP BY  product_name
ORDER BY total_purchases DESC
LIMIT 1;

--Which item was the most popular for each customer?--
WITH cte_most_popular AS (
SELECT sales.customer_id ,menu.product_name, count(menu.product_id) as time_purchased,
RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(menu.product_id) DESC) AS popular_rank
FROM sales JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id, product_name
)
SELECT customer_id, product_name, time_purchased
FROM cte_most_popular
where popular_rank =1

--Which item was purchased first by the customer after they became a member? --	
select sales.customer_id, menu.product_name, min(order_date) as first_purchase, join_date
from sales join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where order_date >= join_date
group by sales.customer_id, product_name
HAVING COUNT(*) =1;

--Which item was purchased just before the customer became a member? --
select sales.customer_id, menu.product_id, product_name, max(order_date) as first_purchase, join_date
from sales join members on sales.customer_id = members.customer_id
join menu on sales.product_id = menu.product_id
where order_date < join_date
group by sales.customer_id, product_id
HAVING COUNT(*) =1;

--What is the total items and amount spent for each member before they became a member?--
SELECT members.customer_id, COUNT(menu.product_id) AS total_items, SUM(menu.price) AS total_spent
FROM members
JOIN sales ON sales.customer_id = members.customer_id
JOIN menu ON sales.product_id = menu.product_id
WHERE order_date < join_date
GROUP BY sales.customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?--	
WITH cte_member_points AS (
SELECT members.customer_id,
		SUM(
			CASE
				WHEN menu.product_name = 'sushi' THEN (menu.price * 20)
				ELSE (menu.price * 10)
			END
		) AS membership_points
	FROM members
		JOIN sales ON sales.customer_id = members.customer_id
		JOIN menu  ON sales.product_id = menu.product_id
	GROUP BY customer_id
)
SELECT *
FROM cte_member_points
Question 10: 
WITH cte_member_points AS (
	SELECT members.customer_id,
		SUM(
			CASE
				WHEN order_date < join_date THEN 
					CASE
						WHEN menu.product_name = "sushi" THEN (menu.price * 20)
						ELSE (menu.price * 10)
					END
				WHEN order_date - join_date >6 THEN 
					CASE
						WHEN menu.product_name = "sushi" THEN (menu.price * 20)
						ELSE (menu.price * 10)
					END
				ELSE (menu.price * 20)
			END
		) AS membership_points
	FROM members 
		JOIN sales ON sales.customer_id = members.customer_id
		JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date <= '2021-01-31'
	GROUP BY customer_id
)
SELECT *
FROM cte_member_points
ORDER BY customer_id;

