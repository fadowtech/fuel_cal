import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()
db_url = os.getenv("DATABASE_URL")

def migrate():
    print("Connecting to database...")
    conn = psycopg2.connect(db_url)
    cursor = conn.cursor()
    
    # Check if columns exist in the users table
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='users';
    """)
    columns = [row[0] for row in cursor.fetchall()]
    
    new_columns = [
        ("created_at", "TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc')"),
        ("last_login", "TIMESTAMP WITHOUT TIME ZONE")
    ]
    
    for col_name, col_type in new_columns:
        if col_name not in columns:
            print(f"Adding column '{col_name}' to users table...")
            cursor.execute(f"ALTER TABLE users ADD COLUMN {col_name} {col_type};")
        else:
            print(f"Column '{col_name}' already exists.")
            
    conn.commit()
    cursor.close()
    conn.close()
    print("PostgreSQL Migration completed successfully.")

if __name__ == "__main__":
    if not db_url:
        print("DATABASE_URL not found in environment variables. Please check your .env file.")
    else:
        migrate()
