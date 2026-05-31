import psycopg2

try:
    conn = psycopg2.connect('postgresql://fuel_user:Fuel%402026Secure@184.174.37.4:5432/fuel_db')
    cur = conn.cursor()
    cur.execute("ALTER TABLE reminders ADD COLUMN amount DOUBLE PRECISION;")
    conn.commit()
    print('Added amount column')
    conn.close()
except Exception as e:
    print('Error:', e)
