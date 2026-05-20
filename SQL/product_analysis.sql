USE olist_project;

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length VARCHAR(20),
    product_description_length VARCHAR(20),
    product_photos_qty VARCHAR(20),
    product_weight_g VARCHAR(20),
    product_length_cm VARCHAR(20),
    product_height_cm VARCHAR(20),
    product_width_cm VARCHAR(20),

    PRIMARY KEY (product_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_raw.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_products
FROM products;

-- Missing values check in the product dataset
SELECT 
    SUM(CASE
        WHEN product_id IS NULL OR product_id = '' THEN 1
        ELSE 0
    END) AS missing_product_id,
    SUM(CASE
        WHEN
            product_category_name IS NULL
                OR product_category_name = ''
        THEN
            1
        ELSE 0
    END) AS missing_category,
    SUM(CASE
        WHEN
            product_weight_g IS NULL
                OR product_weight_g = ''
        THEN
            1
        ELSE 0
    END) AS missing_weight,
    SUM(CASE
        WHEN
            product_length_cm IS NULL
                OR product_length_cm = ''
        THEN
            1
        ELSE 0
    END) AS missing_length,
    SUM(CASE
        WHEN
            product_height_cm IS NULL
                OR product_height_cm = ''
        THEN
            1
        ELSE 0
    END) AS missing_height,
    SUM(CASE
        WHEN
            product_width_cm IS NULL
                OR product_width_cm = ''
        THEN
            1
        ELSE 0
    END) AS missing_width
FROM
    products;

-- Duplicate value chec in product dataset
SELECT product_id ,
	COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- =========================================
-- ORDERS LIST + PRODUCTS JOIN ANALYSIS
-- =========================================

-- Top product categories  by order_list
SELECT 
	p.product_category_name,
    COUNT(oi.order_id) AS total_orders
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_orders DESC;

-- Average Product Price by category
SELECT 
    p.product_category_name,
    
    COUNT(oi.order_id) AS total_items_sold,
    
    ROUND(AVG(oi.price),2) AS avg_product_price

FROM order_items oi

JOIN products p
ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY avg_product_price DESC;

-- Freight Cost Analysis by Category
SELECT 
    p.product_category_name,
    
    COUNT(oi.order_id) AS total_items_sold,
    
    ROUND(AVG(oi.freight_value),2) AS avg_freight_cost

FROM order_items oi

JOIN products p
ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY avg_freight_cost DESC;

-- Most Expensive Sold Products
SELECT 
    oi.product_id,
    
    p.product_category_name,
    
    ROUND(MAX(oi.price),2) AS highest_price

FROM order_items oi

JOIN products p
ON oi.product_id = p.product_id

GROUP BY oi.product_id, p.product_category_name

ORDER BY highest_price DESC

LIMIT 10;

-- Category Revenue vs Freight Analysis
SELECT 
    p.product_category_name,
    
    ROUND(SUM(oi.price),2) AS total_revenue,
    
    ROUND(SUM(oi.freight_value),2) AS total_freight,
    
    ROUND(
        SUM(oi.freight_value) / SUM(oi.price) * 100,
        2
    ) AS freight_percentage

FROM order_items oi

JOIN products p
ON oi.product_id = p.product_id

GROUP BY p.product_category_name

ORDER BY total_revenue DESC;


-- Monthly Product Sales Trend
SELECT 
    SUBSTRING(o.order_purchase_timestamp,1,7) AS order_month,
    
    COUNT(oi.order_id) AS total_items_sold,
    
    ROUND(SUM(oi.price),2) AS total_product_revenue

FROM order_items oi

JOIN orders o
ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'

GROUP BY order_month

ORDER BY order_month;


