import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()
db_url = os.getenv("DATABASE_URL")

def migrate():
    conn = psycopg2.connect(db_url)
    cursor = conn.cursor()
    
    # Check if columns exist
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='fuel_logs';
    """)
    columns = [row[0] for row in cursor.fetchall()]
    
    new_columns = [
        ("fuel_price", "DOUBLE PRECISION"),
        ("remaining_range", "DOUBLE PRECISION"),
        ("remaining_range_after", "DOUBLE PRECISION"),
        ("is_full_tank", "BOOLEAN DEFAULT FALSE"),
        ("location", "VARCHAR"),
        ("notes", "VARCHAR"),
        ("payment_method", "VARCHAR"),
        ("bill_image_path", "VARCHAR")
    ]
    
    for col_name, col_type in new_columns:
        if col_name not in columns:
            print(f"Adding column {col_name} to PostgreSQL...")
            cursor.execute(f"ALTER TABLE fuel_logs ADD COLUMN {col_name} {col_type};")
            
    conn.commit()
    cursor.close()
    conn.close()
    print("PostgreSQL Migration completed.")

if __name__ == "__main__":
    migrate()
