from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from database import Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String, index=True)
    last_name = Column(String, index=True)
    gender = Column(String, nullable=True)
    email = Column(String, unique=True, index=True)
    phone = Column(String, nullable=True)
    password_hash = Column(String)
    currency_code = Column(String, nullable=True, default=None)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    last_login = Column(DateTime, nullable=True)
    
    vehicles = relationship("Vehicle", back_populates="owner")
    logs = relationship("FuelLog", back_populates="user")

class Vehicle(Base):
    __tablename__ = "vehicles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    make = Column(String)
    model = Column(String)
    year = Column(Integer)
    fuel_type = Column(String)
    tank_capacity = Column(Float)
    vehicle_number = Column(String, nullable=True)
    variant = Column(String, nullable=True)
    vehicle_type = Column(String, nullable=True)
    tank_type = Column(String, nullable=True)
    highest_avg_mileage = Column(Float, nullable=True)
    avg_mileage = Column(Float, nullable=True)
    poor_mileage = Column(Float, nullable=True)
    notes = Column(String, nullable=True)
    color = Column(String, nullable=True)
    is_default = Column(Boolean, default=False)
    
    owner = relationship("User", back_populates="vehicles")
    logs = relationship("FuelLog", back_populates="vehicle")

class FuelLog(Base):
    __tablename__ = "fuel_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=True)
    date = Column(DateTime, default=datetime.datetime.utcnow)
    odometer = Column(Float)
    fuel_quantity = Column(Float)
    total_cost = Column(Float)
    fuel_price = Column(Float, nullable=True)
    remaining_range = Column(Float, nullable=True)
    remaining_range_after = Column(Float, nullable=True)
    is_full_tank = Column(Boolean, default=False)
    station_name = Column(String, nullable=True)
    location = Column(String, nullable=True)
    notes = Column(String, nullable=True)
    payment_method = Column(String, nullable=True)
    bill_image_path = Column(String, nullable=True)
    
    user = relationship("User", back_populates="logs")
    vehicle = relationship("Vehicle", back_populates="logs")

class Expense(Base):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=True)
    category = Column(String)
    title = Column(String)
    amount = Column(Float)
    date = Column(DateTime, default=datetime.datetime.utcnow)
    notes = Column(String, nullable=True)
    
    user = relationship("User")
    vehicle = relationship("Vehicle")

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    category = Column(String)
    title = Column(String)
    due_date = Column(DateTime, nullable=True)
    due_km = Column(Float, nullable=True)
    amount = Column(Float, nullable=True)
    notes = Column(String, nullable=True)
    repeat = Column(Boolean, default=False)
    repeat_interval = Column(String, nullable=True)
    notify_before_days = Column(String, nullable=True) # e.g. "30,7,1"
    priority = Column(String, default="High")
    status = Column(String, default="pending") # "pending", "completed", "skipped"
    completed_at = Column(DateTime, nullable=True)
    
    user = relationship("User")

class Service(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=True)
    category = Column(String)
    title = Column(String)
    amount = Column(Float)
    date = Column(DateTime, default=datetime.datetime.utcnow)
    notes = Column(String, nullable=True)
    
    user = relationship("User")
    vehicle = relationship("Vehicle")

class Manage(Base):
    __tablename__ = "manages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    type = Column(String, index=True) # "fuel" or "station"
    name = Column(String)
    price = Column(Float, nullable=True) # Used for fuel
    
    user = relationship("User")

class LoginAttempt(Base):
    __tablename__ = "login_attempts"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, index=True, nullable=True)
    ip_address = Column(String, index=True)
    attempt_time = Column(DateTime, default=datetime.datetime.utcnow)
    success = Column(Boolean, default=False)

