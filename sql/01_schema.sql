DROP TABLE IF EXISTS wo_cost;
DROP TABLE IF EXISTS downtime_event;
DROP TABLE IF EXISTS work_order;
DROP TABLE IF EXISTS failure_mode;
DROP TABLE IF EXISTS asset;
DROP TABLE IF EXISTS production_line;
CREATE TABLE production_line (
    line_id SERIAL PRIMARY KEY,
    line_name VARCHAR(50) NOT NULL,
    workshop VARCHAR(50),
    description TEXT
);
CREATE TABLE asset (
    asset_id SERIAL PRIMARY KEY,
    line_id INTEGER NOT NULL REFERENCES production_line(line_id),
    asset_name VARCHAR(100) NOT NULL,
    asset_type VARCHAR(50),
    criticality CHAR(1) CHECK (criticality IN ('A','B','C')),
    commissioning_date DATE,
    target_mtbf_hours INTEGER,
    target_mttr_hours NUMERIC(6,2)
);
CREATE TABLE failure_mode (
    failure_mode_id SERIAL PRIMARY KEY,
    family VARCHAR(50),
    label VARCHAR(100),
    description TEXT
);
CREATE TABLE work_order (
    wo_id SERIAL PRIMARY KEY,
    asset_id INTEGER NOT NULL REFERENCES asset(asset_id),
    maintenance_type VARCHAR(10) CHECK (maintenance_type IN ('PREV','CORR','AMEL')),
    planned_flag BOOLEAN,
    request_date TIMESTAMP NOT NULL,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('REQUESTED','PLANNED','IN_PROGRESS','DONE','CANCELLED')),
    failure_mode_id INTEGER REFERENCES failure_mode(failure_mode_id),
    technician_team VARCHAR(50),
    description TEXT
);
CREATE TABLE downtime_event (
    dt_id SERIAL PRIMARY KEY,
    asset_id INTEGER NOT NULL REFERENCES asset(asset_id),
    wo_id INTEGER REFERENCES work_order(wo_id),
    start_dt TIMESTAMP NOT NULL,
    end_dt TIMESTAMP NOT NULL,
    downtime_minutes INTEGER,
    downtime_type VARCHAR(20) CHECK (downtime_type IN ('UNPLANNED','PLANNED','MICROSTOP')),
    production_impact BOOLEAN
);
CREATE TABLE wo_cost (
    wo_cost_id SERIAL PRIMARY KEY,
    wo_id INTEGER NOT NULL REFERENCES work_order(wo_id),
    labor_cost NUMERIC(10,2),
    parts_cost NUMERIC(10,2),
    external_cost NUMERIC(10,2),
    total_cost NUMERIC(10,2)
);
