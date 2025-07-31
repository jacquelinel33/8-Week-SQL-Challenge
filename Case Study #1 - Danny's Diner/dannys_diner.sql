CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- returns total amount each customer spent
SELECT
  sales.customer_id,
  SUM(menu.price) as Total_Spend
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id

-- returns number of distinct days a customers has visited
SELECT
  sales.customer_id,
  COUNT(DISTINCT order_date) as days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id

--returns the first menu item ordered by each customer
SELECT
  customer_id,
  product_name,
  order_date,
FROM (
  SELECT 
   customer_id,
   product_name, 
   order_date,
   RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id) as ranked_dates
WHERE rank = 1

--What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  menu.product_name,
  COUNT(sales.product_id) AS purchase_count
FROM dannys_diner.sales
JOIN 
  dannys_diner.menu 
  ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY purchase_count DESC

-- Counts # of orders by customer and product name
SELECT
  customer_id,
  product_name,
  product_count
FROM (
  SELECT 
    customer_id,
    product_name,
    COUNT(product_name) as product_count,
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) as rank
  FROM dannys_diner.sales 
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id
  GROUP BY customer_id, product_name) as ranked
WHERE rank = 1

--6. Which item was purchased first by the customer after they became a member?
SELECT
  customer_id,
  product_name,
  join_date,
  order_date
FROM
  (SELECT 
    sales.customer_id,
    product_name,
    join_date,
    order_date,
    RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date) as rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id
  LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
  WHERE order_date > join_date) as ranked
WHERE rank = 1 

--7. Which item was purchased just before the customer became a member?
SELECT
  customer_id,
  product_name,
  join_date,
  order_date
FROM
  (SELECT 
    sales.customer_id,
    product_name,
    join_date,
    order_date,
    RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC) as rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id
  LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
  WHERE order_date < join_date) as ranked
WHERE rank = 1 

--8. What is the total items and amount spent for each member before they became a member?
SELECT
  sales.customer_id,
  COUNT(product_name) as total_items,
  SUM(price) as total_spend
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
WHERE order_date < join_date
GROUP BY sales.customer_id

--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
  sales.customer_id,
SUM(
  CASE 
    WHEN menu.product_name != 'sushi' THEN (menu.price * 10)
  ELSE (menu.price * 20) 
  END
) AS points
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
GROUP BY sales.customer_id
--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?







