/*
=========================================================
Project: operations performance & kpi dashboard
file: 02_load_data.sql

Description:
loads synthetic csv data into mysql tables.
=========================================================
*/

use operations_analytics_db;

-- load dimension tables first

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/dim_region.csv'
into table dim_region
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/dim_team.csv'
into table dim_team
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/dim_service.csv'
into table dim_service
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/dim_priority.csv'
into table dim_priority
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/dim_date.csv'
into table dim_date
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- load fact tables

-- handle nullable fields during csv import
-- open tickets do not have a closed date
-- unanswered surveys do not have a csat score

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/fact_tickets.csv'
into table fact_tickets
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(ticket_id, created_date, @closed_date, region_id, team_id, service_id, priority_id,
 ticket_type, complexity, status, @resolution_hours, sla_target_hours, @sla_met,
 escalated, reopened)
set
    closed_date = nullif(@closed_date, ''),
    resolution_hours = nullif(@resolution_hours, ''),
    sla_met = nullif(@sla_met, '');
    
load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/fact_csat.csv'
into table fact_csat
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(ticket_id, survey_sent, survey_responded, @csat_score)
set
    csat_score = nullif(trim(@csat_score), '');
    
load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/fact_capacity.csv'
into table fact_capacity
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/fact_costs.csv'
into table fact_costs
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile 'c:/programdata/mysql/mysql server 8.0/data/uploads/fact_cost_details.csv'
into table fact_cost_details
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
