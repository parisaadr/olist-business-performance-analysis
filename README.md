# Olist business performance analysis

## Executive summary

This project analyzes the performance of a Brazilian e-commerce marketplace using SQL and a structured business analytics framework. The objective is to evaluate whether business growth is translating into customer value and operational performance by examining revenue trends, customer retention, delivery reliability, and category performance.

A PostgreSQL data model was built from the raw Olist dataset, followed by the creation of analytical views at the order, customer, and product category levels. These views were used to answer strategic business questions related to growth quality, customer economics, and operational execution.

## Business objective

Rather than performing exploratory analysis alone, this project approaches the dataset as a quarterly business performance review.

The analysis focuses on three executive questions:

* Is the business growing sustainably?
* Are customers generating long-term value?
* Are operations supporting customer satisfaction and profitable growth?

## Analytical framework

The analysis is organized into three areas.

### Executive performance

* Monthly order growth
* Revenue growth
* Average order value
* Geographic revenue concentration

### Customer economics

* Repeat purchase rate
* Revenue from repeat customers
* Customer revenue segmentation
* Time between purchases

### Operational performance

* Delivery delays by category
* Relationship between delivery performance and review scores
* Customer experience impact

## Data model

The project uses three analytical views.

| View           | Grain                | Purpose                                      |
| -------------- | -------------------- | -------------------------------------------- |
| order_level    | One row per order    | Revenue, growth, delivery, customer behavior |
| customer_level | One row per customer | Retention, segmentation, customer value      |
| category_level | One row per category | Product performance and operational analysis |

## Key findings

* Revenue growth was primarily driven by increasing order volume rather than sustained expansion in average order value.
* A relatively small share of customers generated repeat purchases, but repeat customers contributed a disproportionately large share of total revenue.
* Delivery performance varied significantly across product categories.
* Late deliveries were associated with lower customer review scores, suggesting that operational reliability materially affected customer experience.

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
