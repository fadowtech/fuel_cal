from database import engine
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError

print("Connecting to database:", engine.url)
try:
    with engine.connect() as conn:
        conn.execute(text("ALTER TABLE expenses ADD COLUMN notes TEXT;"))
        conn.commit()
    print("Success! The 'notes' column has been added to the expenses table.")
except ProgrammingError as e:
    if "already exists" in str(e).lower() or "duplicate column" in str(e).lower():
        print("The 'notes' column already exists in the database. You are good to go!")
    else:
        print(f"An error occurred: {e}")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
