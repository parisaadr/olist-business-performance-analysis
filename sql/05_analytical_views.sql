/*
============================================================
Olist business performance analysis
Analytical Views
============================================================

Purpose:
Create reusable analytical views at different business
grains so that downstream analysis can be performed without
repeatedly rebuilding joins and aggregations.

Analytical grains:
1. order_level    -> one row per order
2. customer_level -> one row per customer
3. category_level -> one row per product category

These views intentionally separate data preparation from
business questions. Specific analyses are performed in
05_business_metrics.sql.
-- ============================================================
*/

-- ============================================================
-- 1. ORDER-LEVEL VIEW
-- ============================================================
--
-- Grain: One row per order
--
-- Combines:
--   - Order information
--   - Customer information
--   - Item-level financials
--   - Payment information
--   - Review information
--   - Delivery performance
--
-- This is the primary analytical view for:
--   - Revenue analysis
--   - Order trends
--   - AOV
--   - Geographic performance
--   - Delivery analysis
--   - Customer purchase behavior
-- ============================================================

DROP VIEW IF EXISTS order_level;

CREATE VIEW order_level AS

WITH item_totals AS (

    SELECT
        order_id,

        -- Product value excluding freight
        SUM(price) AS order_value,

        -- Total freight charged for the order
        SUM(freight_value) AS freight_value,

        -- Number of products/items in the order
        COUNT(order_item_id) AS item_count,

        -- Number of distinct sellers involved in the order
        COUNT(DISTINCT seller_id) AS seller_count

    FROM items

    GROUP BY order_id
),

review_totals AS (

    SELECT
        order_id,

        -- Some orders may have multiple review records.
        -- Average them to maintain one row per order.
        AVG(review_score) AS review_score

    FROM reviews

    GROUP BY order_id
)

SELECT

    -- --------------------------------------------------------
    -- Identifiers
    -- --------------------------------------------------------

    o.order_id,
    c.customer_unique_id,
    c.customer_state,

    -- --------------------------------------------------------
    -- Order information
    -- --------------------------------------------------------

    o.order_status,
    o.order_purchase_timestamp AS purchase_date,

    -- Useful time dimensions for trend analysis
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS purchase_year,

    DATE_TRUNC(
        'quarter',
        o.order_purchase_timestamp
    ) AS purchase_quarter,

    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    ) AS purchase_month,

    -- --------------------------------------------------------
    -- Delivery information
    -- --------------------------------------------------------

    o.order_estimated_delivery_date AS estimated_delivery_date,
    o.order_delivered_customer_date AS delivered_date,

    -- Number of calendar days between purchase and delivery
    (
        o.order_delivered_customer_date::date
        - o.order_purchase_timestamp::date
    ) AS delivery_days,

    -- --------------------------------------------------------
    -- Financial and order metrics
    -- --------------------------------------------------------

    it.order_value,
    it.freight_value,

    -- Total customer order value including freight
    (
        it.order_value + it.freight_value
    ) AS total_order_value,

    it.item_count,
    it.seller_count,

    -- --------------------------------------------------------
    -- Customer experience
    -- --------------------------------------------------------

    rt.review_score

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN item_totals it
    ON o.order_id = it.order_id

LEFT JOIN review_totals rt
    ON o.order_id = rt.order_id;


-- ============================================================
-- 2. CUSTOMER-LEVEL VIEW
-- ============================================================
--
-- Grain: One row per unique customer
--
-- Purpose:
-- Transform order-level activity into customer-level metrics
-- that can be used for:
--   - Customer segmentation
--   - Repeat purchase analysis
--   - Retention analysis
--   - Customer revenue analysis
--   - Purchase interval analysis
--
-- Note:
-- customer_unique_id is used rather than customer_id because
-- the dataset can contain multiple customer IDs representing
-- the same underlying customer.
-- ============================================================

DROP VIEW IF EXISTS customer_level;

CREATE VIEW customer_level AS

WITH customer_orders AS (

    SELECT
        customer_unique_id,

        order_id,
        purchase_date,
        total_order_value

    FROM order_level
),

customer_metrics AS (

    SELECT

        customer_unique_id,

        -- First and most recent purchase
        MIN(purchase_date) AS first_purchase_date,
        MAX(purchase_date) AS last_purchase_date,

        -- Total number of orders
        COUNT(DISTINCT order_id) AS total_orders,

        -- Total customer revenue
        SUM(total_order_value) AS total_revenue,

        -- Average value of an order
        AVG(total_order_value) AS average_order_value

    FROM customer_orders

    GROUP BY customer_unique_id
)

SELECT

    customer_unique_id,

    first_purchase_date,
    last_purchase_date,

    total_orders,

    total_revenue,
    average_order_value,

    -- Number of days since the customer's latest purchase
    CURRENT_DATE - last_purchase_date::date
        AS days_since_last_purchase

FROM customer_metrics;


-- ============================================================
-- 3. CATEGORY-LEVEL VIEW
-- ============================================================
--
-- Grain: One row per product category
--
-- Purpose:
-- Aggregate product and order activity into category-level
-- business metrics.
--
-- Used for:
--   - Category revenue analysis
--   - Sales volume analysis
--   - Delivery performance analysis
--   - Customer experience analysis
--
-- Delivery and review metrics are calculated at order level
-- before being combined with category information. This avoids
-- treating individual items within the same order as separate
-- delivery events.
-- ============================================================

DROP VIEW IF EXISTS category_level;

CREATE VIEW category_level AS

WITH order_delivery AS (

    SELECT

        order_id,

        order_delivered_customer_date AS delivered_date,

        order_estimated_delivery_date AS estimated_delivery_date,

        -- Actual delivery time
        (
            order_delivered_customer_date::date
            - order_purchase_timestamp::date
        ) AS delivery_days

    FROM orders
),

order_reviews AS (

    SELECT

        order_id,

        -- Average review score where multiple reviews exist
        AVG(review_score) AS review_score

    FROM reviews

    GROUP BY order_id
),

category_orders AS (

    SELECT DISTINCT

        i.order_id,
        p.product_category_name AS category

    FROM items i

    LEFT JOIN products p
        ON i.product_id = p.product_id
)

SELECT

    co.category,

    -- --------------------------------------------------------
    -- Sales volume
    -- --------------------------------------------------------

    COUNT(DISTINCT co.order_id) AS orders,

    COUNT(i.order_item_id) AS items_sold,

    -- --------------------------------------------------------
    -- Financial performance
    -- --------------------------------------------------------

    SUM(i.price) AS revenue,

    SUM(i.freight_value) AS freight_revenue,

    (
        SUM(i.price)
        + SUM(i.freight_value)
    )
    / COUNT(DISTINCT co.order_id)::numeric
        AS average_order_value,

    -- --------------------------------------------------------
    -- Operational performance
    -- --------------------------------------------------------

    AVG(od.delivery_days) AS average_delivery_time,

    -- --------------------------------------------------------
    -- Customer experience
    -- --------------------------------------------------------

    AVG(orv.review_score) AS average_review_score

FROM category_orders co

JOIN items i
    ON co.order_id = i.order_id

LEFT JOIN order_delivery od
    ON co.order_id = od.order_id

LEFT JOIN order_reviews orv
    ON co.order_id = orv.order_id

GROUP BY co.category;
