from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import models, database
from routers import auth_router, user_router, vehicle_router, log_router, expense_router, reminder_router, service_router

# Initialize the database tables
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="Fuel Calculator API",
    description="Backend for the Fuel Calculator Flutter App",
    version="1.0.0"
)

# CORS configuration to allow Flutter to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, restrict this to specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(user_router.router)
app.include_router(vehicle_router.router)
app.include_router(log_router.router)
app.include_router(expense_router.router)
app.include_router(reminder_router.router)
app.include_router(service_router.router)

@app.get("/")
def root():
    return {"message": "Welcome to Fuel Calculator API!"}
