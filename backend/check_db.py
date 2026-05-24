from database import engine
from sqlalchemy import text
import pprint

def check():
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT id, title, status, completed_at FROM reminders"))
            rows = result.fetchall()
            print("--- Reminders in Database ---")
            for r in rows:
                print(f"ID: {r[0]}, Title: {r[1]}, Status: {r[2]}, Completed: {r[3]}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check()
