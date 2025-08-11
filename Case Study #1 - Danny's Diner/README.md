# Case Study #1: Danny's Diner

**Source:** [8 Week SQL Challenge - Case Study #1](https://8weeksqlchallenge.com/case-study-1)

### About the Challenge
This case study is part of Danny Ma's 8 Week SQL Challenge series. The scenario involves analyzing customer data for a Japanese restaurant to help with business decisions and customer loyalty program expansion.

### Business Task
1. Write SQL queries to analyze Danny's Diners customers including visiting patterns, customer spending habits, and favorite menu items.
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
```
| customer_id | total_spend |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |


2. How many days has each customer visited the restaurant?
```sql
SELECT
  	sales.customer_id,
    COUNT(DISTINCT order_date) as days_visited
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id
```
| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |


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
```
| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | curry        | 2021-01-01 |
| A           | sushi        | 2021-01-01 |
| B           | curry        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |
| C           | ramen        | 2021-01-01 |


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
```
| product_name | purchase_count |
| ------------ | -------------- |
| ramen        | 8              |
| curry        | 4              |
| sushi        | 3              |


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
```
| customer_id | product_name | product_count |
| ----------- | ------------ | ------------- |
| A           | ramen        | 3             |
| B           | ramen        | 2             |
| B           | curry        | 2             |
| B           | sushi        | 2             |
| C           | ramen        | 3             |


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
```
| customer_id | product_name | join_date  | order_date |
| ----------- | ------------ | ---------- | ---------- |
| A           | ramen        | 2021-01-07 | 2021-01-10 |
| B           | sushi        | 2021-01-09 | 2021-01-11 |


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
```
| customer_id | product_name | join_date  | order_date |
| ----------- | ------------ | ---------- | ---------- |
| A           | sushi        | 2021-01-07 | 2021-01-01 |
| A           | curry        | 2021-01-07 | 2021-01-01 |
| B           | sushi        | 2021-01-09 | 2021-01-04 |

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
```
| customer_id | total_items | total_spend |
| ----------- | ----------- | ----------- |
| B           | 3           | 40          |
| A           | 2           | 25          |


9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
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
```
| customer_id | points |
| ----------- | ------ |
| B           | 940    |
| C           | 360    |
| A           | 860    |


10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```sql
WITH bonus_cte AS (
  SELECT 
  sales.customer_id,
  sales.product_id,
  sales.order_date,
  menu.price,
  menu.product_name,
  members.join_date,
  members.join_date + INTERVAL '6 days' AS bonus_date_end,
  CASE 
    WHEN order_date BETWEEN join_date AND members.join_date + INTERVAL '6 days'
    THEN 'YES' 
    ELSE 'NO'
    END AS is_bonus_period
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
WHERE join_date IS not NULL AND order_date <= '2021-01-31'
)

SELECT 
  customer_id,
  SUM(
    CASE 
      WHEN is_bonus_period = 'YES'
      THEN price * 20
      WHEN product_name = 'sushi'
      THEN price * 20
      ELSE price * 10
      END
  ) AS Total_Points
FROM bonus_cte
GROUP BY customer_id
```
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

### Bonus Questions
Recreate the following table output using the available data.

#### Join All The Things
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

**solution**
```sql
SELECT 
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  menu.price,
  CASE 
    WHEN members.join_date IS NOT NULL AND sales.order_date >= members.join_date
    THEN 'Y'
    ELSE 'N'
    END AS member
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date 
```
#### Rank All The Things
| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | curry        | 15    | N      | null    |
| A           | 2021-01-01 | sushi        | 10    | N      | null    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | null    |
| B           | 2021-01-02 | curry        | 15    | N      | null    |
| B           | 2021-01-04 | sushi        | 10    | N      | null    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-01 | ramen        | 12    | N      | null    |
| C           | 2021-01-07 | ramen        | 12    | N      | null    |

**solution**
```sql
SELECT 
  customer_id,
  order_date,
  product_name,
  price,
  member,
  CASE
    WHEN member = 'Y'
    THEN RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
    ELSE NULL
    END AS rank
FROM (
  SELECT 
  sales.customer_id,
  sales.order_date,
  menu.product_name,
  menu.price,
  CASE 
    WHEN members.join_date IS NOT NULL AND sales.order_date >= members.join_date
    THEN 'Y'
    ELSE 'N'
    END AS member
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date) as sales
```