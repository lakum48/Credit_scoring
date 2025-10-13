import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

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
from sklearn.ensemble import GradientBoostingClassifier

def preprocess_data(data: pd.DataFrame):
    X = data.drop(columns=['loan_status'])
    y = data['loan_status']
    num_cols = X.select_dtypes(include=[np.number]).columns.to_list()
    cat_cols = X.select_dtypes(include='object').columns.to_list()



    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    num_pipe = Pipeline([
        ('impute',SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])
    cat_pipe = Pipeline([
        ('impute', SimpleImputer(strategy='most_frequent')),
        ('1hot', OneHotEncoder(handle_unknown='ignore'))
    ])

    preprocessor = ColumnTransformer([
        ('num', num_pipe, num_cols),
        ('cat', cat_pipe, cat_cols)
    ])

    catboost_model = ImbPipeline(steps=[
        ('preprocessor', preprocessor),
        ('SMOTE', SMOTE(random_state=42)),
        ('modell', CatBoostClassifier(
            learning_rate=0.08,
            l2_leaf_reg=3,
            iterations=1000,
            depth=8,
            random_seed=42,
            verbose=100
        ))
    ])

    lgbm_model = ImbPipeline(steps=[
        ('preprocessor', preprocessor),
        ('SMOTE', SMOTE(random_state=42)),
        ('modell', LGBMClassifier(
            subsample=0.6,
            reg_lambda=0,
            reg_alpha=0,
            num_leaves=31,
            n_estimators=800,
            min_child_samples=10,
            max_depth=5,
            learning_rate=0.1,
            colsample_bytree=0.6,
            random_state=42
        ))
    ])


    gradient_model = ImbPipeline([
    ('preprocessor', preprocessor),
    ('smote', SMOTE(random_state = 42)),
    ('modell', GradientBoostingClassifier(subsample = 1.0,
                                            n_estimators = 300,
                                            min_samples_split = 2,
                                            min_samples_leaf = 5,
                                            max_depth=  4,
                                            learning_rate = 0.1))
])

    return lgbm_model, catboost_model, gradient_model, X_train, y_train, X_test, y_test

