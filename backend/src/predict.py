import joblib 
import numpy as np
import pandas as pd

model = joblib.load("stacking_model.pkl")

def predict_data(input_data: pd.DataFrame):
    """
    Возвращает вероятность класса 1, если доступен predict_proba,
    иначе бинарный прогноз (0/1).
    """
    if hasattr(model, "predict_proba"):
        proba = model.predict_proba(input_data)
        # берем вероятность положительного класса
        return proba[:, 1]
    return model.predict(input_data)
