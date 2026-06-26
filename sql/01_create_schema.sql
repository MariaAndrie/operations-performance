/*
=========================================================
Project: Operations Performance & KPI Dashboard
file: 01_create_schema.sql

Description:
The database supports two related portfolio projects:
1. operations performance & kpi dashboard
2. operational cost & resource utilization analysis

The dataset simulates a multi-region internal it operations
department and supports sla monitoring, ticket performance,
capacity planning, resource utilization and cost analysis.
=========================================================
*/
create database if not exists operations_analytics_db;
use operations_analytics_db;
select database();

-- =====================================================
-- Dimension Tables
-- =====================================================
create table dim_region (
    region_id int primary key,
    region_name varchar(100)
);

create table dim_team (
    team_id int primary key,
    team_name varchar(100)
);

create table dim_service (
    service_id int primary key,
    service_name varchar(150),
    criticality varchar(50),
    primary_team_id int,
    secondary_team_id int
);

create table dim_priority (
    priority_id int primary key,
    priority_name varchar(50),
    sla_target_hours int
);

create table dim_date (
    date date primary key,
    year int,
    quarter varchar(10),
    month int,
    month_name varchar(20),
    month_start date,
    week int,
    day_of_week varchar(20),
    is_weekend boolean
);

-- =====================================================
-- Fact Tables
-- =====================================================

create table fact_tickets (
    ticket_id int primary key,
    created_date date,
    closed_date date,
    region_id int,
    team_id int,
    service_id int,
    priority_id int,
    ticket_type varchar(50),
    complexity varchar(50),
    status varchar(30),
    resolution_hours decimal(10,2),
    sla_target_hours int,
    sla_met boolean,
    escalated boolean,
    reopened boolean
);

create table fact_csat (
    ticket_id int primary key,
    survey_sent boolean,
    survey_responded boolean,
    csat_score int
);


create table fact_capacity (
    month_start date,
    team_id int,
    region_id int,
    fte decimal(10,1),
    available_hours decimal(10,1),
    worked_hours decimal(10,1),
    overtime_hours decimal(10,1)
);


create table fact_costs (
    month_start date,
    team_id int,
    region_id int,
    budget decimal(12,2),
    actual_cost decimal(12,2)
);

create table fact_cost_details (
    month_start date,
    team_id int,
    region_id int,
    cost_category varchar(50),
    budget_amount decimal(12,2),
    actual_amount decimal(12,2)
);

-- =====================================================
-- Performance Indexes
-- =====================================================

create index idx_tickets_created_date
on fact_tickets(created_date);

create index idx_tickets_team
on fact_tickets(team_id);

create index idx_tickets_region
on fact_tickets(region_id);

create index idx_tickets_service
on fact_tickets(service_id);

show index from fact_tickets;

