/*
===============================================================================
Olist business performance analysis
Data quality validation
===============================================================================

Purpose:
Validate completeness, consistency, and integrity of the imported dataset before
building analytical views and business metrics.

Checks included:
- Row counts
- Duplicate primary keys
- Missing values
- Order status distribution
- Date range validation
- Referential integrity
===============================================================================
*/


-- =============================================================================
-- Row counts
-- =============================================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'items', COUNT(*) FROM items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'category', COUNT(*) FROM category;


-- =============================================================================
-- Duplicate primary key checks
-- =============================================================================

-- Duplicate customer IDs
SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate order IDs
SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicate product IDs
SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Duplicate seller IDs
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- Duplicate review IDs
SELECT review_id, COUNT(*)
FROM reviews
GROUP BY review_id
HAVING COUNT(*) > 1;


-- =============================================================================
-- Missing values
-- =============================================================================

-- Missing delivery dates
SELECT
    COUNT(*) AS total_orders,
    COUNT(order_delivered_customer_date) AS delivered_orders,
    COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_dates,
    ROUND(
        (COUNT(*) - COUNT(order_delivered_customer_date))
        * 100.0 / COUNT(*),
        2
    ) AS missing_delivery_percentage
FROM orders;

-- Missing product categories
SELECT
    COUNT(*) AS products,
    COUNT(product_category_name) AS categorized_products,
    COUNT(*) - COUNT(product_category_name) AS missing_categories
FROM products;

-- Missing review scores
SELECT
    COUNT(*) AS reviews,
    COUNT(review_score) AS scored_reviews,
    COUNT(*) - COUNT(review_score) AS missing_review_scores
FROM reviews;


-- =============================================================================
-- Order status distribution
-- =============================================================================

SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- =============================================================================
-- Purchase date validation
-- =============================================================================

SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;


-- =============================================================================
-- Delivery date validation
-- =============================================================================

-- Orders delivered before purchase (should be zero)
SELECT COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- Estimated delivery before purchase (should be zero)
SELECT COUNT(*) AS invalid_estimated_dates
FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;


-- =============================================================================
-- Referential integrity checks
-- =============================================================================

-- Orders with missing customers
SELECT COUNT(*) AS orders_without_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items with missing products
SELECT COUNT(*) AS items_without_products
FROM items i
LEFT JOIN products p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Order items with missing sellers
SELECT COUNT(*) AS items_without_sellers
FROM items i
LEFT JOIN sellers s
    ON i.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Payments with missing orders
SELECT COUNT(*) AS payments_without_orders
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Reviews with missing orders
SELECT COUNT(*) AS reviews_without_orders
FROM reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;
