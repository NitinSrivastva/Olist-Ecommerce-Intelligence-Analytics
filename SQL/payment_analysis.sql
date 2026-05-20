USE olist_project;

CREATE TABLE payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

SHOW TABLEs;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payment_raw.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- SELECT COUNT(*) AS total_payments
-- FROM payments;

SELECT * FROM payments LIMIT 10;

-- Total Revenue
SELECT 
    ROUND(SUM(payment_value),2) AS total_revenue
FROM payments;

-- Average Revenue
SELECT
	ROUND(AVG(payment_value),2) AS avg_revenue
FROM payments;

-- Most Used Payment Method - Credit Card
SELECT payment_type,
	COUNT(*) AS total_transaction
FROM payments
GROUP BY payment_type
ORDER BY total_transaction DESC;

-- Highest Revenue Payment Method - Credit Card
SELECT payment_type,
	ROUND(SUM(payment_value),2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- Average Transaction Value
SELECT payment_type,
	ROUND(AVG(payment_value),2) AS avg_payment
FROM payments
GROUP BY payment_type
ORDER BY avg_payment DESC;

-- Installment Usage Analysis 
SELECT 
	payment_installments,
	COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_installments
ORDER BY total_transactions DESC;

-- Highest Payment Transaction
SELECT 
	MAX(payment_value) AS highest_payment
FROM payments;

-- Lowest Payment Transaction
SELECT 
	MIN(payment_value) AS lowest_payment
FROM payments;

-- SELECT *
-- FROM payments
-- WHERE payment_value = 0;

-- Maximum Installments
SELECT 
	MAX(payment_installments) AS max_installments
FROM payments;

-- Payment Type vs Installments Analysis - which payment type is maximum used for installments
SELECT payment_type,
	MAX(payment_installments) AS max_installments
FROM payments
GROUP BY payment_type
ORDER BY max_installments DESC;

-- Revenue Contribution % by Payment Method
SELECT 
    payment_type,
    ROUND(SUM(payment_value),2) AS total_revenue,
    ROUND(
        (SUM(payment_value) / 
        (SELECT SUM(payment_value) FROM payments)) * 100,
        2
    ) AS revenue_percentage
FROM payments
GROUP BY payment_type
ORDER BY revenue_percentage DESC;
    
-- Top 5 Highest Payment Transactions - premium customer detection
SELECT 
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM payments
ORDER BY payment_value DESC
LIMIT 5;

-- Payment Type Distribution Percentage
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(
        (COUNT(*)  / 
        (SELECT COUNT(*) FROM payments)) * 100.0,
        2
    ) AS transaction_percentage
FROM payments
GROUP BY payment_type
ORDER BY transaction_percentage DESC;

-- Payment Type Wise Average Installments
SELECT 
    payment_type,
    ROUND(AVG(payment_installments),2) AS avg_installments
FROM payments
GROUP BY payment_type
ORDER BY avg_installments DESC;

-- Payment Type Wise Highest Transaction
SELECT payment_type,
	MAX(payment_value) AS highest_transactions
FROM payments
GROUP BY payment_type
ORDER BY highest_transactions DESC;

-- Payment Type Wise lowest Transaction
SELECT 
    payment_type,
    MIN(payment_value) AS minimum_transaction
FROM payments
GROUP BY payment_type
ORDER BY minimum_transaction ASC;

-- Installment Wise Total Revenue
SELECT 
    payment_installments,
    ROUND(SUM(payment_value),2) AS total_revenue
FROM payments
GROUP BY payment_installments
ORDER BY total_revenue DESC;

-- Installment Wise Average Revenue
SELECT 
    payment_installments,
    ROUND(AVG(payment_value),2) AS avg_payment
FROM payments
GROUP BY payment_installments
ORDER BY avg_payment DESC;

-- Premium customer detection
SELECT 
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM payments
WHERE payment_installments > 1
ORDER BY payment_value DESC
LIMIT 10;

-- Which payment method is used the most in which installment range
SELECT payment_type,payment_installments,
	COUNT(*) AS total_transactions
FROM payments
GROUP BY payment_type , payment_installments
ORDER BY total_transactions DESC;
	
-- Which payment method and installment combination generates the most revenue?
SELECT payment_type,payment_installments,
	ROUND(SUM(payment_value),2) AS total_revenue
FROM payments
GROUP BY payment_type,payment_installments
ORDER BY total_revenue DESC;

-- Identify Customers Paying in Very High Installments
SELECT 
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM payments
WHERE payment_installments >= 12
ORDER BY payment_installments DESC, payment_value DESC;

-- How much revenue are long-term EMI customers generating for the business?
SELECT 
    ROUND(SUM(payment_value),2) AS high_installment_revenue
FROM payments
WHERE payment_installments >= 12;
