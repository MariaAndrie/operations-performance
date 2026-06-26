/*
=========================================================
Project: operations performance & kpi dashboard
file: 03_data_quality_checks.sql

Description:
Validate dataset completeness, consistency
and readiness for KPI reporting and dashboarding.
=========================================================
*/

-- =====================================================
-- verify that all tables were loaded successfully
-- =====================================================

select 'dim_date' as table_name, count(*) as row_count from dim_date
union all
select 'dim_priority', count(*) from dim_priority
union all
select 'dim_region', count(*) from dim_region
union all
select 'dim_team', count(*) from dim_team
union all
select 'dim_service', count(*) from dim_service
union all
select 'fact_tickets', count(*) from fact_tickets
union all
select 'fact_csat', count(*) from fact_csat
union all
select 'fact_capacity', count(*) from fact_capacity
union all
select 'fact_costs', count(*) from fact_costs
union all
select 'fact_cost_details', count(*) from fact_cost_details;

/*
table_name			row_count
dim_date			731
dim_priority		4
dim_region			4
dim_team			5
dim_service			6
fact_tickets		121557
fact_csat			111181
fact_capacity		480
fact_costs			480
fact_cost_details	2400
*/

-- =====================================================
-- check 01: for duplicate ticket ids
-- =====================================================

select ticket_id, count(*) as cnt from fact_tickets
group by ticket_id
having count(*) > 1;

-- expected result: 0 rows

-- =====================================================
-- check 02: missing values in key ticket fields
-- =====================================================

select
    sum(case when ticket_id is null then 1 else 0 end) as missing_ticket_id,
    sum(case when created_date is null then 1 else 0 end) as missing_created_date,
    sum(case when region_id is null then 1 else 0 end) as missing_region_id,
    sum(case when team_id is null then 1 else 0 end) as missing_team_id,
    sum(case when service_id is null then 1 else 0 end) as missing_service_id,
    sum(case when priority_id is null then 1 else 0 end) as missing_priority_id
from fact_tickets;

-- missing_ticket_id	missing_created_date	missing_region_id	missing_team_id	missing_service_id	missing_priority_id
-- 0					0						0					0				0					0


-- =====================================================
-- check 03: ticket date range
-- =====================================================

select min(created_date) as min_created_date, max(created_date) as max_created_date
from fact_tickets;

-- min_created_date	max_created_date
-- 2024-01-01		2025-12-31

-- =====================================================
-- check 04: ticket status distribution
-- =====================================================

select status, count(*) as ticket_count, round(100 * count(*) / (select count(*) from fact_tickets), 2) as prct_of_total
from fact_tickets
group by status
order by ticket_count desc;

/*
status	ticket_count	prct_of_total
Closed	111181			91.46
Open	6446			5.30
Pending	3930			3.23
*/

-- =====================================================
-- check 05: sla compliance distribution
-- =====================================================

select sla_met, count(*) as ticket_count, 
round(count(*)/(select count(*) from fact_tickets where status = 'closed')*100,2) as prct_sla_met
from fact_tickets
where status = 'closed'
group by sla_met;

/*
sla_met	ticket_count	prct_sla_met
1		87762			78.94
0		23419			21.06
*/

-- =====================================================
-- check 06: csat survey response rate
-- =====================================================

select survey_responded, count(*) as respondent_count,
round(count(*)/(select count(*) from fact_csat)*100,2) as prct_response_rate
from fact_csat
group by survey_responded;

/*
survey_responded	respondent_count	prct_response_rate
1					40005				35.98
0					71176				64.02
*/
