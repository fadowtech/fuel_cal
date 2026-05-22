from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    currency_code: Optional[str] = "USD"

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(UserBase):
    id: int

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class VehicleBase(BaseModel):
    make: str
    model: str
    year: int
    fuel_type: str
    tank_capacity: float

class VehicleCreate(VehicleBase):
    pass

class Vehicle(VehicleBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class FuelLogBase(BaseModel):
    vehicle_id: Optional[int] = None
    odometer: float
    fuel_quantity: float
    total_cost: float
    station_name: Optional[str] = None
    date: Optional[datetime] = None

class FuelLogCreate(FuelLogBase):
    pass

class FuelLog(FuelLogBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class ExpenseBase(BaseModel):
    vehicle_id: Optional[int] = None
    category: str
    title: str
    amount: float
    date: Optional[datetime] = None

class ExpenseCreate(ExpenseBase):
    pass

class Expense(ExpenseBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True
