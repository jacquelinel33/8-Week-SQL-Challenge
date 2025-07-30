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

**Schema (PostgreSQL v13)**

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

---

**Query #1**

    /* --------------------
       Case Study Questions
       --------------------*/
    
    -- 1. What is the total amount each customer spent at the restaurant?
    -- 2. How many days has each customer visited the restaurant?
    -- 3. What was the first item from the menu purchased by each customer?
    -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
    -- 5. Which item was the most popular for each customer?
    -- 6. Which item was purchased first by the customer after they became a member?
    -- 7. Which item was purchased just before the customer became a member?
    -- 8. What is the total items and amount spent for each member before they became a member?
    -- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
    -- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    
    -- Example Query:
    SELECT
      	sales.customer_id,
        SUM(menu.price) as Total_Spend
    FROM dannys_diner.sales
    JOIN dannys_diner.menu ON sales.product_id = menu.product_id
    GROUP BY customer_id

| customer_id | total_spend |
| ----------- | ----------- |
| B           | 74          |
| C           | 36          |
| A           | 76          |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)


2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?