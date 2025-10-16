from fastapi import FastAPI
import random
from data_models import ClientData
from predict import predict_data
import numpy as np
import pandas as pd
from database import CreditApplication, get_db
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import Base, engine



app = FastAPI()

@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)


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
    prediction = predict_data(df)  # допустим, возвращает np.array
    model_score = float(prediction[0])      # вероятность
    approved = bool(prediction[0] > 0.5)
 

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
    
    return {"approved": bool(prediction[0])}

