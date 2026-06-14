import psycopg2
from dotenv import load_dotenv
import os

# Use getenv so it works inside docker
db_url = os.getenv("DATABASE_URL")

def migrate():
    try:
        conn = psycopg2.connect(db_url)
        cursor = conn.cursor()
        
        # Check if column exists
        cursor.execute("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='reminders';
        """)
        columns = [row[0] for row in cursor.fetchall()]
        
        if "vehicle_id" not in columns:
            print("Adding vehicle_id column to PostgreSQL reminders table...")
            cursor.execute("ALTER TABLE reminders ADD COLUMN vehicle_id INTEGER REFERENCES vehicles(id);")
            conn.commit()
            print("Added vehicle_id successfully.")
        else:
            print("vehicle_id already exists.")
            
        cursor.close()
        conn.close()
        print("PostgreSQL Migration completed.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    migrate()
