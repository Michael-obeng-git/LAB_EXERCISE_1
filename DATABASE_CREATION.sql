-- CREATING THE SHOPEASE DATABASE

create database ShopEase; 

use ShopEase;

create table customers(
customer_id int primary key,
 customer_name varchar(50),
 email varchar(50),
 join_date date
);

create table products (
product_id int primary key,
product_name varchar(50),
category varchar(50),
price decimal
);

create table orders(
order_id int primary key,
customer_id int references customers(customer_id),
order_date date,
product_id int references products(product_id),
quantity int,
year int,
month int,
day int
);

create table order_items (
order_detail_id int primary key,
order_id int references orders(order_id),
quantity int,
product_id int references products(product_id)
);

create table suppliers_data(
supplier_name varchar(50),
supplier_address varchar(50),
email varchar(50),
contact_number varchar(20),
fax varchar(50),
account_number varchar(20),
order_history int,
contract varchar(5),
supplier_country varchar(40),
supplier_city varchar(20),
country_code int
);

CREATE TABLE inventors (
    product_name VARCHAR(50),
    stock_quantity VARCHAR(50),
    stock_date DATE,
    supplier varchar(50),
    warehouse_location VARCHAR(50)
);

-- create table merged_product_orders (
-- product_id int primary key,
-- product_name varchar(50),
-- category varchar(50),
-- price decimal,
-- order_id int,
-- customer_id int,
-- order_date,
-- quantity,
-- );

create table merged_product_orders(
order_id int references orders(order_id),
product_id int references products(product_id),
customer_id int references customers(customer_id),
product_name varchar(50),
category varchar(50),
year int,
month int,
day int,
quantity int,
price decimal,
total_revenue decimal,
primary key(product_id,customer_id,order_id)
)
;


insert into merged_product_orders(order_id,product_id,customer_id,product_name,category,year,month,day,quantity,price,total_revenue)
select 
	o.order_id,p.product_id,	
    o.customer_id,p.product_name,
	p.category,o.year,o.month,o.day,o.quantity,p.price, 
	o.quantity*p.price as total_revenue
from orders o
join products p
on o.product_id = p.product_id
;

select * from order_items;