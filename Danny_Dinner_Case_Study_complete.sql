-- Just showcase all data in these tables

select * from sales;

select * from menu;

select * from members;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. Write a SQL query to find What is the total amount each customer spent at the restaurant.
--Query: - 
select
     s.customer_id,
	 sum(m.price) as total_money_spent
from sales as s
join menu as m  on s.product_id = m.product_id
    group by s.customer_id
	     order by total_money_spent desc;

-- 2.Write a SQL query to find  How many days has each customer visited the restaurant.
-- Query:-
select
     customer_id,
	 count(distinct order_date) as number_of_days_visited
from sales
    group by customer_id
	     order by number_of_days_visited desc;

-- 3. Write a Sql query to find What was the first item from the menu purchased by each customer.
-- Query:-

select
     t.customer_id,
	 t.product_name as first_purchased_item
from (select
     s.customer_id,
	 s.order_date,
	 m.product_name,
	 row_number() over(partition by s.customer_id order by order_date asc) as rownum
from sales as s
join menu as m on s.product_id = m.product_id
    order by s.customer_id,s.order_date) as t
         where t.rownum = 1;

-- 4.Write a SQL query to find  What is the most purchased item on the menu and how many times was it purchased by all customers.
--Query:-
select
     m.product_name,
	 count(s.order_date) as item_purchased_count
from sales as s
join menu as m on s.product_id = m.product_id
    group by m.product_name
	     order by item_purchased_count desc 
		      limit 1;

-- 5.Write a SQL query to find Which item was the most popular for each customer.
--Query:-

select
     t.customer_id,
	 t.product_name as most_popular_item
from (select
     s.customer_id,
	 m.product_name,
	 count(s.order_date) as item_purchased_count,
	 rank() over(partition by s.customer_id order by count(s.order_date) desc) as rank_number
from sales as s
join menu as m on s.product_id = m.product_id
    group by s.customer_id,m.product_name) as t
	      where rank_number = 1;
	 
-- 6. Write a SQL query to find Which item was purchased first by the customer after they became a member.
--Query:-
select
    t.customer_id,
	t.order_date,
	t.product_name as first_purchased_item
from (select
     s.customer_id,
	 s.order_date,
	 m.product_name,
	 dense_rank() over(partition by s.customer_id order by s.order_date asc) as dense_rank_number
from sales as s
inner join menu as m on s.product_id = m.product_id
inner join members as mb on s.customer_id = mb.customer_id
     where s.order_date > mb.join_date) as t
	      where t.dense_rank_number = 1;
		  
-- 7.Write a SQL query to find which item was purchased just before the customer became a member.
-- Query:-
select
     s.customer_id,
	 s.order_date,
	 m.product_name
from sales as s
join menu as m on s.product_id = m.product_id
join members as mb on s.customer_id = mb.customer_id
    where s.order_date < mb.join_date
	      order by s.customer_id asc , s.order_date asc;

-- 8. Write a SQL query to find What is the total items and amount spent for each member before they became a member.
-- Query:-
select
     s.customer_id,
	 count(s.product_id) as total_items_count,
	 sum(m.price) as total_amount_spent
from sales as s
join menu as m on s.product_id = m.product_id
join members as mb on s.customer_id = mb.customer_id
    where s.order_date < mb.join_date
	    group by s.customer_id;

-- 9.Write a SQL query to find If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have.
-- Query:-
select
     t.customer_id,
	 sum(t.customer_points) as total_points
from (select
     s.customer_id,
	 s.order_date,
	 m.product_name,
	 m.price,
	 case
	     when m.product_name = 'curry' or m.product_name = 'ramen' then m.price * 10
		 else m.price* 20
	 end as customer_points
from sales as s
join menu as m on s.product_id = m.product_id
     order by s.customer_id,s.order_date) as t
	      group by t.customer_id
		       order by t.customer_id asc;

-- 10.Write a SQL query to find that in the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
--Query:-
select
     t.customer_id,
	 sum(t.customer_points) as total_points
from (select
     s.customer_id,
	 m.product_name,
	 case
	     when m.product_name ='sushi' then m.price*20
		 when m.product_name = 'curry' then m.price*20
		 else m.price*20
	 end as customer_points
from sales as s
join menu as m on s.product_id = m.product_id
join members as mb on s.customer_id = mb.customer_id
    where s.order_date between mb.join_date and '2021-01-31') as t
	     group by t.customer_id
		      order by t.customer_id asc;