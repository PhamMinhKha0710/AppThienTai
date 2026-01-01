# AI Service for Smart Alert System

Python-based AI service providing intelligent alert scoring, duplicate detection, and notification timing optimization.

## Features

- **Alert Scoring**: ML-based priority scoring using Random Forest
- **Semantic Duplicate Detection**: Using Sentence Transformers (multilingual)
- **Notification Timing**: Contextual Bandit with Thompson Sampling
- **Online Learning**: Continuous improvement from user feedback

## Setup

### 1. Create virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Download pre-trained models

The sentence transformer model will be downloaded automatically on first run.

### 4. Run the service

```bash
python main.py
```

Or with uvicorn:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API Endpoints

- `POST /api/v1/score` - Score alert priority
- `POST /api/v1/duplicate/check` - Check for duplicates
- `POST /api/v1/timing/recommend` - Get notification timing recommendation
- `POST /api/v1/feedback/engagement` - Log user engagement
- `GET /api/v1/health` - Health check

## API Documentation

Visit `http://localhost:8000/docs` for interactive API documentation (Swagger UI).

## Docker

Build and run with Docker:

```bash
docker build -t ai-service .
docker run -p 8000:8000 ai-service
```

Or use docker-compose:

```bash
docker-compose up
```

## Project Structure

```
ai_service/
├── main.py                    # FastAPI application
├── config.py                  # Configuration
├── requirements.txt           # Dependencies
├── models/                    # AI Models
│   ├── alert_scorer.py
│   ├── duplicate_detector.py
│   └── notification_timing.py
├── services/                  # Services
│   ├── data_collector.py
│   └── model_trainer.py
├── utils/                     # Utilities
│   ├── features.py
│   └── metrics.py
└── data/                      # Data storage
    ├── models/                # Saved models
    ├── training/              # Training data
    └── cache/                 # Cache
```

## Development

Run tests:

```bash
pytest tests/
```

## License

MIT



Python-based AI service providing intelligent alert scoring, duplicate detection, and notification timing optimization.

## Features

- **Alert Scoring**: ML-based priority scoring using Random Forest
- **Semantic Duplicate Detection**: Using Sentence Transformers (multilingual)
- **Notification Timing**: Contextual Bandit with Thompson Sampling
- **Online Learning**: Continuous improvement from user feedback

## Setup

### 1. Create virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Download pre-trained models

The sentence transformer model will be downloaded automatically on first run.

### 4. Run the service

```bash
python main.py
```

Or with uvicorn:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API Endpoints

- `POST /api/v1/score` - Score alert priority
- `POST /api/v1/duplicate/check` - Check for duplicates
- `POST /api/v1/timing/recommend` - Get notification timing recommendation
- `POST /api/v1/feedback/engagement` - Log user engagement
- `GET /api/v1/health` - Health check

## API Documentation

Visit `http://localhost:8000/docs` for interactive API documentation (Swagger UI).

## Docker

Build and run with Docker:

```bash
docker build -t ai-service .
docker run -p 8000:8000 ai-service
```

Or use docker-compose:

```bash
docker-compose up
```

## Project Structure

```
ai_service/
├── main.py                    # FastAPI application
├── config.py                  # Configuration
├── requirements.txt           # Dependencies
├── models/                    # AI Models
│   ├── alert_scorer.py
│   ├── duplicate_detector.py
│   └── notification_timing.py
├── services/                  # Services
│   ├── data_collector.py
│   └── model_trainer.py
├── utils/                     # Utilities
│   ├── features.py
│   └── metrics.py
└── data/                      # Data storage
    ├── models/                # Saved models
    ├── training/              # Training data
    └── cache/                 # Cache
```

## Development

Run tests:

```bash
pytest tests/
```

## License

MIT



