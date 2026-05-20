USE olist_project;

CREATE TABLE sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(20),
    seller_city VARCHAR(100),
    seller_state VARCHAR(10),

    PRIMARY KEY (seller_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sellers_raw.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_sellers FROM sellers;

-- Missing Values Check (sellers)
SELECT
    SUM(CASE WHEN seller_id IS NULL OR seller_id = '' THEN 1 ELSE 0 END) AS missing_seller_id,

    SUM(CASE WHEN seller_zip_code_prefix IS NULL OR seller_zip_code_prefix = '' THEN 1 ELSE 0 END) AS missing_zip,

    SUM(CASE WHEN seller_city IS NULL OR seller_city = '' THEN 1 ELSE 0 END) AS missing_city,

    SUM(CASE WHEN seller_state IS NULL OR seller_state = '' THEN 1 ELSE 0 END) AS missing_state

FROM sellers;

-- Check duplicates values in sellers dataset
SELECT 
	seller_id,
    COUNT(*) AS total_duplicates
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

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

-- Top Sellers by Total Orders
SELECT 
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY total_orders DESC

LIMIT 10;

-- Average Revenue per Seller
SELECT 
    ROUND(AVG(seller_revenue),2) AS avg_revenue_per_seller
FROM
(
    SELECT 
        oi.seller_id,
        
        SUM(oi.price) AS seller_revenue

    FROM order_items oi

    JOIN orders o
    ON oi.order_id = o.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY oi.seller_id
) AS seller_data;

-- Top Seller States by Revenue
SELECT 
    s.seller_state,
    
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    
    ROUND(SUM(oi.price),2) AS total_revenue

FROM order_items oi

JOIN sellers s
ON oi.seller_id = s.seller_id

JOIN orders o
ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'

GROUP BY s.seller_state

ORDER BY total_revenue DESC;