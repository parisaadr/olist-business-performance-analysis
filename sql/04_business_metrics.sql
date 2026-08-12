/*
===============================================================================
Olist business performance analysis
Business Metrics
===============================================================================

Purpose:
Answer key business questions across three areas:
----------------------------------------------------
*/

--   1. Executive Performance
--   2. Customer Economics
--   3. Operational Performance
-------------------------------

-- The analysis uses the analytical views created in
-- 05_analytical_views.sql.
---------------------------

-- These queries are designed to translate raw business data
-- into metrics that can support management and strategy
-- discussions.
-- ============================================================

-- ============================================================
-- 1. EXECUTIVE PERFORMANCE
-- Is the business growing?
-- ============================================================

---

-- 1.1 Monthly Order Volume

---

-- Question:
-- How many orders were placed each month?
------------------------------------------

-- Purpose:
-- Monitor overall transaction volume and identify periods
-- of growth, contraction, and unusual activity.

SELECT
TO_CHAR(purchase_month, 'YYYY-MM') AS month,
COUNT(order_id) AS orders
FROM order_level
GROUP BY purchase_month
ORDER BY purchase_month;

---

-- 1.2 Monthly Revenue

---

-- Question:
-- How did revenue change over time?
------------------------------------

-- Purpose:
-- Track the evolution of business revenue alongside order
-- volume.

SELECT
TO_CHAR(purchase_month, 'YYYY-MM') AS month,
ROUND(SUM(total_order_value), 2) AS revenue
FROM order_level
GROUP BY purchase_month
ORDER BY purchase_month;

---

-- 1.3 Month-over-Month Revenue Growth

---

-- Question:
-- How quickly is revenue changing from month to month?
-------------------------------------------------------

-- Purpose:
-- Measure the rate of revenue growth rather than only its
-- absolute value.

WITH monthly_revenue AS (
SELECT
purchase_month,
SUM(total_order_value) AS revenue
FROM order_level
GROUP BY purchase_month
),

revenue_growth AS (
SELECT
purchase_month,
revenue,
LAG(revenue) OVER (
ORDER BY purchase_month
) AS previous_month_revenue
FROM monthly_revenue
)

SELECT
TO_CHAR(purchase_month, 'YYYY-MM') AS month,

```
ROUND(revenue, 2) AS revenue,

ROUND(
    (
        revenue - previous_month_revenue
    ) * 100.0
    / NULLIF(previous_month_revenue, 0),
    2
) AS revenue_growth_percentage
```

FROM revenue_growth
ORDER BY purchase_month;

---

-- 1.4 Average Order Value

---

-- Question:
-- What was the average order value over time?
----------------------------------------------

-- Purpose:
-- Determine whether changes in revenue are being driven by
-- more orders, larger orders, or both.

SELECT
TO_CHAR(purchase_month, 'YYYY-MM') AS month,
ROUND(AVG(total_order_value), 2) AS average_order_value
FROM order_level
GROUP BY purchase_month
ORDER BY purchase_month;

---

-- 1.5 Revenue by Customer State

---

-- Question:
-- Which states contributed the most revenue?
---------------------------------------------

-- Purpose:
-- Identify the geographic markets contributing most to
-- marketplace revenue.

SELECT
customer_state AS state,

```
ROUND(
    SUM(total_order_value),
    2
) AS revenue,

ROUND(
    SUM(total_order_value) * 100.0
    / SUM(SUM(total_order_value)) OVER (),
    2
) AS revenue_share
```

FROM order_level

GROUP BY customer_state

ORDER BY revenue DESC;

-- ============================================================
-- 2. CUSTOMER ECONOMICS
-- Is growth creating long-term customer value?
-- ============================================================

---

-- 2.1 Repeat Customer Rate

---

-- Question:
-- What percentage of customers made more than one purchase?
------------------------------------------------------------

-- Purpose:
-- Measure the proportion of customers returning to the
-- marketplace after their initial purchase.

WITH purchase_counts AS (
SELECT
customer_unique_id,
COUNT(DISTINCT order_id) AS purchase_count
FROM order_level
GROUP BY customer_unique_id
)

SELECT
COUNT(*) AS total_customers,

```
COUNT(*) FILTER (
    WHERE purchase_count > 1
) AS repeat_customers,

ROUND(
    COUNT(*) FILTER (
        WHERE purchase_count > 1
    ) * 100.0
    / COUNT(*),
    2
) AS repeat_customer_percentage
```

FROM purchase_counts;

---

-- 2.2 Revenue from Repeat Customers

---

-- Question:
-- How much revenue came from customers who purchased more
-- than once?
-------------

-- Purpose:
-- Determine how economically important repeat purchasing is
-- to overall revenue.

WITH customer_metrics AS (
SELECT
customer_unique_id,
COUNT(DISTINCT order_id) AS purchase_count,
SUM(total_order_value) AS total_revenue
FROM order_level
GROUP BY customer_unique_id
)

SELECT
ROUND(
SUM(total_revenue),
2
) AS total_revenue,

```
ROUND(
    SUM(total_revenue) FILTER (
        WHERE purchase_count > 1
    ),
    2
) AS repeat_customer_revenue,

ROUND(
    SUM(total_revenue) FILTER (
        WHERE purchase_count > 1
    ) * 100.0
    / SUM(total_revenue),
    2
) AS repeat_customer_revenue_percentage
```

FROM customer_metrics;

---

-- 2.3 Revenue by Customer Segment

---

-- Question:
-- Which customer segments generate the most revenue?
-----------------------------------------------------

-- Segmentation:
--   One-time   = 1 purchase
--   Occasional = 2–3 purchases
--   Frequent   = 4–6 purchases
--   Loyal      = 7+ purchases
------------------------------

-- Purpose:
-- Understand how customer purchasing frequency relates to
-- revenue contribution.

WITH customer_metrics AS (
SELECT
customer_unique_id,

```
    COUNT(DISTINCT order_id) AS total_orders,

    SUM(total_order_value) AS total_revenue

FROM order_level

GROUP BY customer_unique_id
```

),

customer_segments AS (
SELECT
customer_unique_id,
total_orders,
total_revenue,

```
    CASE
        WHEN total_orders = 1
            THEN 'One-time'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional'

        WHEN total_orders BETWEEN 4 AND 6
            THEN 'Frequent'

        ELSE 'Loyal'
    END AS customer_segment

FROM customer_metrics
```

)

SELECT
customer_segment,

```
COUNT(*) AS customers,

ROUND(
    SUM(total_revenue),
    2
) AS revenue,

ROUND(
    AVG(total_revenue),
    2
) AS average_customer_revenue,

ROUND(
    SUM(total_revenue) * 100.0
    / SUM(SUM(total_revenue)) OVER (),
    2
) AS revenue_share
```

FROM customer_segments

GROUP BY customer_segment

ORDER BY revenue DESC;

---

-- 2.4 Time Between Purchases

---

-- Question:
-- How long does it typically take for a customer to make
-- another purchase?
--------------------

-- Purpose:
-- Estimate the natural repurchase interval and provide
-- context for retention and reactivation strategies.

WITH purchase_data AS (
SELECT
customer_unique_id,
order_id,
purchase_date,

```
    LAG(purchase_date) OVER (
        PARTITION BY customer_unique_id
        ORDER BY purchase_date
    ) AS previous_purchase

FROM order_level
```

),

purchase_intervals AS (
SELECT

```
    customer_unique_id,

    purchase_date::date
    - previous_purchase::date AS days_between

FROM purchase_data

WHERE previous_purchase IS NOT NULL
```

)

SELECT

```
ROUND(
    AVG(days_between),
    2
) AS average_days_between_purchases,

PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY days_between
    ) AS median_days_between_purchases,

MIN(days_between) AS minimum_days,

MAX(days_between) AS maximum_days
```

FROM purchase_intervals;

-- ============================================================
-- 3. OPERATIONAL PERFORMANCE
-- Are operations supporting the customer experience?
-- ============================================================

---

-- 3.1 Delivery Performance by Product Category

---

-- Question:
-- Which categories have the highest delivery delay rates?
----------------------------------------------------------

-- Purpose:
-- Identify product categories associated with higher delivery
-- risk and potential operational issues.

WITH order_category AS (

```
SELECT DISTINCT

    o.order_id,

    p.product_category_name AS category,

    o.delivered_date,

    o.estimated_delivery_date

FROM order_level o

JOIN items i
    ON o.order_id = i.order_id

JOIN products p
    ON i.product_id = p.product_id
```

),

delivery_segments AS (

```
SELECT

    order_id,

    category,

    CASE

        WHEN delivered_date IS NULL
            THEN 'Not delivered'

        WHEN delivered_date <= estimated_delivery_date
            THEN 'On time'

        ELSE 'Late'

    END AS delivery_status

FROM order_category
```

)

SELECT

```
category,

COUNT(*) AS total_orders,

COUNT(*) FILTER (
    WHERE delivery_status = 'Late'
) AS late_orders,

ROUND(
    COUNT(*) FILTER (
        WHERE delivery_status = 'Late'
    ) * 100.0
    / COUNT(*),
    2
) AS delay_percentage
```

FROM delivery_segments

GROUP BY category

ORDER BY delay_percentage DESC;

---

-- 3.2 Delivery Performance and Review Scores

---

-- Question:
-- Is poor delivery performance associated with lower review
-- scores?
----------

-- Purpose:
-- Examine whether delivery reliability is associated with
-- customer satisfaction.

WITH order_reviews AS (

```
SELECT DISTINCT

    o.order_id,

    o.delivered_date,

    o.estimated_delivery_date,

    r.review_score

FROM order_level o

JOIN reviews r
    ON o.order_id = r.order_id
```

),

delivery_segments AS (

```
SELECT

    order_id,

    review_score,

    CASE

        WHEN delivered_date IS NULL
            THEN 'Not delivered'

        WHEN delivered_date <= estimated_delivery_date
            THEN 'On time'

        ELSE 'Late'

    END AS delivery_status

FROM order_reviews
```

)

SELECT

```
delivery_status,

COUNT(*) AS total_orders,

ROUND(
    AVG(review_score),
    2
) AS average_review_score,

ROUND(
    COUNT(*) * 100.0
    / SUM(COUNT(*)) OVER (),
    2
) AS order_share
```

FROM delivery_segments

GROUP BY delivery_status

ORDER BY average_review_score;

---

-- 3.3 Review Score by Delivery Performance

---

-- Question:
-- How does review score vary across delivery outcomes?
-------------------------------------------------------

-- Purpose:
-- Provide a direct comparison between late, on-time,
-- early/not-delivered orders and customer satisfaction.

WITH delivery_performance AS (

```
SELECT

    order_id,

    review_score,

    CASE

        WHEN delivered_date IS NULL
            THEN 'Not delivered'

        WHEN delivered_date <= estimated_delivery_date
            THEN 'On time'

        ELSE 'Late'

    END AS delivery_status

FROM order_level

WHERE review_score IS NOT NULL
```

)

SELECT

```
delivery_status,

COUNT(*) AS reviewed_orders,

ROUND(
    AVG(review_score),
    2
) AS average_review_score,

ROUND(
    PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY review_score
        ),
    2
) AS median_review_score
```

FROM delivery_performance

GROUP BY delivery_status

ORDER BY average_review_score;

