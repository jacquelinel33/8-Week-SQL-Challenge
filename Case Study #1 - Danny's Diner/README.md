# Case Study #1: Danny's Diner

### Business Task
1. Write SQL queries to help the owner analyze his customers including visiting patterns, customer spending habits, and favorite menu items.
2. Use the insights to make decisions around expanding the existing customer loyalty program
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
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?