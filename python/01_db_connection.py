import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="maintenance_db",
    user="ioglas",
    password="ioglas_pwd"
)

cur = conn.cursor()
cur.execute("SELECT COUNT(*) FROM work_order;")
print("Total de work orders:", cur.fetchone()[0])

cur.close()
conn.close()
