USE olist_project;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp VARCHAR(50),
    order_approved_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders_raw.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM orders LIMIT 10;

-- Total order count
SELECT COUNT(*) AS total_order 
FROM orders;

-- Total order status Distribution
SELECT order_status,
	COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Delivered Order Percentage
SELECT 
    ROUND(
        (
            SUM(CASE 
                    WHEN order_status = 'delivered' 
                    THEN 1 
                    ELSE 0 
                END
            ) 
        ) / COUNT(*) * 100.0,
        2
    ) AS delivered_percentage
FROM orders;

-- Cancelled Order Percentage
SELECT 
	ROUND(
		(
			SUM(CASE
					WHEN order_status = 'canceled'
                    THEN 1
                    ELSE 0
				END
			)
		)  / COUNT(*) * 100.0, 2) AS canceled_order
	FROM orders;

-- Non-Delivered Orders Count
SELECT order_status , 
	COUNT(*) AS total_orders
FROM orders
WHERE order_status <> 'delivered'
GROUP BY order_status
ORDER BY total_orders DESC;

-- Monthly Orders Trend Analysis
SELECT 
    SUBSTRING(order_purchase_timestamp,1,7) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month ;

-- Highest Order Month
SELECT 
    SUBSTRING(order_purchase_timestamp,1,7) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY total_orders DESC
LIMIT 1;

-- Lowest Order Month
SELECT 
    SUBSTRING(order_purchase_timestamp,1,7) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY total_orders 
LIMIT 1;

-- delivered vs Late Delivered Orders Analysis
SELECT COUNT(*) AS late_deliveries
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- On Time Delivered Orders Analysis
SELECT COUNT(*) AS on_time_deliveries
FROM orders
WHERE order_delivered_customer_date <= order_estimated_delivery_date;

-- Late Deliveries Percentage 
SELECT 
    ROUND(
        (
            SUM(
                CASE 
                    WHEN order_delivered_customer_date > order_estimated_delivery_date
                    THEN 1
                    ELSE 0
                END
            ) * 100.0
        ) / COUNT(*),
        2
		) AS late_delivery_percentage
FROM orders;

-- Average Delivery Time
SELECT ROUND(
			AVG(
				DATEDIFF(
						order_delivered_customer_date,
                        order_purchase_timestamp
					)
				),2
			) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Fastest Delivery Time
SELECT 
	MIN(
		DATEDIFF(
			order_delivered_customer_date,
			order_purchase_timestamp
			)
		) AS fastest_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
					
-- Maximum Delivery Time
SELECT 
	MAX(
		DATEDIFF(
			order_delivered_customer_date,
			order_purchase_timestamp
            )
		) AS max_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Average Delay Days for Late Deliveries
SELECT 
	ROUND(
		AVG(
			DATEDIFF(
				order_delivered_customer_date,
				order_estimated_delivery_date
                )
			),2
		) AS avg_delay_days
FROM orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;

-- Average Early Delivery Days Analysis
SELECT 
    ROUND(
        AVG(
            DATEDIFF(
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        ),
        2
    ) AS avg_early_delivery_days
FROM orders
WHERE order_delivered_customer_date < order_estimated_delivery_date;

-- Orders Delivered After 30+ Days
SELECT 
    COUNT(*) AS delayed_30_plus_orders
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) > 30;

-- Percentage of Orders Delivered After 30+ Days
SELECT 
    ROUND(
        (
            COUNT(*) * 100.0
        ) /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS delayed_30_plus_percentage
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) > 30;
      
      
-- Orders Delivered Within 7 Days
SELECT 
    COUNT(*) AS fast_deliveries
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) <= 7;

-- fast delivery percentage
SELECT 
    ROUND(
        (
            COUNT(*) 
        ) /
        (SELECT COUNT(*) FROM orders)* 100.0,
        2
    ) AS fast_delivery_percentage
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) <= 7;
      
-- Orders Taking Between 8–30 Days
SELECT 
    COUNT(*) AS medium_delivery_orders
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) BETWEEN 8 AND 30;
      
      
-- Delivery Category Percentage Distribution
-- Medium Delivery %
SELECT 
	ROUND(
		(
			COUNT(*)
		)/
        (SELECT COUNT(*) FROM orders)*100.0 ,2
        ) AS medium_delivery_percentage
FROM orders
WHERE DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
      ) BETWEEN 8 AND 30;
            
-- =========================================
-- ORDERS + PAYMENTS JOIN ANALYSIS
-- =========================================


SELECT 
	o.order_id,
    o.order_status,
    p.payment_type,
    p.payment_value
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
LIMIT 10;

-- Total Revenue By order status
SELECT 
	o.order_status,
    ROUND(SUM(p.payment_value),2) AS total_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.order_status
ORDER BY total_revenue DESC;

-- Average Revenue By order status
	SELECT 
		o.order_status,
		ROUND(AVG(p.payment_value),2) AS avg_payment
	FROM orders o
	JOIN payments p
	ON o.order_id = p.order_id
	GROUP BY o.order_status
	ORDER BY avg_payment DESC;

-- Which payment method is used the most in different order status
SELECT 
	o.order_status,
    p.payment_type,
    COUNT(*) AS total_transaction
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY o.order_status , p.payment_type
ORDER BY total_transaction DESC;

-- Revenue Lost Due to Canceled Orders
SELECT 
	ROUND(SUM(p.payment_value),2) AS canceled_order_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'canceled';

-- Average delivery time by order status
SELECT 
	order_status,
    ROUND(
		AVG(
			DATEDIFF(
					order_delivered_customer_date,
					order_purchase_timestamp
                    )
			),2
		) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY order_status
ORDER BY avg_delivery_days DESC;

-- Monthly KPI Trend Analysis
SELECT 
    SUBSTRING(o.order_purchase_timestamp,1,7) AS order_month,
    ROUND(SUM(p.payment_value),2) AS monthly_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- Monthly Orders, Revenue & AOV Analysis
SELECT 
    SUBSTRING(o.order_purchase_timestamp,1,7) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_revenue,
    ROUND(SUM(p.payment_value) / COUNT(DISTINCT o.order_id),2) AS avg_order_value
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- Revenue By payment type
SELECT 
	p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY total_revenue DESC;


-- =========================================
-- CUSTOMER + ORDERS + PAYMENTS JOIN ANALYSIS
-- =========================================

-- City-wise Revenue Analysis
SELECT 
	c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_revenue
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
ORDER BY total_revenue DESC;

-- State-wise Revenue Analysis
SELECT 
	c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_revenue
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Average Order Value by State 
SELECT 
	c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_revenue,
    ROUND(
		SUM(p.payment_value)/
        COUNT(DISTINCT o.order_id)
        ,2) AS avg_order_value
FROM orders o
JOIN customers c 
ON o.customer_ID = c.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_order_value DESC;
    
-- Top 10 Customers by Spending
SELECT 
	c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_spent
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Repeat vs One-Time Customers
SELECT 
	customer_type,
    COUNT(*) AS total_customers
FROM 
	(
		SELECT customer_unique_id ,
		CASE 
			WHEN COUNT(DISTINCT o.order_id) = 1
			THEN 'One-Time Customer'
			ELSE 'Repeat Customer'
		END AS customer_type	
    
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP  BY c.customer_unique_id
) AS customer_data

GROUP BY customer_type;


-- Repeat Customer Revenue Contribution
SELECT 
    customer_type,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(SUM(total_spent),2) AS total_revenue
FROM
(
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(p.payment_value) AS total_spent,
        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
            THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type
    FROM orders o
    JOIN customers c
    ON o.customer_id = c.customer_id
    JOIN payments p
    ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS customer_data
GROUP BY customer_type;

-- Top Customers by Number of Orders
SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value),2) AS total_spent
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN payments p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC, total_spent DESC
LIMIT 10;






