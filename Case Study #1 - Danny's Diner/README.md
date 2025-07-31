# Case Study #1: Danny's Diner

### Business Task
1. Write SQL queries to help the owner analyze his customers including visiting patterns, customer spending habits, and favorite menu items.
2. Use the insights to make decisions around expanding the existing customer loyalty program.
3. Generate basic datasets for the team to inspect on their own without writing SQL.

### Case Study Questions
1. What is the total amount each customer spent at the restaurant?
```sql
SELECT
  	sales.customer_id,
    SUM(menu.price) as Total_Spend
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id

| customer_id | total_spend |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |
```

2. How many days has each customer visited the restaurant?
```sql
SELECT
  	sales.customer_id,
    COUNT(DISTINCT order_date) as days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |
```


3. What was the first item from the menu purchased by each customer?
```sql
SELECT
  customer_id,
  product_name,
  order_date
FROM (
  SELECT 
   customer_id,
   product_name, 
   order_date,
   RANK() OVER(PARTITION BY customer_id ORDER BY order_date) as rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id) as ranked_dates
WHERE rank = 1

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-01 |
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |
```


4. What is the most purchased item on the menu and how many times was it purchased by all customers?
``` sql
SELECT
  menu.product_name,
  COUNT(sales.product_id) AS purchase_count
FROM dannys_diner.sales
JOIN 
  dannys_diner.menu 
  ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY purchase_count DESC

| product_name | purchase_count |
| ------------ | -------------- |
| ramen        | 8              |
| curry        | 4              |
| sushi        | 3              |
```

5. Which item was the most popular for each customer?
```sql
SELECT
  customer_id,
  product_name,
  product_count
FROM (
  SELECT 
    customer_id,
    product_name,
    COUNT(product_name) as product_count,
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_name) DESC)
  FROM dannys_diner.sales 
  JOIN dannys_diner.menu ON sales.product_id = menu.product_id
  GROUP BY customer_id, product_name) as ranked
WHERE rank = 1

| customer_id | product_name | product_count |
| ----------- | ------------ | ------------- |
| A           | ramen        | 3             |
| B           | ramen        | 2             |
| B           | curry        | 2             |
| B           | sushi        | 2             |
| C           | ramen        | 3             |
```
6. Which item was purchased first by the customer after they became a member?

```sql
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

| customer_id | product_name | join_date  | order_date |
| ----------- | ------------ | ---------- | ---------- |
| A           | ramen        | 2021-01-07 | 2021-01-10 |
| B           | sushi        | 2021-01-09 | 2021-01-11 |
```

7. Which item was purchased just before the customer became a member?
```sql
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

| customer_id | product_name | join_date  | order_date |
| ----------- | ------------ | ---------- | ---------- |
| A           | sushi        | 2021-01-07 | 2021-01-01 |
| A           | curry        | 2021-01-07 | 2021-01-01 |
| B           | sushi        | 2021-01-09 | 2021-01-04 |
```

8. What is the total items and amount spent for each member before they became a member?
```sql
SELECT
  sales.customer_id,
  COUNT(product_name) as total_items,
  SUM(price) as total_spend
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
WHERE order_date < join_date
GROUP BY sales.customer_id

| customer_id | total_items | total_spend |
| ----------- | ----------- | ----------- |
| B           | 3           | 40          |
| A           | 2           | 25          |
```
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?