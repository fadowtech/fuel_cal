import sqlite3

def run_migration():
    # Connect to the SQLite database
    conn = sqlite3.connect('fuel_app.db')
    cursor = conn.cursor()

    try:
        # Create reminders table if it doesn't exist
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            category VARCHAR,
            title VARCHAR,
            due_date DATETIME,
            due_km FLOAT,
            notes VARCHAR,
            repeat BOOLEAN DEFAULT 0,
            notify_before_days VARCHAR,
            priority VARCHAR DEFAULT 'High',
            FOREIGN KEY(user_id) REFERENCES users(id)
        )
        ''')
        
        print("Successfully created reminders table if it didn't exist.")
        
        # Create index on user_id for faster lookups
        cursor.execute('CREATE INDEX IF NOT EXISTS ix_reminders_user_id ON reminders (user_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS ix_reminders_id ON reminders (id)')
        
        conn.commit()
        print("Migration completed successfully.")
        
    except sqlite3.Error as e:
        print(f"An error occurred: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    run_migration()
