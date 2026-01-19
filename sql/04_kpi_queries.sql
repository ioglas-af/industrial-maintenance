--------------------------------------------------
-- KPI 1 : Availability per asset
--------------------------------------------------
CREATE OR REPLACE VIEW v_asset_availability AS
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        1
        - SUM(COALESCE(d.downtime_minutes, 0))::numeric
          / (365 * 24 * 60),
        4
    ) AS availability_ratio
FROM asset a
LEFT JOIN downtime_event d
    ON a.asset_id = d.asset_id
GROUP BY a.asset_id, a.asset_name;


--------------------------------------------------
-- KPI 2 : MTTR per asset (corrective only)
--------------------------------------------------
CREATE OR REPLACE VIEW v_asset_mttr AS
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (w.end_date - w.start_date)) / 3600),
        2
    ) AS mttr_hours
FROM asset a
JOIN work_order w
    ON a.asset_id = w.asset_id
WHERE w.maintenance_type = 'CORR'
  AND w.start_date IS NOT NULL
  AND w.end_date IS NOT NULL
GROUP BY a.asset_id, a.asset_name;


--------------------------------------------------
-- KPI 3 : MTBF per asset
--------------------------------------------------
CREATE OR REPLACE VIEW v_asset_mtbf AS
WITH failures AS (
    SELECT
        asset_id,
        start_date,
        LAG(start_date) OVER (
            PARTITION BY asset_id
            ORDER BY start_date
        ) AS prev_failure
    FROM work_order
    WHERE maintenance_type = 'CORR'
)
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (start_date - prev_failure)) / 3600),
        2
    ) AS mtbf_hours
FROM failures f
JOIN asset a
    ON a.asset_id = f.asset_id
WHERE prev_failure IS NOT NULL
GROUP BY a.asset_id, a.asset_name;


--------------------------------------------------
-- KPI 4 : Maintenance mix
--------------------------------------------------
CREATE OR REPLACE VIEW v_maintenance_mix AS
SELECT
    maintenance_type,
    COUNT(*) AS nb_work_orders
FROM work_order
GROUP BY maintenance_type;


--------------------------------------------------
-- KPI 5 : Pareto des pannes
--------------------------------------------------
CREATE OR REPLACE VIEW v_failure_pareto AS
SELECT
    fm.family,
    COUNT(*) AS nb_pannes
FROM work_order w
JOIN failure_mode fm
    ON w.failure_mode_id = fm.failure_mode_id
WHERE w.maintenance_type = 'CORR'
GROUP BY fm.family;


--------------------------------------------------
-- KPI 6 : Maintenance cost per asset
--------------------------------------------------
CREATE OR REPLACE VIEW v_asset_cost AS
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(SUM(c.total_cost), 2) AS total_maintenance_cost
FROM asset a
JOIN work_order w
    ON a.asset_id = w.asset_id
JOIN wo_cost c
    ON w.wo_id = c.wo_id
GROUP BY a.asset_id, a.asset_name;



--------------------------------------------------
-- KPI CONTEXT VIEW (for Python / BI analysis)
--------------------------------------------------
CREATE OR REPLACE VIEW v_asset_kpi_context AS
SELECT
    a.asset_id,
    a.asset_name,
    a.criticality,
    av.availability_ratio,
    mttr.mttr_hours,
    mtbf.mtbf_hours,
    cost.total_maintenance_cost
FROM asset a
LEFT JOIN v_asset_availability av
    ON a.asset_id = av.asset_id
LEFT JOIN v_asset_mttr mttr
    ON a.asset_id = mttr.asset_id
LEFT JOIN v_asset_mtbf mtbf
    ON a.asset_id = mtbf.asset_id
LEFT JOIN v_asset_cost cost
    ON a.asset_id = cost.asset_id;