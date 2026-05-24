from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import models, schemas
from database import get_db
from auth import get_current_user

router = APIRouter(
    prefix="/reminders",
    tags=["reminders"]
)

@router.post("/", response_model=schemas.Reminder)
def create_reminder(reminder: schemas.ReminderCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_reminder = models.Reminder(**reminder.dict(), user_id=current_user.id)
    db.add(db_reminder)
    db.commit()
    db.refresh(db_reminder)
    return db_reminder

@router.get("/", response_model=List[schemas.Reminder])
def read_reminders(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    reminders = db.query(models.Reminder).filter(models.Reminder.user_id == current_user.id).offset(skip).limit(limit).all()
    return reminders

@router.put("/{reminder_id}", response_model=schemas.Reminder)
def update_reminder(reminder_id: int, reminder: schemas.ReminderCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id, models.Reminder.user_id == current_user.id).first()
    if not db_reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
    
    for key, value in reminder.dict().items():
        setattr(db_reminder, key, value)
        
    db.commit()
    db.refresh(db_reminder)
    return db_reminder

@router.delete("/{reminder_id}")
def delete_reminder(reminder_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    db_reminder = db.query(models.Reminder).filter(models.Reminder.id == reminder_id, models.Reminder.user_id == current_user.id).first()
    if not db_reminder:
        raise HTTPException(status_code=404, detail="Reminder not found")
        
    db.delete(db_reminder)
    db.commit()
    return {"message": "Reminder deleted successfully"}
