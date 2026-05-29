import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "fuel_app.db")

def migrate():
    print(f"Connecting to {DB_PATH}")
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    try:
        cursor.execute("ALTER TABLE reminders ADD COLUMN amount FLOAT;")
        conn.commit()
        print("Successfully added 'amount' column to 'reminders' table.")
    except sqlite3.OperationalError as e:
        if "duplicate column name" in str(e):
            print("Column 'amount' already exists.")
        else:
            print(f"Error: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
