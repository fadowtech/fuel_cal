from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from database import Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    phone = Column(String, nullable=True)
    password_hash = Column(String)
    currency_code = Column(String, default="USD")
    
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
