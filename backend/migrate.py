import sqlite3
import os

db_path = "fuel_app.db"

if not os.path.exists(db_path):
    print(f"Error: {db_path} not found.")
    exit(1)

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute('ALTER TABLE expenses ADD COLUMN notes TEXT')
    conn.commit()
    print("Success! The 'notes' column has been added to the expenses table.")
except sqlite3.OperationalError as e:
    if "duplicate column name" in str(e).lower():
        print("The 'notes' column already exists! You are good to go.")
    else:
        print(f"An error occurred: {e}")
finally:
    conn.close()
