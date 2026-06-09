from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    phone: Optional[str] = None
    gender: Optional[str] = None
    currency_code: Optional[str] = "USD"
    created_at: Optional[datetime] = None
    last_login: Optional[datetime] = None

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    gender: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResetPassword(BaseModel):
    email: EmailStr
    new_password: str

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
    vehicle_number: Optional[str] = None
    variant: Optional[str] = None
    vehicle_type: Optional[str] = None
    tank_type: Optional[str] = None
    highest_avg_mileage: Optional[float] = None
    avg_mileage: Optional[float] = None
    poor_mileage: Optional[float] = None
    notes: Optional[str] = None
    color: Optional[str] = None

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
    fuel_price: Optional[float] = None
    remaining_range: Optional[float] = None
    remaining_range_after: Optional[float] = None
    is_full_tank: Optional[bool] = False
    station_name: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None
    payment_method: Optional[str] = None
    bill_image_path: Optional[str] = None
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
    notes: Optional[str] = None

class ExpenseCreate(ExpenseBase):
    pass

class Expense(ExpenseBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class ReminderBase(BaseModel):
    category: str
    title: str
    due_date: Optional[datetime] = None
    due_km: Optional[float] = None
    amount: Optional[float] = None
    notes: Optional[str] = None
    repeat: Optional[bool] = False
    repeat_interval: Optional[str] = None
    notify_before_days: Optional[str] = None
    priority: Optional[str] = "High"
    status: Optional[str] = "pending"
    completed_at: Optional[datetime] = None

class ReminderCreate(ReminderBase):
    pass

class Reminder(ReminderBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class ServiceBase(BaseModel):
    vehicle_id: Optional[int] = None
    category: str
    title: str
    amount: float
    date: Optional[datetime] = None
    notes: Optional[str] = None

class ServiceCreate(ServiceBase):
    pass

class Service(ServiceBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

class ManageBase(BaseModel):
    type: str
    name: str
    price: Optional[float] = None

class ManageCreate(ManageBase):
    pass

class Manage(ManageBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True

