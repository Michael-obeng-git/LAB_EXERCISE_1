-- eXERCISE 2.1: queries to join the orders, products, and customers tables
EXPLAIN select * from orders
inner join customers
on orders.customer_id = customers.customer_id
inner join products
on orders.product_id = products.product_id
;


-- --LAB EXERCISE 2:QUESTION 2 
 -- Use subqueries to find the top 5 products with the highest sales in the last 
-- month.
SELECT 
    p.product_id,
    p.product_name,
    total_revenue
FROM 
    products p
JOIN (
    SELECT 
        p.product_id,
        SUM(o.quantity * p.price) AS total_revenue
    FROM 
        orders o
    JOIN 
        products p ON o.product_id = p.product_id
    -- JOIN 
--         products p ON oi.product_id = p.product_id
    WHERE 
        o.order_date >= 5
--         DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY 
        p.product_id
) AS sales_summary ON p.product_id = sales_summary.product_id
ORDER BY 
    total_revenue DESC
LIMIT 5
;




-- QUESTION 4: query optimization
EXPLAIN SELECT 
    o.order_id,
    o.month,
    total_revenue
FROM 
    orders o
JOIN (
    SELECT 
        p.product_id,
        SUM(o.quantity * p.price) AS total_revenue
    FROM 
        products 
   --  JOIN 
--         products p ON o.product_id = p.product_id
    -- JOIN 
--         products p ON oi.product_id = p.product_id
    WHERE 
        o.order_date >= 5
--         DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY 
        p.product_id
) AS sales_summary ON p.product_id = sales_summary.product_id
ORDER BY 
    total_revenue DESC
LIMIT 5
;

CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date);
ANALYZE TABLE orders;




-- QUESTION 3: t CASE statements to categorize orders into ‘High’, 
-- ‘Medium’, and ‘Low’ revenue based on total order value

select total_revenue from orders
order by total_revenue desc;

select 
	product_id,
    total_revenue,
	case 
		when total_revenue > 1000 then 'HIGH'
		when total_revenue < 1000 and total_revenue >= 500 then "MEDIUM"
		else "LOW" 
    end as 'Revenue Review'
from orders
    ;
    
    

select * from products;


-- LAB EXERCISE 3:

-- ROW_NUMBER(),RANK(),DENSE_RANK FUNCTIONS
EXPLAIN select products.product_name,orders.total_revenue,
	row_number() over (order by orders.total_revenue desc) as 'product_row_num',
    rank() over (order by orders.total_revenue desc) as 'product_rank',
    dense_rank() over (order by orders.total_revenue desc) as 'product_dense_rank'
from products
join orders
on orders.product_id = products.product_id
limit 20
;


-- EXERCISE 3.2**
select 
	p.category,
    p.product_name,
    o.order_date,
    p.price,
sum(p.price) over (order by o.order_date) as running_total
from products p
join orders o ON p.product_id = o.product_id
order by o.order_date;




-- EXERCISE 3.3
-- Using the PARTITION BY clause to calculate the average order value for each 
-- customer

 SELECT 
    c.customer_id,
    c.customer_name,
    o.order_date,
    o.total_revenue,
  AVG(o.total_revenue) OVER (PARTITION BY c.customer_id) AS average_order_value
 FROM 
     customers c
 JOIN 
     orders o ON c.customer_id = o.customer_id
ORDER BY 
     c.customer_id, o.order_date;



-- SELECT 
--     month,
--     SUM(total_revenue) AS total_orders,
--     LAG(SUM(total_revenue)) OVER (ORDER BY month) AS previous_month_orders,
--     LEAD(SUM(total_revenue)) OVER (ORDER BY month) AS previous_month_orders
--     FROM 
--     orders
-- GROUP BY 
--     month
-- ORDER BY 
--     month;
--     
--    
-- 

-- EXERCISE 3.5   
explain SELECT 
    c.customer_id,
    c.customer_name,
    o.month AS order_month,
    SUM(o.total_revenue) AS monthly_sales,

    -- Running total of sales for each customer
    SUM(o.total_revenue) OVER (PARTITION BY c.customer_id ORDER BY o.month) AS cumulative_sales,
    -- Average monthly sales for each customer
    AVG(SUM(o.total_revenue)) OVER (PARTITION BY c.customer_id) AS avg_monthly_sales,
    -- Rank customers by total sales
    RANK() OVER (ORDER BY SUM(o.total_revenue) DESC) AS sales_rank
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.customer_name, o.month
ORDER BY 
    c.customer_id, order_month;


-- EXERCISE 5.1
DROP TRIGGER IF EXISTS update_inventory;

-- EXERCISE 5: TRIGGER
 DELIMITER $$
 CREATE TRIGGER update_inventory
AFTER INSERT ON order_Items
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    
    -- Get the current stock for the product
    SELECT inventory_count INTO current_stock
    FROM inventory
    WHERE product_id = NEW.product_id;

    -- Check if there is sufficient stock
    IF current_stock < NEW.quantity THEN
        -- Display a message if there is insufficient stock
        SIGNAL SQLSTATE '45000' 
        -- SET MESSAGE_TEXT = CONCAT('Insufficient stock for product ID: ' NEW.product_id);
        
			SET MESSAGE_TEXT = 'Insufficient stock for product ID: ';        
        -- 'Insufficient stock for product ID: ' || NEW.product_id
    ELSE
        -- Decrease the inventory count based on the ordered quantity
        UPDATE inventory
        SET inventory_count = inventory_count - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END$$

DELIMITER ;
    
use shopease;

select * from inventors;
select * from suppliers_data;

create table location(
location_id int auto_increment primary key,
supplier_country varchar(50),
supplier_city varchar(50),
supplier_country_code varchar(10),
UNIQUE(supplier_city, supplier_country,supplier_country_code)
);

-- drop table suppliers_data;
insert into location(supplier_country,supplier_city,supplier_country_code)
select 
	s.supplier_country,s.supplier_city,	
    s.country_code
from suppliers_data s
ON DUPLICATE KEY UPDATE
    supplier_country_code = VALUES(supplier_country_code)
;

select * from location;
select distinct suppliers_data.supplier_country
from suppliers_data;

ALTER TABLE location AUTO_INCREMENT = 1;

alter table location
add column location_id int auto_increment primary key;

alter table location
modify column location_id int first;
 
select * from inventors;

-- alter table suppliers_data
-- drop column supplier_country,drop supplier_city; drop country_code;
-- ;
-- alter table suppliers_data
-- ADD constraint foreign key(country_code) references location(supplier_country_code)
-- ;