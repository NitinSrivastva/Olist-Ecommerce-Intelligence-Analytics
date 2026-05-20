USE olist_project;

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10 , 2 ),
    freight_value DECIMAL(10 , 2 )
);

DROP TABLE order_items;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_list_raw.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM order_items LIMIT 10;

-- Count the total Number of rows from the order_items
SELECT 
	COUNT(*) AS total_rows
FROM order_items;

-- Missing value check in order_items 
SELECT 
    SUM(CASE
        WHEN order_id IS NULL OR order_id = '' THEN 1
        ELSE 0
    END) AS missing_order_id,
    SUM(CASE
        WHEN order_item_id IS NULL THEN 1
        ELSE 0
    END) AS missing_order_item_id,
    SUM(CASE
        WHEN product_id IS NULL OR product_id = '' THEN 1
        ELSE 0
    END) AS missing_product_id,
    SUM(CASE
        WHEN seller_id IS NULL OR seller_id = '' THEN 1
        ELSE 0
    END) AS missing_seller_id,
    SUM(CASE
        WHEN shipping_limit_date IS NULL THEN 1
        ELSE 0
    END) AS missing_shipping_limit_date,
    SUM(CASE
        WHEN price IS NULL THEN 1
        ELSE 0
    END) AS missing_price,
    SUM(CASE
        WHEN freight_value IS NULL THEN 1
        ELSE 0
    END) AS missing_freight_value
FROM
    order_items;
    
-- Find Duplicates in the dataset
SELECT order_id,order_item_id,
	count(*) AS total_duplictes
FROM order_items
GROUP BY order_id,order_item_id
HAVING COUNT(*) > 1;


-- =========================================
-- ORDERS LIST + PRODUCTS + ORDERS JOIN ANALYSIS
-- =========================================

-- High Revenue Generating categories 
SELECT 
	p.product_category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- Top Sellers by Revenue
SELECT 
	oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'

GROUP BY oi.seller_id

ORDER BY total_revenue DESC

LIMIT 10;



