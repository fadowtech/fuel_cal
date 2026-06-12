from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import database
import models
import schemas
from auth import get_current_user

router = APIRouter(
    prefix="/vehicles",
    tags=["vehicles"],
    responses={404: {"description": "Not found"}},
)

@router.post("/", response_model=schemas.Vehicle, status_code=status.HTTP_201_CREATED)
def create_vehicle(vehicle: schemas.VehicleCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    db_vehicle = models.Vehicle(**vehicle.model_dump(), user_id=current_user.id)
    
    if db_vehicle.is_default is True:
        db.query(models.Vehicle).filter(models.Vehicle.user_id == current_user.id).update({"is_default": False})
        
    db.add(db_vehicle)
    db.commit()
    db.refresh(db_vehicle)
    return db_vehicle

@router.get("/", response_model=List[schemas.Vehicle])
def read_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    vehicles = db.query(models.Vehicle).filter(models.Vehicle.user_id == current_user.id).offset(skip).limit(limit).all()
    return vehicles

@router.delete("/{vehicle_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_vehicle(
    vehicle_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_vehicle = db.query(models.Vehicle).filter(models.Vehicle.id == vehicle_id, models.Vehicle.user_id == current_user.id).first()
    if not db_vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    
    # Delete dependent fuel logs
    db.query(models.FuelLog).filter(models.FuelLog.vehicle_id == vehicle_id).delete()
    # Delete dependent expenses
    db.query(models.Expense).filter(models.Expense.vehicle_id == vehicle_id).delete()
    
    db.delete(db_vehicle)
    db.commit()
    return None

@router.put("/{vehicle_id}", response_model=schemas.Vehicle)
def update_vehicle(
    vehicle_id: int,
    vehicle_update: schemas.VehicleCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_vehicle = db.query(models.Vehicle).filter(models.Vehicle.id == vehicle_id, models.Vehicle.user_id == current_user.id).first()
    if not db_vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    
    update_data = vehicle_update.model_dump(exclude_unset=True)
    
    if update_data.get('is_default') is True:
        db.query(models.Vehicle).filter(
            models.Vehicle.user_id == current_user.id, 
            models.Vehicle.id != vehicle_id
        ).update({"is_default": False})

    for key, value in update_data.items():
        setattr(db_vehicle, key, value)
        
    db.commit()
    db.refresh(db_vehicle)
    return db_vehicle
