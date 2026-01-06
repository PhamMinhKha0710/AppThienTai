"""Configuration for AI Service"""
import os
from pathlib import Path

# Base directories
BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
MODELS_DIR = DATA_DIR / "models"
TRAINING_DIR = DATA_DIR / "training"
CACHE_DIR = DATA_DIR / "cache"

# Create directories if they don't exist
for directory in [DATA_DIR, MODELS_DIR, TRAINING_DIR, CACHE_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

# Model configurations
SENTENCE_TRANSFORMER_MODEL = "paraphrase-multilingual-MiniLM-L12-v2"
DUPLICATE_SIMILARITY_THRESHOLD = 0.85

# Random Forest configurations
RF_N_ESTIMATORS = 100
RF_MAX_DEPTH = 10
RF_RANDOM_STATE = 42

# Notification timing configurations
N_TIME_SLOTS = 24
EPSILON_EXPLORATION = 0.1

# Database
DATABASE_PATH = TRAINING_DIR / "feedback.db"

# Feature engineering
N_FEATURES = 15

# Cold start configurations
SYNTHETIC_SAMPLES = 1000
MIN_SAMPLES_FOR_RETRAIN = 100

# API configurations
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))

# Open-Meteo API Configuration (100% FREE)
OPEN_METEO_FORECAST_URL = "https://api.open-meteo.com/v1/forecast"
OPEN_METEO_ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive"
WEATHER_CACHE_DIR = CACHE_DIR / "weather"
WEATHER_CACHE_ENABLED = True

# Weather data collection settings
HISTORICAL_WEATHER_LOOKBACK_DAYS = 30  # Days of historical weather to fetch
WEATHER_API_TIMEOUT = 30  # seconds


