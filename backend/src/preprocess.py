import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
from collections import Counter

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
    data['person_emp_length'] = np.log1p(data['person_emp_length'])
    data['person_income'] = np.log1p(data['person_income'])
    data['loan_percent_income'] = np.log1p(data['loan_percent_income'])
    data = data.drop(columns=['cb_person_cred_hist_length', 'cb_person_default_on_file', 'person_age'], axis = 1)

    X = data.drop(columns=['loan_status'])
    y = data['loan_status']
    num_cols = X.select_dtypes(include=[np.number]).columns.to_list()
    cat_cols = X.select_dtypes(include='object').columns.to_list()
    counter = Counter(y)
    scale_pos_weight = counter[0] / counter[1]


    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

    best_params = {'learning_rate': 0.17450714275791432,
    'depth': 3,
    'l2_leaf_reg': 6.343186258115287,
    'subsample': 0.754740858904117,
    'colsample_bylevel': 0.8049005549414734,
    'min_data_in_leaf': 92,
    'iterations': 1500}

    final_model = CatBoostClassifier(
        **best_params,
        random_seed=42,
        loss_function='Logloss',
        eval_metric='PRAUC',
        scale_pos_weight=scale_pos_weight,
        verbose=False,
        cat_features=cat_cols  
    )

    # Обучение на всём train с early stopping
    
        
    return final_model, X_train, y_train, X_test, y_test

