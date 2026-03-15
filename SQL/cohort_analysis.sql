CREATE TABLE online_retail_clean (
    invoice_no VARCHAR,
    stock_code VARCHAR,
    description TEXT,
    quantity INTEGER,
    invoice_date TIMESTAMP,
    unit_price NUMERIC,
    customer_id NUMERIC,
    country VARCHAR,
    revenue NUMERIC
);

SELECT COUNT(*) FROM online_retail_clean;

SELECT
    customer_id,
    invoice_no,
    DATE_TRUNC('month', invoice_date) AS order_month
FROM online_retail_clean
LIMIT 10;

SELECT
    customer_id,
    MIN(DATE_TRUNC('month', invoice_date)) AS cohort_month
FROM online_retail_clean
GROUP BY customer_id
ORDER BY customer_id
LIMIT 10;


SELECT
    a.customer_id,
    DATE_TRUNC('month', a.invoice_date) AS order_month,
    b.cohort_month
FROM online_retail_clean a
JOIN (
    SELECT
        customer_id,
        MIN(DATE_TRUNC('month', invoice_date)) AS cohort_month
    FROM online_retail_clean
    GROUP BY customer_id
) b
ON a.customer_id = b.customer_id
LIMIT 10;


SELECT
    customer_id,
    order_month,
    cohort_month,
    (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
    (EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS cohort_index
FROM (
    SELECT
        a.customer_id,
        DATE_TRUNC('month', a.invoice_date) AS order_month,
        b.cohort_month
    FROM online_retail_clean a
    JOIN (
        SELECT
            customer_id,
            MIN(DATE_TRUNC('month', invoice_date)) AS cohort_month
        FROM online_retail_clean
        GROUP BY customer_id
    ) b
    ON a.customer_id = b.customer_id
) t
LIMIT 20;


SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_id) AS customers
FROM (
    SELECT
        customer_id,
        order_month,
        cohort_month,
        (EXTRACT(YEAR FROM order_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
        (EXTRACT(MONTH FROM order_month) - EXTRACT(MONTH FROM cohort_month)) AS cohort_index
    FROM (
        SELECT
            a.customer_id,
            DATE_TRUNC('month', a.invoice_date) AS order_month,
            b.cohort_month
        FROM online_retail_clean a
        JOIN (
            SELECT
                customer_id,
                MIN(DATE_TRUNC('month', invoice_date)) AS cohort_month
            FROM online_retail_clean
            GROUP BY customer_id
        ) b
        ON a.customer_id = b.customer_id
    ) x
) y
GROUP BY cohort_month, cohort_index
ORDER BY cohort_month, cohort_index;