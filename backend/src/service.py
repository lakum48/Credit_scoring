from fastapi import FastAPI
import random
from data_models import ClientData
from predict import predict_data
import numpy as np
import pandas as pd



app = FastAPI()


@app.post("/score")
def score(data: ClientData):
    loan_grade = random.choice(["A", "B"])
    loan_int_rate = round(random.uniform(5.0, 15.0), 2)
    cb_person_default_on_file =  "N"
    cb_person_cred_hist_length = random.randint(1, 15)

    loan_percent_income = round(data.loan_amnt / data.person_income, 3)
    
    df = pd.DataFrame([{
        "person_age": data.person_age,
        "person_income": data.person_income,
        "person_home_ownership": data.person_home_ownership,
        "person_emp_length": data.person_emp_length or 0.0,
        "loan_intent": data.loan_intent,
        "loan_grade": loan_grade,
        "loan_amnt": data.loan_amnt,
        "loan_int_rate": loan_int_rate,
        "loan_percent_income": loan_percent_income,
        "cb_person_default_on_file": cb_person_default_on_file,
        "cb_person_cred_hist_length": cb_person_cred_hist_length
    }])
    prediction = predict_data(df)
    return {"approved": bool(prediction[0])}

