import numpy as np
import pandas as pd
import os
import joblib

from sklearn.impute import SimpleImputer
from sklearn.model_selection import train_test_split, GridSearchCV, RandomizedSearchCV
from sklearn.metrics import roc_auc_score, precision_recall_curve, fbeta_score, precision_score,recall_score, PrecisionRecallDisplay, f1_score, accuracy_score
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from imblearn.over_sampling import SMOTE
from imblearn.pipeline import Pipeline as ImbPipeline
from sklearn.pipeline import Pipeline 
from sklearn.compose import ColumnTransformer


from sklearn.linear_model import LogisticRegression
from catboost import CatBoostClassifier
from lightgbm import LGBMClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.ensemble import StackingClassifier


from preprocess import preprocess_data

def train_model():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    data_path = os.path.join(base_dir, "../../data/raw/credit_risk_dataset.csv")
    data = pd.read_csv(data_path)

    lgbm_model, catboost_model, gradient_model, X_train, y_train, X_test, y_test= preprocess_data(data)


    estimators = [
        ('lgbm', lgbm_model),
        ('catboost', catboost_model),
        ('gradient', gradient_model)
    ]
    final_estimator = LogisticRegression(max_iter=1000, random_state=42)
    

    # Сам стекинг
    stacking_model = StackingClassifier(
        estimators=estimators,
        final_estimator=final_estimator,
        cv=5,
        n_jobs=-1,
        stack_method='predict_proba'  # чтобы использовать вероятности
    )

    stacking_model.fit(X_train, y_train)

    predict = stacking_model.predict(X_test)
    print(f1_score(y_test, predict))
    print(recall_score(y_test, predict))
    print(precision_score(y_test, predict))

    joblib.dump(stacking_model, 'stacking_model.pkl')

if __name__ == "__main__":
    train_model()