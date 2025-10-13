import joblib 
import numpy as np
import pandas as pd

model = joblib.load("stacking_model.pkl")

def predict_data(input_data: pd.DataFrame):
    return model.predict(input_data)
