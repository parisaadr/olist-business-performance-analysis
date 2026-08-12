/*
===============================================================================
Olist business performance analysis
Exploration
===============================================================================

-- Purpose:
-- Explore the structure and behavior of the raw Olist data
-- before building business metrics and analytical views.
---------------------------------------------------------

-- This file focuses on exploratory questions rather than
-- finalized KPIs or executive reporting.
-- ============================================================

-- ============================================================
-- 1. ORDER STRUCTURE
-- ============================================================

-- How many orders contain multiple sellers?
-- Useful for understanding order complexity and marketplace
-- structure.
*/

SELECT
COUNT(*) AS multi_seller_orders
FROM (
SELECT
order_id
FROM items
GROUP BY order_id
HAVING COUNT(DISTINCT seller_id) > 1
) AS order_sellers;

-- How many orders contain multiple products?

SELECT
COUNT(*) AS multi_product_orders
FROM (
SELECT
order_id
FROM items
GROUP BY order_id
HAVING COUNT(DISTINCT product_id) > 1
) AS order_products;

-- Distribution of items per order.

SELECT
item_count,
COUNT(*) AS order_count
FROM (
SELECT
order_id,
COUNT(*) AS item_count
FROM items
GROUP BY order_id
) AS order_items
GROUP BY item_count
ORDER BY item_count;

-- Distribution of sellers per order.

SELECT
seller_count,
COUNT(*) AS order_count
FROM (
SELECT
order_id,
COUNT(DISTINCT seller_id) AS seller_count
FROM items
GROUP BY order_id
) AS order_sellers
GROUP BY seller_count
ORDER BY seller_count;

-- ============================================================
-- 2. PRODUCT & CATEGORY EXPLORATION
-- ============================================================

-- How many products exist in each category?

SELECT
p.product_category_name AS category,
COUNT(DISTINCT p.product_id) AS product_count
FROM products p
GROUP BY p.product_category_name
ORDER BY product_count DESC;

-- Which categories have the most items sold?

SELECT
p.product_category_name AS category,
COUNT(i.order_item_id) AS items_sold
FROM items i
LEFT JOIN products p
ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY items_sold DESC;

-- Which categories generate the most product revenue?

SELECT
p.product_category_name AS category,
ROUND(SUM(i.price), 2) AS revenue
FROM items i
LEFT JOIN products p
ON i.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC;

-- ============================================================
-- 3. SELLER EXPLORATION
-- ============================================================

-- Which states have the most sellers?

SELECT
seller_state AS state,
COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;

-- Which sellers generate the most product revenue?

SELECT
i.seller_id,
s.seller_state,
ROUND(SUM(i.price), 2) AS revenue,
COUNT(DISTINCT i.order_id) AS orders
FROM items i
LEFT JOIN sellers s
ON i.seller_id = s.seller_id
GROUP BY
i.seller_id,
s.seller_state
ORDER BY revenue DESC
LIMIT 20;

-- ============================================================
-- 4. PAYMENT EXPLORATION
-- ============================================================

-- Which payment methods are most commonly used?

SELECT
payment_type,
COUNT(*) AS payment_count,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (),
2
) AS payment_share
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;

-- What is the distribution of payment installments?

SELECT
payment_installments,
COUNT(*) AS payment_count
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;

-- What is the average payment value by payment method?

SELECT
payment_type,
ROUND(AVG(payment_value), 2) AS average_payment_value,
ROUND(SUM(payment_value), 2) AS total_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

-- ============================================================
-- 5. CUSTOMER EXPLORATION
-- ============================================================

-- How many orders are associated with each customer?

SELECT
customer_id,
COUNT(DISTINCT order_id) AS order_count
FROM orders
GROUP BY customer_id
ORDER BY order_count DESC
LIMIT 20;

-- How many unique customers are represented in the dataset?

SELECT
COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- How many customer records map to each unique customer?
-- This helps distinguish the order-level customer ID from the
-- persistent customer identifier.

SELECT
customer_unique_id,
COUNT(DISTINCT customer_id) AS customer_id_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1
ORDER BY customer_id_count DESC;

-- ============================================================
-- 6. REVIEW EXPLORATION
-- ============================================================

-- Distribution of review scores.

SELECT
review_score,
COUNT(*) AS review_count,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (),
2
) AS review_share
FROM reviews
GROUP BY review_score
ORDER BY review_score;

-- Average review score by month.

SELECT
TO_CHAR(
DATE_TRUNC('month', review_creation_date),
'YYYY-MM'
) AS review_month,
ROUND(AVG(review_score), 2) AS average_review_score,
COUNT(*) AS review_count
FROM reviews
GROUP BY DATE_TRUNC('month', review_creation_date)
ORDER BY DATE_TRUNC('month', review_creation_date);

-- ============================================================
-- 7. DELIVERY EXPLORATION
-- ============================================================

-- How long do delivered orders typically take?

SELECT
ROUND(
AVG(
order_delivered_customer_date::date
- order_purchase_timestamp::date
),
2
) AS average_delivery_days,

```
PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY
            order_delivered_customer_date::date
            - order_purchase_timestamp::date
    ) AS median_delivery_days,

MIN(
    order_delivered_customer_date::date
    - order_purchase_timestamp::date
) AS minimum_delivery_days,

MAX(
    order_delivered_customer_date::date
    - order_purchase_timestamp::date
) AS maximum_delivery_days
```

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- What proportion of delivered orders arrived late,
-- on time, or early relative to the estimated delivery date?

SELECT
CASE
WHEN order_delivered_customer_date IS NULL
THEN 'Not delivered'
WHEN order_delivered_customer_date
<= order_estimated_delivery_date
THEN 'On time'
ELSE 'Late'
END AS delivery_status,

```
COUNT(*) AS order_count,

ROUND(
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (),
    2
) AS order_share
```

FROM orders
GROUP BY delivery_status
ORDER BY order_count DESC;

-- Average delivery time by customer state.

SELECT
c.customer_state AS state,

```
ROUND(
    AVG(
        o.order_delivered_customer_date::date
        - o.order_purchase_timestamp::date
    ),
    2
) AS average_delivery_days,

COUNT(*) AS delivered_orders
```

FROM orders o

JOIN customers c
ON o.customer_id = c.customer_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state
ORDER BY average_delivery_days DESC;

-- ============================================================
-- 8. ORDER STATUS EXPLORATION
-- ============================================================

-- Distribution of order statuses.

SELECT
order_status,
COUNT(*) AS order_count,
ROUND(
COUNT(*) * 100.0 /
SUM(COUNT(*)) OVER (),
2
) AS order_share
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Order status by month.
-- Useful for identifying changes in cancellations,
-- unavailable orders, or other operational issues.

SELECT
TO_CHAR(
DATE_TRUNC('month', order_purchase_timestamp),
'YYYY-MM'
) AS purchase_month,

```
order_status,

COUNT(*) AS order_count
```

FROM orders

GROUP BY
DATE_TRUNC('month', order_purchase_timestamp),
order_status

ORDER BY
DATE_TRUNC('month', order_purchase_timestamp),
order_status;

