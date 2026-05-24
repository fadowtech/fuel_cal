import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), "fuel_app.db")

def migrate():
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check if columns exist, if not add them
    cursor.execute("PRAGMA table_info(fuel_logs);")
    columns = [col[1] for col in cursor.fetchall()]
    
    new_columns = [
        ("fuel_price", "FLOAT"),
        ("remaining_range", "FLOAT"),
        ("is_full_tank", "BOOLEAN DEFAULT 0"),
        ("location", "VARCHAR"),
        ("notes", "VARCHAR"),
        ("payment_method", "VARCHAR"),
        ("bill_image_path", "VARCHAR")
    ]
    
    for col_name, col_type in new_columns:
        if col_name not in columns:
            print(f"Adding column {col_name}...")
            cursor.execute(f"ALTER TABLE fuel_logs ADD COLUMN {col_name} {col_type};")
            
    conn.commit()
    conn.close()
    print("Migration completed.")

if __name__ == "__main__":
    migrate()
