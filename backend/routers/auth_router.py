from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from datetime import timedelta, datetime
import models, schemas, database, auth

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

@router.post("/signup", response_model=schemas.User)
def signup(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = auth.get_password_hash(user.password)
    new_user = models.User(
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        gender=user.gender,
        phone=user.phone,
        password_hash=hashed_password,
        currency_code=user.currency_code
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get("/check-user")
def check_user(email: str, db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == email).first()
    return {"exists": user is not None}

@router.post("/login", response_model=schemas.Token)
def login(request: Request, user_credentials: schemas.UserLogin, db: Session = Depends(database.get_db)):
    ip_address = request.client.host if request.client else "unknown"
    email = user_credentials.email
    
    cutoff_time = datetime.utcnow() - timedelta(minutes=15)
    
    # Check IP limit
    ip_attempts = db.query(models.LoginAttempt).filter(
        models.LoginAttempt.ip_address == ip_address,
        models.LoginAttempt.attempt_time >= cutoff_time,
        models.LoginAttempt.success == False
    ).count()
    
    if ip_attempts >= 20:
        raise HTTPException(status_code=429, detail="Too many login attempts from this IP. Please try again in 15 minutes.")
        
    # Check Email limit
    email_attempts = db.query(models.LoginAttempt).filter(
        models.LoginAttempt.email == email,
        models.LoginAttempt.attempt_time >= cutoff_time,
        models.LoginAttempt.success == False
    ).count()
    
    if email_attempts >= 10:
        raise HTTPException(status_code=429, detail="Too many login attempts for this account. Please try again in 15 minutes.")

    user = db.query(models.User).filter(models.User.email == email).first()
    
    if not user or not auth.verify_password(user_credentials.password, user.password_hash):
        new_attempt = models.LoginAttempt(email=email, ip_address=ip_address, success=False)
        db.add(new_attempt)
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Invalid Credentials"
        )
        
    new_attempt = models.LoginAttempt(email=email, ip_address=ip_address, success=True)
    db.add(new_attempt)
    user.last_login = datetime.utcnow()
    db.commit()
        
    access_token = auth.create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/reset-password")
def reset_password(reset_data: schemas.UserResetPassword, db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == reset_data.email).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    user.password_hash = auth.get_password_hash(reset_data.new_password)
    db.commit()
    return {"message": "Password updated successfully"}
