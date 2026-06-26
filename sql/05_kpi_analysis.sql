-- =====================================================
-- kpi 01: overall sla compliance
-- purpose:
-- measure overall operational performance against
-- sla targets
-- =====================================================

select round(avg(sla_met)*100,2) as prct_sla_compliance
from fact_tickets
where sla_met is not null;

/*
78.94
*/


-- =====================================================
-- kpi 02: average resolution time
-- purpose:
-- measure the average time required to resolve tickets
-- =====================================================

select round(avg(resolution_hours),2) as avg_resolution_hours from fact_tickets
where status = 'closed';

/*
22.13
*/

-- =======================================================
-- kpi 03: escalation rate
-- purpose:
-- measure the percentage of tickets requiring escalation
-- =======================================================

select round(avg(escalated)*100,2) as escalation_rate from fact_tickets;
/*
14.00
*/

-- =====================================================
-- kpi 04: average csat
-- purpose:
-- measure overall customer satisfaction
-- =====================================================

select round(avg(csat_score),2) as avg_csat 
from fact_csat
where survey_responded = 1;

/*
4.25
*/


-- =====================================================
-- kpi 05: monthly SLA trend
-- purpose:
-- monitor sla compliance over time
-- =====================================================

select d.year, d.month, d.month_name, round(avg(t.sla_met)*100,2) as prct_sla_compliance
from fact_tickets t
join dim_date d on t.created_date = d.date
where sla_met is not null
group by d.year, d.month, d.month_name
order by d.year, d.month;

/*
year	month	month_name	prct_sla_compliance
2024	1		January		79.68
2024	2		February	79.72
2024	3		March		80.06
2024	4		April		78.79
2024	5		May			79.09
2024	6		June		79.51
2024	7		July		79.45
2024	8		August		79.22
2024	9		September	79.54
2024	10		October		79.66
2024	11		November	80.40
2024	12		December	80.70
2025	1		January		80.05
2025	2		February	78.93
2025	3		March		79.51
2025	4		April		80.43
2025	5		May			73.93
2025	6		June		74.37
2025	7		July		74.71
2025	8		August		74.43
2025	9		September	80.31
2025	10		October		80.63
2025	11		November	79.83
2025	12		December	79.78
*/

-- =====================================================
-- kpi 06: monthly incident volume trend
-- purpose:
-- monitor workload and demand over time
-- =====================================================

select d.year, d.month, d.month_name, count(*) as ticket_volume
from fact_tickets t
join dim_date d on t.created_date = d.date
group by d.year, d.month, d.month_name
order by d.year, d.month;

/*
year	month	month_name	ticket_volume
2024	1		January		4687
2024	2		February	4265
2024	3		March		4530
2024	4		April		4430
2024	5		May			4588
2024	6		June		3905
2024	7		July		4229
2024	8		August		4508
2024	9		September	4480
2024	10		October		6047
2024	11		November	5731
2024	12		December	6147
2025	1		January		5214
2025	2		February	4643
2025	3		March		5216
2025	4		April		5002
2025	5		May			5167
2025	6		June		4552
2025	7		July		4725
2025	8		August		4985
2025	9		September	4961
2025	10		October		6651
2025	11		November	6356
2025	12		December	6538
*/


-- =====================================================
-- kpi 07: monthly csat trend
-- purpose:
-- monitor customer satisfaction over time
-- =====================================================

select d.year, d.month, d.month_name, round(avg(c.csat_score),2) as avg_csat, count(*) as responses
from fact_tickets t
join fact_csat c on t.ticket_id = c.ticket_id
join dim_date d on t.created_date = d.date
where c.survey_responded = 1
group by d.year, d.month, d.month_name
order by d.year, d.month;


/*
year	month	month_name	avg_csat	responses
2024	1		January		4.25		1588
2024	2		February	4.27		1411
2024	3		March		4.25		1463
2024	4		April		4.24		1452
2024	5		May			4.27		1552
2024	6		June		4.27		1266
2024	7		July		4.25		1446
2024	8		August		4.25		1509
2024	9		September	4.26		1484
2024	10		October		4.25		2005
2024	11		November	4.23		1895
2024	12		December	4.24		1971
2025	1		January		4.24		1684
2025	2		February	4.24		1544
2025	3		March		4.27		1731
2025	4		April		4.24		1692
2025	5		May			4.26		1692
2025	6		June		4.25		1469
2025	7		July		4.23		1570
2025	8		August		4.26		1646
2025	9		September	4.24		1701
2025	10		October		4.25		2165
2025	11		November	4.26		2171
2025	12		December	4.24		1898
*/