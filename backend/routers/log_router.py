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
