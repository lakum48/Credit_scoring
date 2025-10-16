import streamlit as st
import pandas as pd
import requests
import os

st.set_page_config(page_title="Loan Approval Predictor", layout="centered")

st.title("Loan Approval Predictor")
st.write("Введите данные клиента для предсказания одобрения кредита")

# Форма ввода данных клиента
with st.form("client_data_form"):
    person_age = st.number_input("Возраст", min_value=18, max_value=100, value=30)
    person_income = st.number_input("Доход", min_value=0, value=50000)
    person_home_ownership = st.selectbox("Владение жильём", ["RENT", "OWN", "MORTGAGE", "OTHER"])
    person_emp_length = st.number_input("Стаж работы (лет)", min_value=0, max_value=50, value=5)
    loan_intent = st.selectbox("Цель кредита", ["PERSONAL", "EDUCATION", "MEDICAL", "HOMEIMPROVEMENT", "VENTURE", "DEBTCONSOLIDATION", "BUSINESS"])
    loan_grade = st.selectbox("Рейтинг кредита", ["A", "B", "C", "D", "E", "F"])
    loan_amnt = st.number_input("Сумма кредита", min_value=0, value=10000)
    loan_int_rate = st.number_input("Процентная ставка", min_value=0.0, max_value=30.0, value=10.0)
    cb_person_default_on_file = st.selectbox("Был ли дефолт", ["Y", "N"])
    cb_person_cred_hist_length = st.number_input("Длина кредитной истории", min_value=0, max_value=50, value=5)

    submitted = st.form_submit_button("Предсказать")

if submitted:
    # Рассчитаем loan_percent_income
    loan_percent_income = round(loan_amnt / person_income, 3) if person_income > 0 else 0

    data = {
        "person_age": person_age,
        "person_income": person_income,
        "person_home_ownership": person_home_ownership,
        "person_emp_length": person_emp_length,
        "loan_intent": loan_intent,
        "loan_grade": loan_grade,
        "loan_amnt": loan_amnt,
        "loan_int_rate": loan_int_rate,
        "loan_percent_income": loan_percent_income,
        "cb_person_default_on_file": cb_person_default_on_file,
        "cb_person_cred_hist_length": cb_person_cred_hist_length
    }

    st.subheader("Входные данные")
    st.json(data)

    # Отправляем данные на ваш API
    try:
        BACKEND_URL = os.getenv("BACKEND_URL", "http://backend:8000") + "/score"
        response = requests.post(BACKEND_URL, json=data)

        if response.status_code == 200:
            result = response.json()
            st.subheader("Результат предсказания")
            st.write(f"Approved: {result.get('approved')}")
        else:
            st.error(f"Ошибка API: {response.status_code}")
    except Exception as e:
        st.error(f"Не удалось подключиться к API: {e}")