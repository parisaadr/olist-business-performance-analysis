# Methodology

## Analytical approach

The project was designed as a structured business performance analysis rather than a collection of independent SQL queries. The workflow focused on transforming raw transactional data into analytical datasets that support executive reporting, customer analysis, and operational performance evaluation.

The analysis followed four stages:

1. Data preparation
2. Data quality validation
3. Analytical data modeling
4. Business metric development

---

# Data preparation

The original Olist dataset consists of multiple transactional tables representing customers, orders, order items, payments, reviews, products, sellers, and category translations.

A PostgreSQL database was created and normalized relational tables were established using primary and foreign key relationships.

The analysis used SQL to aggregate transactional data into reusable analytical views.

---

# Data quality validation

Before constructing business metrics, several validation checks were performed.

## Duplicate detection

Primary key uniqueness was verified across customer and order tables to ensure entity integrity.

## Missing value assessment

Critical operational fields were evaluated for completeness, particularly delivery dates and review information.

Missing delivery dates were treated as undelivered orders rather than automatically imputed.

## Temporal validation

Order timestamps were reviewed to establish the analysis period and identify incomplete edge periods that could distort trend analysis.

---

# Analytical data modeling

Three analytical views were created to support different levels of business analysis.

## order_level

Consolidates customer, revenue, delivery, and review information into a single order-level dataset.

This view serves as the primary fact table for growth, revenue, and operational analysis.

## customer_level

Aggregates purchasing behavior across the customer lifecycle.

This view supports retention, segmentation, and customer value analysis.

## category_level

Aggregates commercial and operational performance by product category.

This view supports category performance evaluation and delivery analysis.

---

# Metric construction

## Revenue

Revenue was calculated as total product value plus freight value.

```text
Revenue = Order Value + Freight Value
```

## Average order value

Calculated using total revenue divided by the number of orders.

## Repeat customer

A repeat customer was defined as a customer with more than one recorded order.

## Repeat customer revenue

Revenue generated from purchases after a customer’s first order.

## Delivery delay

Orders delivered after the estimated delivery date.

---

# Customer analysis methodology

## Retention

Customer retention was evaluated using purchase frequency at the customer level.

The analysis measured:

* Repeat purchase rate
* Revenue contribution from repeat customers
* Customer segmentation by purchase frequency
* Time between purchases

Window functions were used to identify purchase sequences and calculate interpurchase intervals.

---

# Operational analysis methodology

Delivery performance was analyzed by comparing actual delivery dates with estimated delivery dates.

Orders were classified into:

* On time
* Late
* Not delivered

Review scores were then analyzed across delivery segments to evaluate the relationship between operational reliability and customer satisfaction.

---

# Analytical assumptions

The methodology assumes:

* One row per order in the `order_level` view
* Revenue measured at the order level
* Customer behavior identified using `customer_unique_id`
* Review scores averaged when multiple reviews existed for a single order
* Delivery time measured from purchase date to customer delivery date

---

# Limitations

Several limitations should be considered when interpreting the results.

* The dataset represents historical marketplace activity and may not reflect current business conditions.
* Early and late periods contain relatively few orders and may not be representative of underlying demand.
* Review behavior may be influenced by factors beyond delivery performance.
* The analysis identifies statistical associations rather than causal relationships.

Despite these limitations, the analytical framework provides a structured approach for evaluating marketplace growth, customer value, and operational performance using reproducible SQL-based business metrics.

