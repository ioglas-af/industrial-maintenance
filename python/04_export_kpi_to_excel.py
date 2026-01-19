import psycopg2
import pandas as pd
from pathlib import Path


def get_connection():
    return psycopg2.connect(
        host="localhost",
        database="maintenance_db",
        user="maint_user",
        password="maint_pwd"
    )


def load_view(conn, name):
    return pd.read_sql_query(f"SELECT * FROM {name};", conn)


def main():
    output_path = Path("/home/ioglas/maintenance_project/python/output/maintenance_kpi_full_export.xlsx")
    output_path.parent.mkdir(parents=True, exist_ok=True)

    conn = get_connection()

    try:
        df_asset_kpi = load_view(conn, "v_asset_kpi_context")
        df_availability = load_view(conn, "v_asset_availability")
        df_mttr = load_view(conn, "v_asset_mttr")
        df_mtbf = load_view(conn, "v_asset_mtbf")
        df_cost = load_view(conn, "v_asset_cost")
        df_mix = load_view(conn, "v_maintenance_mix")
        df_pareto = load_view(conn, "v_failure_pareto")

        df_corrective = pd.read_sql_query("""
            SELECT
                a.asset_id,
                a.asset_name,
                a.criticality,
                COUNT(w.wo_id) AS nb_corrective
            FROM asset a
            JOIN work_order w ON a.asset_id = w.asset_id
            WHERE w.maintenance_type = 'CORR'
            GROUP BY a.asset_id, a.asset_name, a.criticality;
        """, conn)

    finally:
        conn.close()

    numeric_cols = ["mttr_hours", "mtbf_hours", "total_maintenance_cost"]
    for col in numeric_cols:
        if col in df_asset_kpi.columns:
            df_asset_kpi[col] = df_asset_kpi[col].fillna(0)

    with pd.ExcelWriter(output_path) as writer:
        df_asset_kpi.to_excel(writer, sheet_name="asset_kpi", index=False)
        df_availability.to_excel(writer, sheet_name="asset_availability", index=False)
        df_mttr.to_excel(writer, sheet_name="asset_mttr", index=False)
        df_mtbf.to_excel(writer, sheet_name="asset_mtbf", index=False)
        df_cost.to_excel(writer, sheet_name="asset_cost", index=False)
        df_mix.to_excel(writer, sheet_name="maintenance_mix", index=False)
        df_pareto.to_excel(writer, sheet_name="failure_pareto", index=False)
        df_corrective.to_excel(writer, sheet_name="corrective_count", index=False)

    print(f"Full KPI export completed: {output_path}")


if __name__ == "__main__":
    main()