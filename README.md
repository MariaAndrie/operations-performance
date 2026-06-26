# Operations Performance & KPI Dashboard

## Project Overview

End-to-end Business Intelligence project focused on IT Operations performance, SLA monitoring, KPI management, and service delivery analytics.

The project uses a synthetic dataset to simulate an internal IT Operations environment and demonstrates how SQL and Power BI can be used to monitor operational performance, identify service bottlenecks, and support management reporting.

---

## Data Note

This project uses a synthetic dataset generated for portfolio purposes.  
The data does not represent any real company, customer, employee, or operational system.

The dataset was designed to simulate a realistic internal IT Operations environment, including ticket volumes, SLA performance, escalations, CSAT responses, team capacity, and operational costs.

---

## Business Objectives

The dashboard answers the following business questions:

* Are SLA targets being achieved?
* Which teams have the best operational performance?
* How do escalations affect customer satisfaction?
* What factors influence CSAT?
* How do ticket volumes change over time?
* Which KPIs require management attention?

---

## Technology Stack

* MySQL
* SQL
* Power BI
* DAX
* Star Schema Data Warehouse
* Git & GitHub

---

## Data Model

The solution follows a Star Schema design.

### Fact Tables

* fact_tickets
* fact_csat
* fact_capacity
* fact_costs
* fact_cost_details

### Dimension Tables

* dim_date
* dim_team
* dim_region
* dim_service
* dim_priority

---

## Project Structure

```
operations-performance/

│
├── data/
│   ├── dim_date.csv
│   ├── fact_tickets.csv
│   ├── fact_csat.csv
│   └── ...
│
├── python/
│   └── generate_operations_kpi_dataset.py
│
├── sql/
│   ├── 01_create_schema.sql
│   ├── 02_load_data.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_business_logic_validation.sql
│   └── 06_kpi_analysis.sql
│
├── powerbi/
│   └── Operations_Performance_Dashboard.pbix
│
├── screenshots/
│   ├── executive_overview.png
│   ├── operational_performance.png
│   └── kpi_scorecard.png
│
└── README.md
```

```

---

## Data Quality Validation

The project includes automated SQL validation for:

* duplicate ticket IDs
* missing values
* date range validation
* ticket status distribution
* SLA compliance distribution
* CSAT response rate

---

## Business Logic Validation

Business rules were validated using SQL before dashboard development.

Examples include:

* SLA vs CSAT
* SLA by team
* CSAT by team
* Escalation impact on CSAT
* Complexity vs CSAT
* Reopened tickets vs CSAT
* Resolution time vs CSAT

---

## KPI Analysis

The dashboard tracks several operational KPIs:

* SLA Compliance
* Average Resolution Time
* Escalation Rate
* Average CSAT
* Monthly SLA Trend
* Monthly Ticket Volume
* Monthly CSAT Trend

---

## Dashboard Pages

### Executive Overview

High-level operational KPIs with monthly trends.

### Operational Performance

Performance breakdown by:

* Team
* Region
* Service
* Priority
* Criticality

### KPI Scorecard

Comparison of:

* Actual KPI
* Target KPI
* KPI Status

---

## Key Insights

* Overall SLA compliance is approximately **79%**, below the target of **85%**.
* Escalated tickets receive significantly lower CSAT scores.
* Reopened tickets have noticeably lower customer satisfaction.
* Complex tickets receive lower CSAT ratings than simple requests.
* Resolution times above 72 hours are associated with lower customer satisfaction.
* Workplace Support consistently demonstrates the highest SLA performance.

---


