from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import models, schemas, database
from auth import get_current_user

router = APIRouter(
    prefix="/services",
    tags=["Services"]
)

@router.post("/", response_model=schemas.Service)
def create_service(
    service: schemas.ServiceCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_service = models.Service(**service.model_dump(), user_id=current_user.id)
    db.add(db_service)
    db.commit()
    db.refresh(db_service)
    return db_service

@router.get("/", response_model=List[schemas.Service])
def get_services(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    services = db.query(models.Service).filter(models.Service.user_id == current_user.id).offset(skip).limit(limit).all()
    return services

@router.delete("/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_service(
    service_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_service = db.query(models.Service).filter(models.Service.id == service_id, models.Service.user_id == current_user.id).first()
    if not db_service:
        raise HTTPException(status_code=404, detail="Service not found")
    
    db.delete(db_service)
    db.commit()
    return None

@router.put("/{service_id}", response_model=schemas.Service)
def update_service(
    service_id: int,
    service_update: schemas.ServiceCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(get_current_user)
):
    db_service = db.query(models.Service).filter(models.Service.id == service_id, models.Service.user_id == current_user.id).first()
    if not db_service:
        raise HTTPException(status_code=404, detail="Service not found")
    
    update_data = service_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_service, key, value)
        
    db.commit()
    db.refresh(db_service)
    return db_service
