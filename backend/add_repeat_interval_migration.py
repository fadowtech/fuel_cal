import sqlite3
import os

def migrate():
    # SQLite database path
    db_path = "/app/fuel_cal.db" if os.path.exists("/app/fuel_cal.db") else "fuel_cal.db"
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Check if column exists
        cursor.execute("PRAGMA table_info(reminders)")
        columns = [info[1] for info in cursor.fetchall()]
        
        if 'repeat_interval' not in columns:
            print("Adding repeat_interval column to reminders table...")
            cursor.execute("ALTER TABLE reminders ADD COLUMN repeat_interval VARCHAR")
            conn.commit()
            print("Migration successful.")
        else:
            print("Column repeat_interval already exists.")
            
    except Exception as e:
        print(f"Error during migration: {e}")
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
