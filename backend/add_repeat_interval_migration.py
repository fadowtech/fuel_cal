from database import engine
from sqlalchemy import text

def migrate():
    try:
        with engine.connect() as conn:
            print("Adding repeat_interval column to reminders table...")
            conn.execute(text("ALTER TABLE reminders ADD COLUMN IF NOT EXISTS repeat_interval VARCHAR;"))
            conn.commit()
            print("Migration successful.")
    except Exception as e:
        print(f"Error during migration: {e}")

if __name__ == "__main__":
    migrate()
