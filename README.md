Credit Scoring Project
Описание

Проект реализует систему кредитного скоринга для оценки вероятности дефолта клиентов. Используется машинное обучение для предсказания риска невозврата кредита. Модель показывает Recall = 0.75 и Precision = 0.96, что позволяет эффективно идентифицировать проблемных заемщиков и минимизировать ложные срабатывания.

Структура проекта

backend/               # Flask/FastAPI backend для работы с моделью
frontend/              # Приложение для взаимодействия с моделью
data/raw/              # Исходные данные для обучения модели
model_training/        # Скрипты подготовки данных и обучения модели
Dockerfile.backend     # Dockerfile для backend
Dockerfile.frontend    # Dockerfile для frontend
docker-compose.yml     # Конфигурация для запуска всех сервисов через Docker
README.md              # Документация проекта

Требования

- Python 3.10+

- Docker и Docker Compose

- Основные библиотеки Python: pandas, scikit-learn, numpy, matplotlib, seaborn, fastapi/flask(можно установить при запуске приложения)

Установка и запуск
1. Клонирование репозитория
- git clone https://github.com/lakum48/Credit_scoring.git
- cd Credit_scoring

2. Запуск через Docker Compose
- docker-compose up --build

3. Локальный запуск (без Docker)
Backend:
- cd backend
- pip install -r requirements.txt
- cd src
- uvicorn service:app

Frontend:
- cd frontend
- pip install -r requirements.txt
- streamlit run app.py
