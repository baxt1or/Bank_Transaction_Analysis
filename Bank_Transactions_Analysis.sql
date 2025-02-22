-- 1. Find total transaction amount for each customer in the last 6 months.
SELECT
customer_id, 
SUM(amount)
FROM transactions
WHERE transaction_date >= (SELECT MAX(transaction_date) FROM transactions) - INTERVAL '6 months'
GROUP BY 1;

-- 2. Identify the top 5 customers with the highest number of transactions.
SELECT
customer_id, 
COUNT(transaction_id),
RANK() OVER(ORDER BY COUNT(transaction_id) DESC) AS rnk
FROM transactions
GROUP BY 1
LIMIT 5;


-- 3. Find customers whose transaction amounts increased by more than 20% month-over-month.
WITH cte AS (SELECT
*,
LAG(total) OVER(PARTITION BY customer_id ORDER BY month) AS prev_month
FROM (SELECT
customer_id,
TO_CHAR(transaction_date, 'YYYY-MM') AS month,
SUM(amount) AS total
FROM transactions
GROUP BY 1, 2
ORDER BY 1,2) AS sub)

SELECT
*,
(total - prev_month ) * 1.0 / prev_month AS percentage
FROM cte
WHERE (total - prev_month ) * 1.0 / prev_month > 20;


WITH cte AS (SELECT
customer_id,
DATE_TRUNC('month',transaction_date) AS month,
SUM(amount) AS total
FROM transactions
GROUP BY 1, 2
ORDER BY 1,2)


SELECT
a.customer_id, a.month, a.total,
(a.total - b.total) * 1.0 / b.total * 100 AS percentage
FROM cte a
INNER JOIN cte b ON a.customer_id = b.customer_id AND a.month = b.month + INTERVAL '1 month'
WHERE (a.total - b.total) * 1.0 / b.total * 100 > 20;



-- 4. Calculate the average credit score of customers who took loans.
SELECT
customer_id, 
AVG(loan_amount)
FROM loans
GROUP BY 1;


-- 5. Identify potential fraud (large transactions within a short time).
WITH cte AS (SELECT
customer_id, 
loan_amount, 
start_date, 
LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_transaction_date, 
LAG(loan_amount) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_amount
FROM loans)

SELECT
*
FROM cte
WHERE loan_amount > 50000 AND prev_amount > 50000
AND start_date - prev_transaction_date <= 1;

SELECT
transaction_id, customer_id, transaction_date, amount, prev_amount, prev_transaction_date
FROM (SELECT
*,
LAG(transaction_date) OVER(PARTITION BY customer_id ORDER BY transaction_date) AS prev_transaction_date, 
LAG(amount) OVER(PARTITION BY customer_id ORDER BY transaction_date) AS prev_amount
FROM transactions) AS sub
WHERE amount > 5000 AND prev_amount > 5000
AND transaction_date - prev_transaction_date <= 1;










