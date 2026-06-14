import psycopg2
from dotenv import load_dotenv
import os

db_url = os.getenv("DATABASE_URL", "postgresql://fuel_user:Fuel%402026Secure@localhost:5432/fuel_db")

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
        
        if "created_at" not in columns:
            print("Adding created_at column to PostgreSQL reminders table...")
            cursor.execute("ALTER TABLE reminders ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;")
            conn.commit()
            print("Added created_at successfully.")
        else:
            print("created_at already exists.")
            
        cursor.close()
        conn.close()
        print("PostgreSQL Migration completed.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    migrate()
