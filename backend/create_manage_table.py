import models
from database import engine

print("Connecting to database:", engine.url)
print("Creating manages table if it doesn't exist...")
models.Base.metadata.create_all(bind=engine)
print("Success! The 'manages' table is ready.")
