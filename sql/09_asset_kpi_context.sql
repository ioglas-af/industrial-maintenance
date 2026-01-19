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