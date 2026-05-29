import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

# Get DB URL
db_url = os.getenv("DATABASE_URL")
if not db_url:
    print("Error: DATABASE_URL environment variable not set.")
    sys.exit(1)

print(f"Connecting to database...")

try:
    engine = create_engine(db_url)
    with engine.connect() as conn:
        print("Adding 'amount' column to 'reminders' table...")
        
        # Check if the column already exists to prevent errors
        check_col = conn.execute(text(
            "SELECT column_name FROM information_schema.columns "
            "WHERE table_name='reminders' AND column_name='amount';"
        )).fetchone()
        
        if check_col:
            print("The 'amount' column already exists in the 'reminders' table. No migration needed.")
        else:
            # Add the column
            conn.execute(text("ALTER TABLE reminders ADD COLUMN amount DOUBLE PRECISION;"))
            conn.commit()
            print("Successfully added 'amount' column to 'reminders' table!")

except Exception as e:
    print(f"An error occurred during migration: {e}")
    sys.exit(1)
