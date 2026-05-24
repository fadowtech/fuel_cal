import os
from dotenv import load_dotenv

load_dotenv()
db_url = os.getenv("DATABASE_URL", "sqlite:///./fuel_app.db")

new_columns = [
    ("vehicle_number", "VARCHAR"),
    ("variant", "VARCHAR"),
    ("vehicle_type", "VARCHAR"),
    ("tank_type", "VARCHAR"),
    ("highest_avg_mileage", "DOUBLE PRECISION"),
    ("avg_mileage", "DOUBLE PRECISION"),
    ("poor_mileage", "DOUBLE PRECISION"),
    ("notes", "VARCHAR"),
    ("color", "VARCHAR")
]

def migrate_postgres():
    import psycopg2
    conn = psycopg2.connect(db_url)
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='vehicles';
    """)
    columns = [row[0] for row in cursor.fetchall()]
    
    for col_name, col_type in new_columns:
        if col_name not in columns:
            print(f"Adding column {col_name} to PostgreSQL...")
            cursor.execute(f"ALTER TABLE vehicles ADD COLUMN {col_name} {col_type};")
            
    conn.commit()
    cursor.close()
    conn.close()
    print("PostgreSQL Vehicle Migration completed.")

def migrate_sqlite():
    import sqlite3
    db_path = "fuel_app.db"
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute("PRAGMA table_info(vehicles);")
    columns = [row[1] for row in cursor.fetchall()]
    
    for col_name, col_type in new_columns:
        if col_name not in columns:
            print(f"Adding column {col_name} to SQLite...")
            # SQLite doesn't use DOUBLE PRECISION, fallback to REAL
            sql_type = "REAL" if "DOUBLE" in col_type else "TEXT"
            cursor.execute(f"ALTER TABLE vehicles ADD COLUMN {col_name} {sql_type};")
            
    conn.commit()
    cursor.close()
    conn.close()
    print("SQLite Vehicle Migration completed.")

if __name__ == "__main__":
    if db_url.startswith("postgres"):
        migrate_postgres()
    else:
        migrate_sqlite()
