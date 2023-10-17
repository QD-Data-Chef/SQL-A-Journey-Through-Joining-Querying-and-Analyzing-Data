create database Sales;

Create table Menu
(Product_id int primary key,
Product_name varchar (5),
Price int
);

insert into menu (Product_id, Product_name, Price)
values
(1, 'Sushi', 10),
(2, 'Curry', 15),
(3, 'Ramen', 12);

select *
from Menu;

Create table Members
(Customer_id varchar (1) primary key,
Join_date datetime
);

ALTER TABLE Members ALTER COLUMN Join_date date

insert into members (Customer_id, Join_date)
Values
('A', '2021-01-07'),
('B', '2021-01-09');

select *
from Members;

create table orders
(Customer_id varchar (1),
order_date Date,
Product_id int
);


insert into orders(Customer_id, Order_date, Product_id)
values
('A', '2021-01-01', 1),
('A', '2021-01-01', 2),
('A', '2021-01-07', 2),
('A', '2021-01-10', 3),
('A', '2021-01-11', 3),
('A', '2021-01-11', 3),
('B', '2021-01-01', 2),
('B', '2021-01-02', 2),
('B', '2021-01-04', 1),
('B', '2021-01-11', 1),
('B', '2021-01-16', 3),
('B', '2021-02-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-01', 3),
('C', '2021-01-07', 3);

select *
from orders;

--total amount each customer spent 
select customer_id, SUM(price) as Total_amount
from orders as o
join Menu as m
on o.product_id = m.Product_id
group by customer_id;

--total number of days each customers visited the restaurant
select customer_id, COUNT(distinct order_date) as no_of_visit
from orders as o
join Menu as m
on o.product_id = m.Product_id
group by customer_id
ORDER BY no_of_visit DESC;

--first item from the menu purchased by each customer
with cte as (select Product_name, order_date, customer_id,
ROW_NUMBER () OVER ( PARTITION BY customer_id ORDER BY order_date ASC) order_rank
from orders as o
join Menu as m
on o.product_id = m.Product_id)
select customer_id, product_name, order_date
from cte
where order_rank = 1;

--the most purchased item on the menu and how many times was it purchased by all customers
select customer_id, product_name, COUNT(product_name) AS No_of_times_purchased
from orders as o
join Menu as m
on o.product_id = m.Product_id
WHERE Product_name = (select top 1 Product_name
from orders as o
join Menu as m
on o.product_id = m.Product_id
group by Product_name
order by COUNT(product_name) desc)
group by customer_id, Product_name;

--the most popular item for each customer
with cte as (select customer_id, product_name,
COUNT(product_name) Total_orders, Rank() OVER (PARTITION BY customer_id 
ORDER BY COUNT(product_name) desc) as Most_popular_item
from orders as o
join Menu as m
on o.product_id = m.Product_id
GROUP BY Product_name, customer_id)
select Customer_id, Product_name, Total_orders
from cte
where Most_popular_item = 1;

 ---first item purchased by a customer after they became a member
 with cte as (SELECT o.Customer_id, order_date, Product_name, Join_date
  FROM Menu as m
  JOIN orders as o
  ON m.Product_id = o.Product_id
  join Members as me 
  ON o.Customer_id = me.Customer_id
  where order_date >= Join_date)
  select Customer_id, order_date, Product_name, Join_date
  from (select *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as row_rank
  from cte) t
  where row_rank = 1;

 ---first item purchased by a customer before they became a member
 with cte as (SELECT o.Customer_id, order_date, Product_name, Join_date
  FROM Menu as m
  JOIN orders as o
  ON m.Product_id = o.Product_id
 JOIN Members as me 
  ON o.Customer_id = me.Customer_id
  where order_date <= Join_date)
  select *
  from (select *, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as row_rank
  from cte) t
  where row_rank = 1;

  --total items and amount spent for each member before they became a member
SELECT o.Customer_id, COUNT(m.Product_id) as Amount_of_product, SUM(Price) as Total_amount
  FROM Menu as m
  JOIN orders as o
  ON m.Product_id = o.Product_id
  join Members as me 
  ON o.Customer_id = me.Customer_id
 where order_date < Join_date
 Group by o.Customer_id;

 --If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
 --how many points would each customer have?
select o.Customer_id, Product_name, sum(Price) AS total_price, 
(sum(price) * 10 * CASE WHEN product_name = 'Sushi' THEN 2 ELSE 1 END) AS Points
FROM Menu as m
  JOIN orders as o
  ON m.Product_id = o.Product_id
  join Members as me 
  ON o.Customer_id = me.Customer_id
  GROUP BY o.customer_id, Product_name
  ORDER BY Customer_id;

--In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select o.Customer_id, sum(price * 10 * CASE WHEN product_name = 'Sushi' THEN 2 ELSE 1 END * CASE
WHEN datediff(day, join_date, order_date) <= 7 THEN 2 ELSE 1 END) AS Points
FROM Menu as m
  JOIN orders as o
  ON m.Product_id = o.Product_id
  join Members as me 
  ON o.Customer_id = me.Customer_id
WHERE order_date <= '2021-01-31'
GROUP BY o.customer_id;


 --Join all the tables 
 select *
FROM Menu as m
  LEFT JOIN orders as o
  ON m.Product_id = o.Product_id
  LEFT join Members as me 
  ON o.Customer_id = me.Customer_id;

  