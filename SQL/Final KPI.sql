USE olist_project;

-- Total Revenue
SELECT 
    ROUND(SUM(payment_value),2) AS total_revenue
FROM payments;

-- Total Orders KPI
SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Total Customers KPI
SELECT 
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;

-- Total Sellers KPI
SELECT 
    COUNT(DISTINCT seller_id) AS total_sellers
FROM sellers;

-- Average Order Value (AOV)
SELECT 
    ROUND(
        SUM(payment_value) / COUNT(DISTINCT order_id),
        2
    ) AS avg_order_value
FROM payments;

-- Repeat Customer Rate
SELECT 	
    ROUND(
        (
            2801 * 100.0
        ) / 96096,
        2
    ) AS repeat_customer_percentage;