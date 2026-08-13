# Data dictionary

## Overview

This project transforms the raw Olist e-commerce dataset into three analytical views designed for business performance analysis. Each view represents a different analytical grain and supports a specific set of business questions related to growth, customer behavior, and operational performance.

## Analytical views

### order_level

**Grain:** One row per order

The `order_level` view is the primary analytical dataset used throughout the project. It consolidates customer, revenue, delivery, and review information into a single order-level record.

| Column                  | Description                        |
| ----------------------- | ---------------------------------- |
| order_id                | Unique order identifier            |
| customer_unique_id      | Unique customer identifier         |
| customer_state          | Customer state (Brazil)            |
| order_status            | Order fulfillment status           |
| purchase_date           | Order purchase timestamp           |
| purchase_year           | Purchase year                      |
| purchase_quarter        | Purchase quarter                   |
| purchase_month          | Purchase month                     |
| estimated_delivery_date | Estimated delivery date            |
| delivered_date          | Actual delivery date               |
| delivery_days           | Days between purchase and delivery |
| order_value             | Product value of the order         |
| freight_value           | Shipping cost                      |
| total_order_value       | Product value plus freight         |
| item_count              | Number of items in the order       |
| seller_count            | Number of unique sellers           |
| review_score            | Average customer review score      |

### customer_level

**Grain:** One row per unique customer

The `customer_level` view summarizes purchasing behavior and customer value across the customer lifecycle.

| Column                   | Description                         |
| ------------------------ | ----------------------------------- |
| customer_unique_id       | Unique customer identifier          |
| first_purchase_date      | First recorded purchase             |
| last_purchase_date       | Most recent purchase                |
| total_orders             | Total number of orders              |
| total_revenue            | Lifetime revenue generated          |
| average_order_value      | Average order value                 |
| days_since_last_purchase | Days since the most recent purchase |

### category_level

**Grain:** One row per product category

The `category_level` view evaluates commercial and operational performance by product category.

| Column                | Description                     |
| --------------------- | ------------------------------- |
| category              | Product category                |
| orders                | Number of unique orders         |
| items_sold            | Number of items sold            |
| revenue               | Total product revenue           |
| freight_revenue       | Total freight revenue           |
| average_order_value   | Average order value by category |
| average_delivery_time | Average delivery time           |
| average_review_score  | Average customer review score   |

## Metric definitions

### Revenue

Total order value including both product price and freight charges.

```text
Revenue = Order Value + Freight Value
```

### Average order value (AOV)

Average revenue generated per order.

```text
AOV = Total Revenue / Number of Orders
```

### Repeat customer

A customer with more than one completed order.

### Repeat customer revenue

Revenue generated from all purchases after a customer’s first order.

### Delivery delay

An order delivered after its estimated delivery date.

### Delivery performance segments

* **On time:** Delivered on or before the estimated delivery date
* **Late:** Delivered after the estimated delivery date
* **Not delivered:** No recorded delivery date

## Analytical assumptions

* One order may contain multiple items and multiple sellers.
* Revenue is measured at the order level.
* Review scores are averaged at the order level when multiple reviews exist.
* Customer behavior is analyzed using `customer_unique_id` rather than `customer_id`.
* Delivery time is measured from purchase date to customer delivery date.
* Missing delivery dates are treated as undelivered orders rather than data errors.

## Intended use

The analytical views are designed to support business performance monitoring, customer economics analysis, operational performance evaluation, and executive KPI reporting.

