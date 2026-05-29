import sqlite3
import os

# Connect to the database
db_path = "fuel_app.db"
print(f"Connecting to database: {db_path}")

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Check if services table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='services'")
    if not cursor.fetchone():
        print("Creating 'services' table...")
        cursor.execute("""
            CREATE TABLE services (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                vehicle_id INTEGER,
                category VARCHAR,
                title VARCHAR,
                amount FLOAT,
                date DATETIME,
                notes VARCHAR,
                FOREIGN KEY(user_id) REFERENCES users(id),
                FOREIGN KEY(vehicle_id) REFERENCES vehicles(id)
            )
        """)
        print("Table 'services' created successfully.")
    else:
        print("Table 'services' already exists.")

    conn.commit()

    # Optional: Migrate existing services from expenses to services
    print("Do you want to migrate existing service expenses to the new services table? (y/n)")
    # We will just do it for any category that is 'Service', 'Engine', 'Brakes', 'Suspension', 'General', 'Tires'
    
    # We'll just do it automatically for this script
    cursor.execute("SELECT id, user_id, vehicle_id, category, title, amount, date, notes FROM expenses WHERE category IN ('Service', 'Engine', 'Brakes', 'Suspension', 'General', 'Tires', 'service', 'engine', 'brakes', 'suspension', 'general', 'tires')")
    service_expenses = cursor.fetchall()
    
    if service_expenses:
        print(f"Found {len(service_expenses)} service records in expenses table. Migrating...")
        for row in service_expenses:
            expense_id, user_id, vehicle_id, category, title, amount, date, notes = row
            cursor.execute("""
                INSERT INTO services (user_id, vehicle_id, category, title, amount, date, notes)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (user_id, vehicle_id, category, title, amount, date, notes))
            
            # Delete from expenses
            cursor.execute("DELETE FROM expenses WHERE id=?", (expense_id,))
        conn.commit()
        print("Migration complete!")
    else:
        print("No service records found in expenses table to migrate.")

except Exception as e:
    print(f"An error occurred: {e}")
finally:
    if 'conn' in locals():
        conn.close()
        print("Database connection closed.")
