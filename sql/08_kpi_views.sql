--------------------------------------------------
-- VIEW 1 : MTTR par équipement
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_mttr AS
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (wo.end_date - wo.start_date)) / 3600
        )::numeric
    ,2) AS mttr_hours
FROM work_order wo
JOIN asset a ON a.asset_id = wo.asset_id
WHERE wo.maintenance_type = 'CORR'
  AND wo.status = 'DONE'
GROUP BY a.asset_id, a.asset_name;

--------------------------------------------------
-- VIEW 2 : MTBF par équipement
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_mtbf AS
WITH failure_dates AS (
    SELECT
        asset_id,
        start_date,
        LAG(start_date) OVER (
            PARTITION BY asset_id
            ORDER BY start_date
        ) AS previous_start
    FROM work_order
    WHERE maintenance_type = 'CORR'
      AND status = 'DONE'
)
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (start_date - previous_start)) / 3600
        )::numeric
    ,2) AS mtbf_hours
FROM failure_dates fd
JOIN asset a ON a.asset_id = fd.asset_id
WHERE previous_start IS NOT NULL
GROUP BY a.asset_id, a.asset_name;

--------------------------------------------------
-- VIEW 3 : Disponibilité par équipement
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_availability AS
WITH downtime AS (
    SELECT
        asset_id,
        SUM(downtime_minutes)/60.0 AS downtime_hours
    FROM downtime_event
    WHERE production_impact = true
    GROUP BY asset_id
)
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(
        (
            1 - COALESCE(d.downtime_hours,0) / 8760
        )::numeric
    ,4) AS availability_ratio
FROM asset a
LEFT JOIN downtime d ON d.asset_id = a.asset_id;

--------------------------------------------------
-- VIEW 4 : Répartition PREV / CORR
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_maintenance_mix AS
SELECT
    maintenance_type,
    COUNT(*) AS nb_work_orders
FROM work_order
GROUP BY maintenance_type;

--------------------------------------------------
-- VIEW 5 : Pareto des pannes par famille
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_failure_pareto AS
SELECT
    fm.family,
    COUNT(*) AS nb_pannes
FROM work_order wo
JOIN failure_mode fm ON fm.failure_mode_id = wo.failure_mode_id
WHERE wo.maintenance_type = 'CORR'
GROUP BY fm.family
ORDER BY nb_pannes DESC;

--------------------------------------------------
-- VIEW 6 : Coûts de maintenance par équipement
--------------------------------------------------
CREATE OR REPLACE VIEW v_kpi_cost_by_asset AS
SELECT
    a.asset_id,
    a.asset_name,
    ROUND(SUM(c.total_cost)::numeric,2) AS total_maintenance_cost
FROM wo_cost c
JOIN work_order wo ON wo.wo_id = c.wo_id
JOIN asset a ON a.asset_id = wo.asset_id
GROUP BY a.asset_id, a.asset_name
ORDER BY total_maintenance_cost DESC;