# Operations Performance & KPI Dashboard

## Project Overview

End-to-end Business Intelligence project focused on IT Operations performance, SLA monitoring, KPI management, and service delivery analytics.

The project uses a synthetic dataset to simulate an internal IT Operations environment and demonstrates how SQL and Power BI can be used to monitor operational performance, identify service bottlenecks, and support management reporting.

---

## Dashboard Preview

### Executive Overview

![Executive Overview](/images/executive_overview.png)

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
* Where are operational issues concentrated?
* Which teams contribute most to ticket backlog and escalations?
---

## Technology Stack

* MySQL
* SQL
* Power BI
* DAX
* Star Schema Data model
* Git & GitHub
* Python for synthetic dataset generation

---

## Data Model

The solution follows a star schema design.

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
├── images/
│   ├── executive_overview.png
│   ├── operational_performance.png
│   └── KPI_scorecard.png
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
* Tickets Received
* Open Ticket Backlog
* Monthly SLA Trend
* Monthly Ticket Volume
* Monthly CSAT Trend
* YoY and MoM KPI changes

---

## Power BI Dashboard

### Executive Overview

High-level operational KPIs with monthly trends and management.

The page includes:

SLA target achievement
customer satisfaction
ticket volume
escalation rate
open ticket backlog
average resolution time
comparison with the previous year
dynamic filters by region, team, and service

### Executive Overview dashboard preview

![Executive Overview](/images/executive_overview.png)

---

### Operational Performance

Performance breakdown by:

* Team
* Region
* Service
* Priority
* SLA performance
* Escalation rate
* Resolution time
* Backlog contribution
* Ticket volume


### Operational Performance dashboard preview

![Operational Performance](/images/operational_performance.png)


### KPI Scorecard

Comparison of:

* Actual KPI
* Target KPI
* KPI Status
* Variance from target


### KPI Scorecard preview

![Performance Scorecard](/images/KPI_scorecard.png)


---

## Key Insights

* Overall SLA compliance is approximately 78%, above the 77% target.
* SLA performance declined slightly compared with the previous year.
* Ticket volume increased, with the strongest growth occurring in Q4.
* Escalated tickets receive significantly lower CSAT scores.
* Reopened tickets have noticeably lower customer satisfaction.
* Complex tickets receive lower CSAT ratings than simple requests.
* Resolution times above 72 hours are associated with lower customer satisfaction.
* Workplace Support consistently demonstrates the highest SLA performance.
* Network Operations shows the lowest SLA performance and the highest escalation rate.
* The ticket backlog improved month over month, although it remains above the previous-year level.

---

## Work in Progress

Power BI dashboard development is currently in progress.
Dashboard screenshots and the final `.pbix` file will be added upon completion.

