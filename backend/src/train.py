import numpy as np
import pandas as pd
import os
import joblib

from sklearn.metrics import  precision_score, recall_score,  f1_score

from preprocess import preprocess_data

def train_model():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(base_dir, "../../data/raw/credit_risk_dataset.csv")
    data = pd.read_csv(data_path)

    final_model, X_train, y_train, X_test, y_test= preprocess_data(data)

    final_model.fit(
        X_train, y_train,
        eval_set=(X_test, y_test),
        early_stopping_rounds=100,
        use_best_model=True,
        verbose=100
    )

    predict = final_model.predict(X_test)
    print(f1_score(y_test, predict))
    print(recall_score(y_test, predict))
    print(precision_score(y_test, predict))

    joblib.dump(final_model, 'CatBoost_model.pkl')

if __name__ == "__main__":
    train_model()