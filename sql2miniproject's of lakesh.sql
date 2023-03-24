create database mini_project_sql2;
use mini_project_sql2;

--  question 1.	Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)


create view combined_table as 
select m.ord_id, m.prod_id,m.ship_id,m.cust_id,m.sales,m.discount,m.order_quantity,m.profit,m.shipping_cost,m.product_base_margin,customer_name,province,region,customer_segment,o.order_id,order_date,order_priority,product_category,product_sub_category,Ship_mode,ship_date 
from market_fact m join cust_dimen c on m.cust_id = c.cust_id  
join   orders_dimen o on m.ord_id = o.ord_id
join prod_dimen p on m.prod_id = p.prod_id
join shipping_dimen s on m.ship_id = s.ship_id ;
 

-- 2.	Find the top 3 customers who have the maximum number of orders
select cust_id, customer_name,count(*) from combined_table group by cust_id order by count(*) desc;-- limit 3;


-- 3.	Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

select * from combined_table;
select *,datediff(ship_date,order_date) as Days_taken_for_delivery from combined_table;


-- 4.	Find the customer whose order took the maximum time to get delivered.
select *,datediff(ship_date,order_date) as Days_taken_for_delivery from combined_table order by Days_taken_for_delivery desc limit 1;


-- 5.	Retrieve total sales made by each product from the data (use Windows function) 
select distinct product_sub_category, round( sum(sales) over(partition by product_sub_category ),3)as total_sales from combined_table order by total_sales desc ;


-- 6.	Retrieve total profit made from each product from the data (use windows function)

select distinct product_sub_category, round( sum(profit) over(partition by product_sub_category ),3)as total_profit from combined_table order by total_profit desc ;

-- 7.	Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
select count(*) as  unique_jan_customer from (
select distinct cust_id  as  unique_jan_2011_customer from combined_table where monthname(order_date)='january') t;

select  ' The jan customer who were back every month over the entire year in 2011' from (
select  cust_id,count(*) as total_order_in_year2011 from combined_table where cust_id in (
select distinct cust_id  as  unique_jan_2011_customer from combined_table where monthname(order_date)='january')  and year(order_date) = 2011 group by cust_id having total_order_in_year2011 >11)t ;

-- 8.	Retrieve month-by-month customer retention rate since the start of the business.(using views)
select (total-no_of_customer)/total *100 as 'Month by Month Retention-Rate' from (
select *,sum(no_of_customer) as total from (
select * , if (diff>1,1,0) AS final_diff,count(*) as no_of_customer from (
select *,(month(order_date) - lag(month(order_date)) over(partition by cust_id order by order_date)) diff from (
select distinct ship_id, order_id, cust_id,customer_name ,order_date,lag(order_date) over(partition by cust_id order by order_date),month(order_date),
lag(month(order_date)) over(partition by cust_id order by order_date) from combined_table )t)t1 
group by final_diff)t2)t3;


























