from fastapi import FastAPI, Depends, HTTPException
from data_models import ClientData
from predict import predict_data
import pandas as pd
from database import CreditApplication, get_db, Base, engine, User
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import hashlib
import secrets
from typing import List

app = FastAPI(title="Credit Scoring API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # настройте на конкретные origin в проде
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def _hash_password(password: str) -> str:
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)


@app.post("/register")
def register_user(data: RegisterRequest, db: Session = Depends(get_db)):
    exists = db.query(User).filter(User.email == data.email).first()
    if exists:
        raise HTTPException(status_code=400, detail="Email already registered")
    token = secrets.token_hex(16)
    user = User(
        email=data.email,
        password_hash=_hash_password(data.password),
        token=token,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"token": token}


@app.post("/login")
def login_user(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == data.email).first()
    if not user or user.password_hash != _hash_password(data.password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    # обновляем токен для простоты
    user.token = secrets.token_hex(16)
    db.commit()
    return {"token": user.token}


@app.post("/score")
def score(data: ClientData, db: Session = Depends(get_db)):
    df = pd.DataFrame([{
        "person_age": data.person_age,
        "person_income": data.person_income,
        "person_home_ownership": data.person_home_ownership,
        "person_emp_length": data.person_emp_length or 0.0,
        "loan_intent": data.loan_intent,
        "loan_grade": data.loan_grade,
        "loan_amnt": data.loan_amnt,
        "loan_int_rate": data.loan_int_rate,
        "loan_percent_income": data.loan_percent_income,
        "cb_person_default_on_file": data.cb_person_default_on_file,
        "cb_person_cred_hist_length": data.cb_person_cred_hist_length
    }])
    prediction = predict_data(df)  # np.array вероятностей или классов
    model_score = float(prediction[0])  # вероятность положительного класса
    approved = bool(model_score > 0.5)

    record = CreditApplication(
        person_age=data.person_age,
        person_income=data.person_income,
        person_home_ownership=data.person_home_ownership,
        person_emp_length=data.person_emp_length or 0.0,
        loan_intent=data.loan_intent,
        loan_grade=data.loan_grade,
        loan_amnt=data.loan_amnt,
        loan_int_rate=data.loan_int_rate,
        loan_percent_income=data.loan_percent_income,
        cb_person_default_on_file=data.cb_person_default_on_file,
        cb_person_cred_hist_length=data.cb_person_cred_hist_length,
        model_score=model_score,
        approved=approved
    )
    db.add(record)
    db.commit()
    db.refresh(record)

    return {"approved": approved, "probability": model_score, "id": record.id}


@app.get("/applications")
def list_applications(limit: int = 50, db: Session = Depends(get_db)):
    rows: List[CreditApplication] = (
        db.query(CreditApplication)
        .order_by(CreditApplication.timestamp.desc())
        .limit(limit)
        .all()
    )
    return [
        {
            "id": r.id,
            "person_age": r.person_age,
            "person_income": r.person_income,
            "person_home_ownership": r.person_home_ownership,
            "person_emp_length": r.person_emp_length,
            "loan_intent": r.loan_intent,
            "loan_grade": r.loan_grade,
            "loan_amnt": r.loan_amnt,
            "loan_int_rate": r.loan_int_rate,
            "loan_percent_income": r.loan_percent_income,
            "cb_person_default_on_file": r.cb_person_default_on_file,
            "cb_person_cred_hist_length": r.cb_person_cred_hist_length,
            "model_score": r.model_score,
            "approved": r.approved,
            "timestamp": r.timestamp,
        }
        for r in rows
    ]
