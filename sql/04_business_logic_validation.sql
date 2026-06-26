/*
=========================================================
Project: operations performance & kpi dashboard
file: 04_business_logic_validation.sql

Description:
Check business logic
=========================================================
*/

-- =====================================================
-- check 01: relationship between sla and csat
-- purpose:
-- validate whether sla breaches negatively impact
-- customer satisfaction.
-- =====================================================

select t.sla_met, round(avg(c.csat_score),2) as avg_csat, count(*) as responses
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
where c.survey_responded =1
group by t.sla_met;

/*
sla_met	avg_csat	responses
1		4.28		31576
0		4.14		8429
*/

-- =====================================================
-- check 02: relationship between team and sla compliance
-- purpose:
-- identify differences in operational performance
-- across support teams.
-- =====================================================

select tm.team_name, round(avg(t.sla_met)*100,2) as prc_sla_complience, count(*) as closed_tickets
from dim_team tm
join fact_tickets t on tm.team_id = t.team_id
where t.sla_met is not null
group by tm.team_name
order by prc_sla_complience desc;

/*
team_name					prc_sla_complience	closed_tickets
Workplace Support			88.71				17686
IT Service Desk				82.99				27034
Application Support			77.57				26808
Infrastructure Operations	76.56				23079
Network Operations			67.41				16574
*/

-- =====================================================
-- check 03: relationship between csat by team
-- purpose:
-- compare customer satisfaction across teams.
-- =====================================================

select tm.team_name, count(*) as requests, round(avg(c.csat_score),2) as avg_csat
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
join dim_team tm on t.team_id = tm.team_id
where c.survey_responded = 1
group by tm.team_name
order by avg_csat desc;

/*
team_name					requests	avg_csat
Workplace Support			6333		4.28
IT Service Desk				9729		4.26
Infrastructure Operations	8248		4.24
Application Support			9744		4.24
Network Operations			5951		4.23
*/


-- =====================================================
-- check 04: relationship between escalation and csat
-- purpose:
-- evaluate the impact of ticket escalation
-- on customer satisfaction.
-- =====================================================

select t.escalated, round(avg(c.csat_score),2) as avg_csat, count(*) as responses  
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
where c.survey_responded = 1
group by t.escalated;

/*
escalatedavg_csatresponses
0	4.31	34400
1	3.89	5605
*/


-- =====================================================
-- check 05: relationship between complexity and csat
-- purpose:
-- evaluate whether ticket complexity affects
-- customer satisfaction.
-- =====================================================

select t.complexity, round(avg(c.csat_score),2) as avg_csat, count(*) as responses
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
where c.survey_responded = 1
group by t.complexity
order by avg_csat desc;

/*
complexity	avg_csat	responses
Simple		4.29		19099
Medium		4.28		14054
Complex		4.08		6852
*/

-- =====================================================
-- check 06: relationship between reopened and csat
-- purpose:
-- evaluate whether reopened tickets are associated
-- with lower customer satisfaction.
-- =====================================================

select t.reopened, round(avg(c.csat_score),2) as avg_csat, count(*) as responses
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
where c.survey_responded = 1
group by reopened
order by avg_csat desc;

/*
reopened	avg_csat	responses
0			4.27		37754
1			3.94		2251
*/

-- ========================================================
-- check 07: relationship between resolution_hours and csat
-- purpose:
-- evaluate whether longer resolution times are associated
-- with lower customer satisfaction.
--
-- note:
-- the generated dataset shows only a weak relationship
-- between resolution time and csat.
-- ========================================================

select min(resolution_hours), max(resolution_hours), avg(resolution_hours) from fact_tickets where resolution_hours is not null;
-- 0.93	207.86 22.129974


select 
case 
   when resolution_hours <= 8 then '0-8h'
   when resolution_hours <= 24 then '8-24h'
   when resolution_hours <= 48 then '24-48h'
   when resolution_hours <= 72 then '48-72h'
   else '72+h'
end as resolution_bucket,
round(avg(c.csat_score),2) as avg_csat, count(*) as responses
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
where c.survey_responded = 1
and t.status = 'closed'
group by resolution_bucket
-- order by resolution_bucket;
order by 
case
	when resolution_bucket = '0-8h' then 1
	when resolution_bucket = '8-24h' then 2
	when resolution_bucket = '24-48h' then 3
	when resolution_bucket = '48-72h' then 4
	else 5
end;

/*
resolution_bucket	avg_csat		responses   
0-8h				4.21			10487
8-24h				4.26			16510
24-48h				4.28			8824
48-72h				4.27			2951
72+h				4.14			1233    
*/
