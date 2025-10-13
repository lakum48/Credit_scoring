from pydantic import BaseModel
from typing import Optional

class ClientData(BaseModel):
    person_age: int
    person_income: float
    person_home_ownership: str
    person_emp_length: Optional[float] = None  # может быть пропущено
    loan_intent: str
    loan_grade: Optional[str] = None           # теперь не обязателен
    loan_amnt: float
    loan_int_rate: Optional[float] = None      # теперь не обязателен
    loan_percent_income: Optional[float] = None
    cb_person_default_on_file: Optional[str] = None
    cb_person_cred_hist_length: Optional[int] = None