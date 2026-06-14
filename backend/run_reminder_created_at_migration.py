import sqlite3

def run_migration():
    conn = sqlite3.connect('fuel_app.db')
    cursor = conn.cursor()

    try:
        cursor.execute("ALTER TABLE reminders ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
        conn.commit()
        print("Successfully added created_at to reminders table.")
    except sqlite3.OperationalError as e:
        if "duplicate column name" in str(e).lower():
            print("Column created_at already exists.")
        else:
            print(f"OperationalError: {e}")
            conn.rollback()
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()
