CREATE TABLE menu
(
product_id int PRIMARY KEY,
product_name varchar(5),
price int
);

CREATE TABLE members
(
customer_id varchar(1) PRIMARY KEY,
join_date timestamp
);

CREATE TABLE sales
(
customer_id varchar(1) REFERENCES members(customer_id),
order_date date,
product_id int REFERENCES menu(product_id)
);


insert into menu values (1,'sushi',10);
insert into menu values (2,'curry',15);
insert into menu values (3,'ramen',12);

insert into members values ('A','07/01/2021');
insert into members values ('B','09/01/2021');
insert into members values ('C','12/01/2021');


insert into sales values ('A','01/01/2021',1);
insert into sales values ('A','01/01/2021',2);
insert into sales values ('A','07/01/2021',2);
insert into sales values ('A','10/01/2021',3);
insert into sales values ('A','11/01/2021',3);
insert into sales values ('A','11/01/2021',3);
insert into sales values ('B','01/01/2021',2);
insert into sales values ('B','02/01/2021',2);
insert into sales values ('B','01/01/2021',1);
insert into sales values ('B','11/01/2021',1);
insert into sales values ('B','16/01/2021',3);
insert into sales values ('B','01/01/2021',3);
insert into sales values ('C','01/01/2021',3);
insert into sales values ('C','01/01/2021',3);
insert into sales values ('C','07/01/2021',3);

select * from sales;
select * from members;
select * from menu;

--Question 1 : What is the total amount each customer spent at the restaurant? 
select s.customer_id,sum(b.price) amount from sales s,menu b where s.product_id = b.product_id
group by s.customer_id;

--Question 2 : How many days has each customer visited the restaurant? 
select customer_id,count(order_date) count from sales group by customer_id;

--Question 3 : What was the first item from the menu purchased by each customer?
select DISTINCT t.customer_id,m.product_name 
from (select s.* ,DENSE_RANK() over (order by  s.order_date) as k from sales s) t, menu m 
where t.product_id = m.product_id and k = 1 order by t.customer_id;


--Question 4 : What is the most purchased item on the menu and how many times was it purchased by all customers? 
select a.product_id,a.cnt,b.PRODUCT_NAME from (
select product_id,count(product_id) cnt 
from sales  group by product_id 
order by count(product_id) desc) a,menu b where rownum=1;


--Question 5 : Which item was the most popular for each customer? 
select customer_id,product_id,product_name from (
select t.customer_id,t.product_id,t.cnt,m.product_name,rank() over(partition by customer_id order by t.customer_id ASC,t.cnt DESC) as rankk from
(select customer_id,product_id,count(product_id) cnt 
from sales group by customer_id,product_id order by customer_id ASC,cnt DESC) t,menu m
where t.product_id = m.product_id  order by t.customer_id ) q where rankk=1;

-- Q6) Which item was purchased first by the customer after they became a member?

SELECT customer_id, product_name FROM
(SELECT customer_id, join_date, order_date, product_name, RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as rn
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)
 WHERE order_date >= join_date) sq
 WHERE rn = 1;
 
 -- 7)Q Which item was purchased just before the customer became a member?
SELECT customer_id, product_name, order_date FROM
(SELECT customer_id, join_date, order_date, product_name, RANK() OVER (PARTITION BY customer_id ORDER BY order_date DESC) as rn
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)
 WHERE order_date < join_date) sq
WHERE rn = 1;

--Question 8 : What is the total items and amount spent for each member before they became a member? 
select a.customer_id,count(a.order_date) total ,sum(c.price) 
from sales a,members b,menu c
where a.customer_id = b.customer_id
and a.product_id = c.product_id
and to_char(b.join_date,'DD-MM-YY') > a.order_date
group by a.customer_id;

--Q9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? 

SELECT DISTINCT customer_id, SUM(CASE WHEN product_name = 'sushi' THEN price*20 ELSE price*10 END) OVER (PARTITION BY customer_id)
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id);

--Question 10 :
SELECT customer_id,SUM(CASE WHEN (diff in (1,6) OR product_id = 1) THEN price*20 ELSE price*10 END) AS points
 FROM
(SELECT customer_id, order_date, join_date,(order_date - join_date ) AS diff, price,product_id
 FROM sales 
 JOIN members USING (customer_id) 
 JOIN menu USING(product_id)) sq
 GROUP BY customer_id;
 
 
 
 
 
 
 




 ;