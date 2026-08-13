# Olist business performance analysis

## Executive summary

This project analyzes the performance of a Brazilian e-commerce marketplace using SQL and a structured business analytics framework. The objective was to evaluate whether business growth translated into customer value and operational performance by examining revenue trends, customer retention, delivery reliability, and category performance.

A PostgreSQL data model was built from the raw Olist dataset, followed by the creation of analytical views at the order, customer, and product category levels. These views were used to answer executive-level business questions related to growth quality, customer economics, and operational execution.

## Business objective

Rather than performing exploratory analysis alone, this project approaches the dataset as a quarterly business performance review.

The analysis focuses on three executive questions:

* Is the business growing sustainably?
* Are customers generating long-term value?
* Are operations supporting customer satisfaction and profitable growth?

## Analytical framework

### Executive performance

* Monthly order growth
* Revenue growth
* Average order value
* Geographic revenue concentration

### Customer economics

* Repeat purchase rate
* Revenue contribution from repeat customers
* Customer revenue segmentation
* Time between purchases

### Operational performance

* Delivery delays by product category
* Relationship between delivery performance and review scores
* Customer experience indicators

## Data model

The analysis is built on three analytical views.

| View           | Grain                | Purpose                                          |
| -------------- | -------------------- | ------------------------------------------------ |
| order_level    | One row per order    | Growth, revenue, delivery, and customer behavior |
| customer_level | One row per customer | Retention, segmentation, and customer value      |
| category_level | One row per category | Product performance and operational analysis     |

## Key findings

### Growth was primarily driven by order volume

Order volume increased substantially across the analysis period, and revenue grew alongside transaction activity. Average order value remained relatively stable, indicating that revenue expansion was driven primarily by higher purchasing volume rather than sustained increases in order value.

### Repeat purchasing was limited

Only **3.12% of customers placed more than one order**, and repeat customers accounted for **5.82% of total revenue**. The business relied heavily on one-time purchasers, suggesting that customer retention represented a meaningful growth opportunity.

### Delivery performance was strongly associated with customer satisfaction

Orders delivered on time received an average review score of **4.30**, compared with **2.57** for late deliveries and **1.74** for undelivered orders. While this analysis does not establish causation, it shows a clear association between operational reliability and customer experience.

### Revenue was geographically concentrated

São Paulo contributed the largest share of marketplace revenue, indicating a significant concentration of commercial activity in a small number of geographic markets.

## Repository structure

```text
sql/
  01_create_tables.sql
  02_data_quality.sql
  03_exploration.sql
  04_analytical_views.sql
  05_business_metrics.sql

documentation/
  01_data_dictionary.md
  02_business_questions.md
  03_methodology.md
```

## Technical stack

* PostgreSQL
* SQL
* Data modeling
* KPI analysis
* Cohort and retention analysis
* Business performance analytics

## Project outcome

This project demonstrates an end-to-end business analytics workflow: transforming raw transactional data into analytical models, developing reusable business metrics, and translating quantitative findings into strategic insights that could support executive decision-making in an e-commerce or fintech environment.
