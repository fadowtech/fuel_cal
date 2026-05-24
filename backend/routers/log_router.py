from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import database
import models
import schemas
from auth import get_current_user

router = APIRouter(
    prefix="/logs",
    tags=["logs"],
    responses={404: {"description": "Not found"}},
)

@router.post("/", response_model=schemas.FuelLog, status_code=status.HTTP_201_CREATED)
def create_fuel_log(log: schemas.FuelLogCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    db_log = models.FuelLog(**log.model_dump(), user_id=current_user.id)
    db.add(db_log)
    db.commit()
    db.refresh(db_log)
    return db_log

@router.get("/", response_model=List[schemas.FuelLog])
def read_fuel_logs(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    logs = db.query(models.FuelLog).filter(models.FuelLog.user_id == current_user.id).offset(skip).limit(limit).all()
    return logs

@router.put("/{log_id}", response_model=schemas.FuelLog)
def update_fuel_log(log_id: int, log_update: schemas.FuelLogCreate, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    db_log = db.query(models.FuelLog).filter(models.FuelLog.id == log_id, models.FuelLog.user_id == current_user.id).first()
    if not db_log:
        raise HTTPException(status_code=404, detail="Fuel log not found")
    
    update_data = log_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_log, key, value)
        
    db.commit()
    db.refresh(db_log)
    return db_log

@router.delete("/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_fuel_log(log_id: int, db: Session = Depends(database.get_db), current_user: models.User = Depends(get_current_user)):
    db_log = db.query(models.FuelLog).filter(models.FuelLog.id == log_id, models.FuelLog.user_id == current_user.id).first()
    if not db_log:
        raise HTTPException(status_code=404, detail="Fuel log not found")
        
    db.delete(db_log)
    db.commit()
    return None
