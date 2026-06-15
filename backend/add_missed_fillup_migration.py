from database import engine
from sqlalchemy import text

def migrate():
    try:
        with engine.connect() as conn:
            print("Adding missed_fillup column to fuel_logs table...")
            try:
                conn.execute(text("ALTER TABLE fuel_logs ADD COLUMN missed_fillup BOOLEAN DEFAULT FALSE;"))
            except Exception as e:
                print(f"Column might already exist or error occurred: {e}")
            
            conn.commit()
            print("Migration successful.")
    except Exception as e:
        print(f"Error during migration: {e}")

if __name__ == "__main__":
    migrate()
