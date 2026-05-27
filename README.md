# Olist Order Lifecycle Data Engineering Project

## Overview

This project explores how ecommerce order data can be transformed, validated, and organized using a layered data engineering workflow built with dbt and PostgreSQL.

The focus of the project is not dashboarding or analytics visualization, but building reliable transformation pipelines that can detect inconsistencies in real-world operational data.

Using the Olist ecommerce dataset, I modeled the lifecycle of an order from purchase to delivery and implemented validation logic to identify missing stages, incorrect event sequences, and inconsistent status updates.

---

# Tech Stack

- SQL
- PostgreSQL
- dbt

---

# Project Workflow

The project follows a layered transformation approach:

```text
Raw Source Data
    ↓
Staging Layer
    ↓
Intermediate Validation Layer
    ↓
Mart / Summary Layer
```

---

# What Was Built

## Source & Staging Layer

- Connected dbt with PostgreSQL source tables
- Configured source definitions using YAML
- Applied basic data quality checks such as:
  - unique constraints
  - not-null validations
- Built staging views to clean and standardize order data

---

## Intermediate Layer

This layer contains the core transformation logic of the project.

### Order Lifecycle Tracking

Orders were modeled as a sequence of lifecycle stages:
- purchase
- approval
- dispatch
- delivery

Lifecycle stages were mapped and tracked to analyze how orders progressed through the ecommerce pipeline.

---

### Data Validation & Consistency Checks

Implemented validation logic to detect:
- missing timestamps
- missing status updates
- incomplete lifecycle stages
- out-of-order event sequences

Examples:
- delivery recorded before approval
- dispatch updated without timestamp
- missing intermediate stages in the order flow

---

### Operational Anomaly Detection

Additional checks were created to identify:
- unavailable orders after specific stages
- partially completed order flows
- inconsistent operational transitions

Reusable dbt macros were also used to simplify validation logic across models.

---

## Mart Layer

Built summary tables to:
- aggregate validation results
- calculate anomaly ratios
- track lifecycle inconsistencies across orders

Examples of generated metrics:
- percentage of rows with missing statuses
- frequency of sequencing anomalies
- lifecycle completion statistics

---

# Key Concepts Demonstrated

- layered data modeling
- dbt transformation workflows
- lifecycle-based data processing
- temporal validation logic
- data quality engineering
- reusable SQL transformations

---

# Project Scope

This project was designed as a foundational data engineering exercise focused on transformation and validation workflows.

Areas intentionally not covered:
- dashboards
- visualization tools
- orchestration pipelines
- production deployment

---

# Dataset

Dataset used:
- Brazilian E-Commerce Public Dataset by Olist

Dataset source:
- https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

# Author

Kiruthika Soundararajan

