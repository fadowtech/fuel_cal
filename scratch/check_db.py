import sys
try:
    from sqlalchemy import create_engine, text
    engine = create_engine('postgresql://fuel_user:Fuel%402026Secure@184.174.37.4:5432/fuel_db')
    with engine.connect() as conn:
        res = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='reminders';"))
        cols = [r[0] for r in res]
        print('Reminders columns:', cols)
except Exception as e:
    print(e)
