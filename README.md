# Mini-CMMS / Industrial Maintenance Analytics (Synthetic Brewery Dataset)

## Overview
This project implements a **data-driven mini-CMMS (GMAO)** based on a realistic industrial brewery environment.  
It covers the full maintenance data pipeline, from database design to decision-oriented dashboards.

The project is **fully reproducible** and based on **synthetic maintenance data**, designed to simulate real industrial behavior.

---

## Industrial Context — Brewery (Brasserie)
The simulated site represents a typical industrial brewery, including:

- Brewing (vessels, pumps, heat exchangers)
- Fermentation (tanks, sensors, agitators)
- Packaging (fillers, conveyors, labellers)
- Utilities (industrial cooling, compressed air, process water)
- Electrical & Automation systems

This context enables realistic modeling of process equipment, utilities, and mechanical, electrical, and instrumentation failures.

---

## Project Objectives
The goal of this project is to demonstrate how to:

- design an industrial maintenance database,
- generate realistic synthetic failure and downtime events,
- compute classical reliability KPIs (MTBF, MTTR, Availability),
- build a clean SQL → Python → BI data pipeline,
- support maintenance decision-making through dashboards.

The focus is on **maintenance data engineering**, not only visualization.

---

## Technology Stack
- PostgreSQL (relational database)
- SQL (schema, seeding, KPI views)
- Python (psycopg2, pandas)
- Power BI (dashboard & analysis)
- GitHub (versioning & reproducibility)

---

## Database Model
The database schema reflects a real CMMS used in an industrial brewery:

- `production_line` – production zones
- `asset` – equipment with criticality (A/B/C)
- `failure_mode` – failure families
- `work_order` – preventive and corrective maintenance
- `downtime_event` – stops, micro-stops, production impact
- `wo_cost` – labor, spare parts, subcontracting costs

Foreign keys enforce realistic maintenance workflows.

---

## Synthetic Data Generation
Custom SQL scripts generate a large and realistic dataset, including:

- critical and secondary assets,
- **bad actors** with frequent corrective failures,
- planned preventive maintenance,
- unplanned downtime and micro-stops,
- realistic maintenance cost distributions.

This ensures meaningful MTBF, MTTR and availability indicators for most assets.

---

## KPI Computation (SQL Views)
All KPIs are computed directly in PostgreSQL using SQL views:

- Availability per asset
- MTTR (corrective maintenance only)
- MTBF
- Preventive vs corrective maintenance mix
- Failure Pareto by family
- Total maintenance cost per asset

A consolidated view (`v_asset_kpi_context`) centralizes all KPIs for BI and Python consumption.

---

## Python Integration Layer
Python is used strictly as an integration layer:

- connection to PostgreSQL,
- extraction of KPI views,
- export to a single Excel file for BI.

No KPI logic is duplicated outside the database.

---

## Power BI Dashboard

### Maintenance Overview — Key KPIs
![Maintenance Overview](figures/maintenance_overview.png)

This page provides a global view of maintenance performance, including availability, MTBF, MTTR, maintenance mix and cost distribution.

---

### Critical Assets — Reliability & Performance
![Critical Assets](figures/critical_assets.png)

Focused analysis of critical (A-class) assets, highlighting corrective maintenance frequency, cost impact, and reliability vs maintainability trade-offs.

---

### Failure Analysis & Pareto
![Failure Analysis](figures/failure_analysis.png)

Pareto analysis of failure modes to identify dominant causes and support prioritization actions following the 80/20 principle.

---

## Project Value
This project demonstrates capabilities in:

- industrial maintenance engineering,
- reliability analysis,
- industrial data modeling,
- advanced SQL,
- Python and BI integration,
- decision-oriented dashboard design.

It is easily extensible to predictive maintenance, time-series analysis, OEE calculation, or integration with real industrial data.

---
