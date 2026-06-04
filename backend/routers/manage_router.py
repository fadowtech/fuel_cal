from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

import models, schemas, auth
from database import get_db

router = APIRouter(
    prefix="/manage",
    tags=["Manage"]
)

@router.get("/", response_model=List[schemas.Manage])
def get_manages(type: Optional[str] = None, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    query = db.query(models.Manage).filter(models.Manage.user_id == current_user.id)
    if type:
        query = query.filter(models.Manage.type == type)
    return query.all()

@router.post("/", response_model=schemas.Manage)
def create_manage(manage: schemas.ManageCreate, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    db_manage = models.Manage(**manage.model_dump(), user_id=current_user.id)
    db.add(db_manage)
    db.commit()
    db.refresh(db_manage)
    return db_manage

@router.put("/{manage_id}", response_model=schemas.Manage)
def update_manage(manage_id: int, manage: schemas.ManageCreate, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    db_manage = db.query(models.Manage).filter(models.Manage.id == manage_id, models.Manage.user_id == current_user.id).first()
    if db_manage is None:
        raise HTTPException(status_code=404, detail="Manage not found")
    
    update_data = manage.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_manage, key, value)
        
    db.commit()
    db.refresh(db_manage)
    return db_manage

@router.delete("/{manage_id}")
def delete_manage(manage_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(auth.get_current_user)):
    db_manage = db.query(models.Manage).filter(models.Manage.id == manage_id, models.Manage.user_id == current_user.id).first()
    if db_manage is None:
        raise HTTPException(status_code=404, detail="Manage not found")
        
    db.delete(db_manage)
    db.commit()
    return {"message": "Manage deleted successfully"}
