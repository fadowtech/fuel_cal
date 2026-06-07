import sqlite3

def run_migration():
    conn = sqlite3.connect("fuel_app.db")
    cursor = conn.cursor()
    try:
        cursor.execute("ALTER TABLE fuel_logs ADD COLUMN remaining_range_after FLOAT")
        conn.commit()
        print("Successfully added remaining_range_after to fuel_logs")
    except sqlite3.OperationalError as e:
        print(f"Migration failed or already applied: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()
