from sqlalchemy import create_engine, Column, Integer, Float, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
from urllib.parse import quote_plus

# твой пароль с !

DATABASE_URL = "postgresql+pg8000://postgres:danielDaniel1907!@localhost:5432/credit_app"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

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

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()