
import numpy as np
import pandas as pd
from pathlib import Path

np.random.seed(42)

OUTPUT_DIR = Path("output_operations_kpi")
OUTPUT_DIR.mkdir(exist_ok=True)

START_DATE = "2024-01-01"
END_DATE = "2025-12-31"

# -----------------------------
# Dimension tables
# -----------------------------

regions = pd.DataFrame({
    "region_id": [1, 2, 3, 4],
    "region_name": ["Nordics", "Western Europe", "Central Europe", "UK & Ireland"]
})

teams = pd.DataFrame({
    "team_id": [1, 2, 3, 4, 5],
    "team_name": [
        "IT Service Desk",
        "Application Support",
        "Infrastructure Operations",
        "Network Operations",
        "Workplace Support"
    ]
})

services = pd.DataFrame({
    "service_id": [1, 2, 3, 4, 5, 6],
    "service_name": [
        "Account & Access Management",
        "Business Applications",
        "Cloud & Infrastructure",
        "Network & Connectivity",
        "Devices & Workplace Support",
        "Security & Compliance"
    ],
    "criticality": ["Medium", "High", "High", "Critical", "Medium", "Critical"],
    "primary_team_id": [1, 2, 3, 4, 5, 3],
    "secondary_team_id": [2, 1, 4, 3, 1, 2]
})

priorities = pd.DataFrame({
    "priority_id": [1, 2, 3, 4],
    "priority_name": ["Low", "Medium", "High", "Critical"],
    "sla_target_hours": [72, 24, 8, 4]
})

dates = pd.DataFrame({"date": pd.date_range(START_DATE, END_DATE, freq="D")})
dates["year"] = dates["date"].dt.year
dates["quarter"] = "Q" + dates["date"].dt.quarter.astype(str)
dates["month"] = dates["date"].dt.month
dates["month_name"] = dates["date"].dt.month_name()
dates["month_start"] = dates["date"].values.astype("datetime64[M]")
dates["week"] = dates["date"].dt.isocalendar().week.astype(int)
dates["day_of_week"] = dates["date"].dt.day_name()
dates["is_weekend"] = (dates["day_of_week"].isin(["Saturday", "Sunday"]).astype(int))

# -----------------------------
# Business rules
# -----------------------------

region_probs = {
    1: 0.20,   # Nordics
    2: 0.35,   # Western Europe
    3: 0.30,   # Central Europe
    4: 0.15    # UK & Ireland
}

service_probs = {
    1: 0.22,  # Account & Access Management
    2: 0.24,  # Business Applications
    3: 0.16,  # Cloud & Infrastructure
    4: 0.14,  # Network & Connectivity
    5: 0.18,  # Devices & Workplace Support
    6: 0.06   # Security & Compliance
}

ticket_type_probs = {
    "Incident": 0.45,
    "Service Request": 0.30,
    "Access Request": 0.15,
    "Change Support": 0.10
}

complexity_probs = {
    "Simple": 0.50,
    "Medium": 0.35,
    "Complex": 0.15
}

base_priority_probs = {
    "Low": 0.25,
    "Medium": 0.45,
    "High": 0.22,
    "Critical": 0.08
}

priority_id_map = dict(zip(priorities["priority_name"], priorities["priority_id"]))
sla_map = dict(zip(priorities["priority_id"], priorities["sla_target_hours"]))

def weighted_choice(prob_dict):
    keys = list(prob_dict.keys())
    probs = list(prob_dict.values())
    return np.random.choice(keys, p=probs)

def choose_priority(service_id):
    # Security and network-related services receive more high-priority tickets
    if service_id == 6:  # Security & Compliance
        probs = {"Low": 0.10, "Medium": 0.30, "High": 0.35, "Critical": 0.25}
    elif service_id == 4:  # Network & Connectivity
        probs = {"Low": 0.15, "Medium": 0.35, "High": 0.35, "Critical": 0.15}
    elif service_id == 5:  # Devices & Workplace
        probs = {"Low": 0.35, "Medium": 0.45, "High": 0.17, "Critical": 0.03}
    else:
        probs = base_priority_probs
    return priority_id_map[weighted_choice(probs)]

def choose_complexity(service_id):
    if service_id == 2:  # Business Applications
        probs = {"Simple": 0.35, "Medium": 0.40, "Complex": 0.25}
    elif service_id == 5:  # Devices & Workplace
        probs = {"Simple": 0.65, "Medium": 0.25, "Complex": 0.10}
    elif service_id == 6:  # Security
        probs = {"Simple": 0.30, "Medium": 0.45, "Complex": 0.25}
    else:
        probs = complexity_probs
    return weighted_choice(probs)

def choose_team(service_id):
    service = services.loc[services["service_id"] == service_id].iloc[0]
    primary = service["primary_team_id"]
    secondary = service["secondary_team_id"]

    rand = np.random.random()
    if rand < 0.80:
        return primary
    elif rand < 0.95:
        return secondary
    else:
        other_teams = [t for t in teams["team_id"] if t not in [primary, secondary]]
        return np.random.choice(other_teams)

def daily_ticket_volume(date):
    base = 180

    # Weekends are quieter
    if date.weekday() >= 5:
        base *= 0.45

    # Q4 seasonal peak
    if date.month in [10, 11, 12]:
        base *= 1.25

    # Summer is slightly quieter
    if date.month in [6, 7]:
        base *= 0.90

    # Gradual operational growth in 2025
    if date.year == 2025:
        base *= 1.10

    return max(20, int(np.random.normal(base, base * 0.12)))

def resolution_hours(priority_id, complexity, service_id, team_id, created_date):
    target = sla_map[priority_id]

    priority_base = {
        1: 48,
        2: 18,
        3: 6.5,
        4: 3.2
    }[priority_id]

    complexity_factor = {
        "Simple": 0.75,
        "Medium": 1.00,
        "Complex": 1.55
    }[complexity]

    service_factor = 1.0
    if service_id in [4, 6]:
        service_factor = 1.20

    overload_factor = 1.0
    if team_id == 4 and pd.Timestamp("2025-05-01") <= created_date <= pd.Timestamp("2025-08-31"):
        overload_factor = 1.45

    regional_noise = np.random.lognormal(mean=0, sigma=0.25)

    hours = priority_base * complexity_factor * service_factor * overload_factor * regional_noise

    # keep values realistic
    return round(max(0.5, hours), 2)

def choose_status(created_date):
    # Older tickets are usually closed; recent tickets have more open/pending items.
    if created_date >= pd.Timestamp("2025-12-15"):
        probs = {"Closed": 0.72, "Open": 0.18, "Pending": 0.10}
    else:
        probs = {"Closed": 0.92, "Open": 0.05, "Pending": 0.03}
    return weighted_choice(probs)

def escalation_flag(priority_id, complexity, service_id, team_id, created_date):
    base = {1: 0.02, 2: 0.08, 3: 0.18, 4: 0.35}[priority_id]
    if complexity == "Complex":
        base += 0.10
    if service_id == 4:
        base += 0.06
    if team_id == 4 and pd.Timestamp("2025-05-01") <= created_date <= pd.Timestamp("2025-08-31"):
        base += 0.08
    return np.random.random() < min(base, 0.65)

def reopened_flag(priority_id, complexity):
    base = {1: 0.01, 2: 0.04, 3: 0.07, 4: 0.10}[priority_id]
    if complexity == "Complex":
        base += 0.05
    return np.random.random() < min(base, 0.25)

# -----------------------------
# Generate fact_tickets
# -----------------------------

ticket_rows = []
ticket_id = 1

for date in dates["date"]:
    n_tickets = daily_ticket_volume(date)

    for _ in range(n_tickets):
        region_id = weighted_choice(region_probs)
        service_id = weighted_choice(service_probs)
        team_id = choose_team(service_id)
        priority_id = choose_priority(service_id)
        complexity = choose_complexity(service_id)
        ticket_type = weighted_choice(ticket_type_probs)
        status = choose_status(date)

        res_hours = resolution_hours(priority_id, complexity, service_id, team_id, date)
        sla_target = sla_map[priority_id]
        sla_met = res_hours <= sla_target

        if status == "Closed":
            closed_date = date + pd.to_timedelta(res_hours, unit="h")
        else:
            closed_date = pd.NaT

        ticket_rows.append({
            "ticket_id": ticket_id,
            "created_date": date.date(),
            "closed_date": closed_date.date() if pd.notna(closed_date) else None,
            "region_id": region_id,
            "team_id": team_id,
            "service_id": service_id,
            "priority_id": priority_id,
            "ticket_type": ticket_type,
            "complexity": complexity,
            "status": status,
            "resolution_hours": res_hours if status == "Closed" else None,
            "sla_target_hours": sla_target,
            "sla_met": int(sla_met) if status == "Closed" else None,
            "escalated": int(escalation_flag(priority_id, complexity, service_id, team_id, date)),
            "reopened": int(reopened_flag(priority_id, complexity))
        })
        ticket_id += 1

fact_tickets = pd.DataFrame(ticket_rows)

# -----------------------------
# Generate fact_csat
# -----------------------------

csat_rows = []

for _, row in fact_tickets[fact_tickets["status"] == "Closed"].iterrows():
    survey_sent = np.random.random() < 0.55
    survey_responded = survey_sent and (np.random.random() < 0.65)

    if survey_responded:
        score = 4.4

        if row["sla_met"] is False:
            score -= 0.9
        if row["escalated"]:
            score -= 0.4
        if row["reopened"]:
            score -= 0.3
        if row["region_id"] == 3:  # Central Europe
            score -= 0.25
        if row["region_id"] == 1:  # Nordics
            score += 0.15
        if row["complexity"] == "Complex":
            score -= 0.15

        score = np.random.normal(score, 0.45)
        score = int(np.clip(round(score), 1, 5))
    else:
        score = None

    csat_rows.append({
        "ticket_id": row["ticket_id"],
        "survey_sent": int(survey_sent),
        "survey_responded": int(survey_responded),
        "csat_score": score
    })

fact_csat = pd.DataFrame(csat_rows)

# -----------------------------
# Generate fact_capacity
# -----------------------------

month_starts = pd.date_range(START_DATE, END_DATE, freq="MS")

base_fte = {
    1: 38,  # IT Service Desk
    2: 28,  # Application Support
    3: 24,  # Infrastructure Operations
    4: 20,  # Network Operations
    5: 18   # Workplace Support
}

capacity_rows = []

for month in month_starts:
    for _, team in teams.iterrows():
        for _, region in regions.iterrows():
            team_id = team["team_id"]
            region_id = region["region_id"]

            region_factor = {1: 0.75, 2: 1.15, 3: 1.05, 4: 0.70}[region_id]
            fte = max(3, round(base_fte[team_id] * region_factor * np.random.normal(1, 0.04), 1))
            available_hours = round(fte * 160, 1)

            utilization = np.random.normal(0.86, 0.08)

            # Network Operations overload period
            if team_id == 4 and pd.Timestamp("2025-05-01") <= month <= pd.Timestamp("2025-08-01"):
                utilization = np.random.normal(1.17, 0.06)

            # Central Europe pressure
            if region_id == 3:
                utilization += 0.04

            worked_hours = round(available_hours * max(0.55, utilization), 1)
            overtime_hours = round(max(0, worked_hours - available_hours), 1)

            capacity_rows.append({
                "month_start": month.date(),
                "team_id": team_id,
                "region_id": region_id,
                "fte": fte,
                "available_hours": available_hours,
                "worked_hours": worked_hours,
                "overtime_hours": overtime_hours
            })

fact_capacity = pd.DataFrame(capacity_rows)

# -----------------------------
# Generate fact_costs
# -----------------------------

cost_rows = []

cost_per_fte_month = {
    1: 6200,
    2: 7200,
    3: 7600,
    4: 7800,
    5: 6000
}

for _, cap in fact_capacity.iterrows():
    month = pd.Timestamp(cap["month_start"])
    team_id = cap["team_id"]
    region_id = cap["region_id"]

    base_budget = cap["fte"] * cost_per_fte_month[team_id]
    budget = round(base_budget * np.random.normal(1, 0.03), 2)

    actual_multiplier = np.random.normal(1.01, 0.05)

    if cap["overtime_hours"] > 0:
        actual_multiplier += 0.05

    if team_id == 4 and pd.Timestamp("2025-05-01") <= month <= pd.Timestamp("2025-08-01"):
        actual_multiplier += 0.12

    if month.year == 2025 and month.month in [10, 11, 12]:
        actual_multiplier += 0.05

    actual_cost = round(budget * actual_multiplier, 2)

    cost_rows.append({
        "month_start": cap["month_start"],
        "team_id": team_id,
        "region_id": region_id,
        "budget": budget,
        "actual_cost": actual_cost
    })

fact_costs = pd.DataFrame(cost_rows)


# -----------------------------
# Generate fact_cost_details
# -----------------------------
# Detailed monthly cost breakdown by category.
# Used for the second portfolio project:
# Operational Cost & Resource Utilization Analysis.

cost_category_shares = {
    "salary": 0.70,
    "contractors": 0.15,
    "software": 0.08,
    "training": 0.04,
    "travel": 0.03
}

cost_detail_rows = []

for _, row in fact_costs.iterrows():
    month = pd.Timestamp(row["month_start"])
    team_id = row["team_id"]
    region_id = row["region_id"]

    for category, share in cost_category_shares.items():
        category_budget = row["budget"] * share
        category_budget *= np.random.normal(1, 0.03)

        category_actual = category_budget * np.random.normal(1.01, 0.05)

        # Contractor costs increase during Network Operations overload.
        if (
            category == "contractors"
            and team_id == 4
            and pd.Timestamp("2025-05-01") <= month <= pd.Timestamp("2025-08-01")
        ):
            category_actual *= np.random.normal(1.25, 0.05)

        # Software costs increase slightly during Q4.
        if category == "software" and month.month in [10, 11, 12]:
            category_actual *= np.random.normal(1.08, 0.03)

        cost_detail_rows.append({
            "month_start": row["month_start"],
            "team_id": team_id,
            "region_id": region_id,
            "cost_category": category,
            "budget_amount": round(category_budget, 2),
            "actual_amount": round(category_actual, 2)
        })

fact_cost_details = pd.DataFrame(cost_detail_rows)

# -----------------------------
# Export CSV
# -----------------------------

dates.to_csv(OUTPUT_DIR / "dim_date.csv", index=False)
regions.to_csv(OUTPUT_DIR / "dim_region.csv", index=False)
teams.to_csv(OUTPUT_DIR / "dim_team.csv", index=False)
services.to_csv(OUTPUT_DIR / "dim_service.csv", index=False)
priorities.to_csv(OUTPUT_DIR / "dim_priority.csv", index=False)

fact_tickets.to_csv(OUTPUT_DIR / "fact_tickets.csv", index=False)
fact_csat.to_csv(OUTPUT_DIR / "fact_csat.csv", index=False)
fact_capacity.to_csv(OUTPUT_DIR / "fact_capacity.csv", index=False)
fact_costs.to_csv(OUTPUT_DIR / "fact_costs.csv", index=False)
fact_cost_details.to_csv(OUTPUT_DIR / "fact_cost_details.csv", index=False)

print("Dataset generated successfully.")
print(f"Tickets: {len(fact_tickets):,}")
print(f"CSAT rows: {len(fact_csat):,}")
print(f"Capacity rows: {len(fact_capacity):,}")
print(f"Cost rows: {len(fact_costs):,}")
print(f"Cost detail rows: {len(fact_cost_details):,}")
print(f"Files saved to: {OUTPUT_DIR.resolve()}")
