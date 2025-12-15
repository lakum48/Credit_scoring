# database.py
import os
from sqlalchemy import create_engine, Column, Integer, Float, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime

# Берем переменную окружения DATABASE_URL, если она есть
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+pg8000://postgres:danielDaniel1907!@localhost:5432/credit_app"
)

# Создаем движок SQLAlchemy
engine = create_engine(DATABASE_URL, echo=True)  # echo=True для логов SQL (можно убрать)

# Сессии для работы с БД
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Базовый класс для моделей
Base = declarative_base()

# Модель таблицы заявок
class CreditApplication(Base):
    __tablename__ = "applications"

    id = Column(Integer, primary_key=True, index=True)
    person_age = Column(Integer)
    person_income = Column(Float)
    person_home_ownership = Column(String(50))
    person_emp_length = Column(Float)
    loan_intent = Column(String(50))
    loan_grade = Column(String(10))
    loan_amnt = Column(Float)
    loan_int_rate = Column(Float)
    loan_percent_income = Column(Float)
    cb_person_default_on_file = Column(String(5))
    cb_person_cred_hist_length = Column(Integer)
    model_score = Column(Float)
    approved = Column(Boolean)
    timestamp = Column(DateTime, default=datetime.utcnow)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    token = Column(String(255), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

# Функция для получения сессии БД
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Создаем таблицы (можно запускать один раз при старте backend)
def init_db():
    Base.metadata.create_all(bind=engine)

if __name__ == "__main__":
    init_db()
    print("База данных и таблицы созданы!")
