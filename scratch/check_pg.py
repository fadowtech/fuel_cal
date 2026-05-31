import psycopg2

try:
    conn = psycopg2.connect('postgresql://fuel_user:Fuel%402026Secure@184.174.37.4:5432/fuel_db')
    cur = conn.cursor()
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='reminders';")
    cols = [r[0] for r in cur.fetchall()]
    print('Reminders columns:', cols)
    conn.close()
except Exception as e:
    print('Error:', e)
