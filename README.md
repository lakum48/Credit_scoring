# Credit Scoring Project

Модель кредитного скоринга + REST API на FastAPI + два клиента: web (Streamlit) и мобильный Flutter.

**Метрики модели**  
- Recall = 0.82  
- Precision = 0.82  

---

## 📂 Структура
```
credit_scoring_app/
├─ backend/
│  ├─ src/
│  │  ├─ service.py          # FastAPI: /score, /applications, /register, /login, CORS
│  │  ├─ predict.py          # загрузка модели, predict/predict_proba
│  │  ├─ data_models.py      # схема входных данных
│  │  ├─ database.py         # SQLAlchemy (Postgres), таблицы applications, users
│  │  └─ ...
│  └─ requirements.txt
├─ frontend/
│  └─ app.py                 # Streamlit UI (старый веб-клиент)
├─ mobile_flutter/           # Новый мобильный/веб клиент на Flutter
│  ├─ pubspec.yaml
│  └─ lib/
│     ├─ main.dart           # навигация: Скоринг / История / Профиль
│     ├─ core/               # http client, config
│     ├─ features/predict    # форма ввода, вызов /score
│     ├─ features/history    # список заявок с /applications
│     └─ features/auth       # регистрация/логин через /register /login
├─ data/                     # данные
├─ model_training/           # ноутбуки и артефакты обучения
├─ Dockerfile.backend
├─ Dockerfile.frontend
└─ docker-compose.yml
```

---

## 🔌 API
- `POST /score` — принять данные клиента, вернуть `approved`, `probability`, `id`; пишет в таблицу `applications`.
- `GET /applications?limit=50` — история заявок (последние).
- `POST /register` — простая регистрация, возвращает токен.
- `POST /login` — логин, возвращает токен.
Все эндпоинты с включённым CORS (по умолчанию `allow_origins=["*"]`, сузьте в проде).

---

## 🛠 Требования
- Python 3.10+  
- Postgres (по умолчанию `postgresql+pg8000://postgres:danielDaniel1907!@localhost:5432/credit_app`, настраивается через `DATABASE_URL`)
- Установки: `pip install -r backend/requirements.txt` + `pip install "pydantic[email]" email-validator`
- Flutter 3.3+ (для mobile_flutter)

---

## 🚀 Запуск backend (локально без Docker)
```bash
cd credit_scoring_app/backend
pip install -r requirements.txt
pip install "pydantic[email]" email-validator   # для EmailStr
cd src
uvicorn service:app --reload --host 0.0.0.0 --port 8000
```

---

## 🌐 Запуск старого веб-клиента (Streamlit)
```bash
cd credit_scoring_app/frontend
pip install -r requirements.txt
streamlit run app.py
```

---

## 📱 Запуск Flutter клиента
```bash
cd credit_scoring_app/mobile_flutter
flutter pub get
# web/dev
flutter run -d chrome
# android/ios — выбрать устройство/эмулятор
```
В `lib/core/config.dart` укажите `apiBaseUrl` на хост, где крутится backend (не 127.0.0.1, если устройство другое).

---

## 🧠 Модель
- Артефакт: `backend/src/stacking_model.pkl`
- Логика: `predict.py` пытается использовать `predict_proba`, иначе `predict`.

---

## 📊 Метрики и визуализация
- Recall: 0.82
- Precision: 0.82
- PR-кривая: `image-1.png`
