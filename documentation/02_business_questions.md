# Business questions

## Purpose of the analysis

This project was designed as a business performance review rather than a technical SQL exercise. The objective was to evaluate whether marketplace growth was creating sustainable business value by examining performance across three areas:

* Executive performance
* Customer economics
* Operational performance

Each question was chosen to support a management decision related to growth, retention, or operational execution.

---

# Executive performance

## Is the business growing?

### How many orders were placed each month?

**Business objective**

Measure transaction growth over time and identify periods of acceleration or slowdown.

**Management relevance**

Order growth is a leading indicator of marketplace activity and demand.

### How did revenue change month over month?

**Business objective**

Evaluate whether revenue growth is keeping pace with transaction growth.

**Management relevance**

Revenue trends help assess commercial performance and support forecasting and planning.

### What was the average order value over time?

**Business objective**

Determine whether revenue growth is driven by larger orders or higher order volume.

**Management relevance**

Average order value helps distinguish volume-driven growth from value-driven growth.

### Which states contributed the most revenue?

**Business objective**

Identify geographic concentration of revenue.

**Management relevance**

Understanding regional dependence supports market expansion, investment prioritization, and risk assessment.

---

# Customer economics

## Is growth creating long-term customer value?

### What percentage of customers made more than one purchase?

**Business objective**

Measure customer retention and repeat purchasing behavior.

**Management relevance**

A low repeat purchase rate suggests that growth depends heavily on customer acquisition.

### How much revenue came from repeat customers?

**Business objective**

Evaluate the financial contribution of retained customers.

**Management relevance**

Repeat customers often generate higher lifetime value and lower acquisition costs.

### Which customer segments generated the most revenue?

**Business objective**

Compare the revenue contribution of one-time, occasional, frequent, and loyal customers.

**Management relevance**

Customer segmentation helps prioritize retention strategies and commercial investment.

### How long did customers typically take to make another purchase?

**Business objective**

Measure the interval between purchases.

**Management relevance**

Repurchase timing supports retention campaigns, CRM planning, and customer lifecycle management.

---

# Operational performance

## Are operations supporting customer satisfaction?

### Which categories had the highest delivery delays?

**Business objective**

Identify product categories with operational performance problems.

**Management relevance**

Delivery delays can affect customer satisfaction, refunds, and operational costs.

### Was poor delivery performance associated with lower review scores?

**Business objective**

Evaluate whether delivery reliability is related to customer experience.

**Management relevance**

If delayed orders receive consistently lower reviews, operational improvements may directly improve customer satisfaction and retention.

---

# Analytical approach

The analysis was performed using three analytical views:

* **order_level** for growth, revenue, delivery, and customer behavior
* **customer_level** for retention and customer value
* **category_level** for category performance and operational analysis

The overall goal was to transform raw transactional data into decision-oriented business metrics that could support executive performance monitoring and strategic planning.

