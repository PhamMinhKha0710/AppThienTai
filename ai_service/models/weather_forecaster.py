"""
Weather Forecaster Model
Predicts weather conditions (temperature, humidity, rainfall) based on historical data.
"""
import numpy as np
import pandas as pd
import joblib
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional

try:
    from sklearn.ensemble import RandomForestRegressor
    from sklearn.preprocessing import StandardScaler
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import mean_absolute_error
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False

class WeatherForecaster:
    """
    Weather Forecasting Model
    Predicts next-day weather metrics: Temperature, Humidity, Rainfall
    """
    
    def __init__(self, data_dir: Path = None):
        if data_dir is None:
            data_dir = Path(__file__).parent.parent / "data"
        
        self.data_dir = data_dir
        self.models_dir = data_dir / "models"
        self.models_dir.mkdir(parents=True, exist_ok=True)
        
        self.model = None
        self.scaler = None
        self.is_trained = False
        
        # Features needed for prediction
        self.feature_columns = ['month', 'day_of_year', 'province_id', 'region_id', 'prev_temp', 'prev_humid', 'prev_rain']
    
    def train(self, data_path: Path = None) -> Dict:
        """Train model using historical weather strings."""
        if not HAS_SKLEARN:
            return {"status": "error", "message": "scikit-learn not installed"}

        if data_path is None:
            data_path = self.data_dir / "weather" / "vietnam_weather_2020_2024.json"
            
        print(f"[WeatherForecaster] Loading data from {data_path}...")
        try:
            # Load JSON data
            df = pd.read_json(data_path)
            
            # Basic preprocessing if needed (assuming structure matches expected)
            # We need to create lag features for 'prev_day' values if not present
            # or simply use the data structure if it's already formatted.
            # For simplicity, assuming the JSON list has records we can process.
            
            # Mocking transformation for robustness if raw JSON structure needs generic parsing
            if 'date' in df.columns:
                df['date'] = pd.to_datetime(df['date'])
                df['month'] = df['date'].dt.month
                df['day_of_year'] = df['date'].dt.dayofyear
            
            # Create dummy training data if file is empty/invalid for demo
            if len(df) < 10:
                print("[WeatherForecaster] Insufficient real data, generating synthetic training data...")
                df = self._generate_synthetic_weather_data()

            X = df[self.feature_columns]
            y = df[['temperature', 'humidity', 'rainfall']]
            
            # Split
            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
            
            # Scale
            self.scaler = StandardScaler()
            X_train_scaled = self.scaler.fit_transform(X_train)
            X_test_scaled = self.scaler.transform(X_test)
            
            # Train (Multi-output regressor)
            print("[WeatherForecaster] Training Random Forest...")
            self.model = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
            self.model.fit(X_train_scaled, y_train)
            
            # Evaluate
            y_pred = self.model.predict(X_test_scaled)
            mae = mean_absolute_error(y_test, y_pred)
            
            self.is_trained = True
            
            metrics = {
                "status": "success",
                "mae": float(mae),
                "samples": len(df)
            }
            print(f"[WeatherForecaster] Training complete. MAE: {mae:.2f}")
            self.save()
            return metrics
            
        except Exception as e:
            print(f"[WeatherForecaster] Error training: {e}")
            return {"status": "error", "message": str(e)}

    def predict(self, date: datetime, province_id: int, region_id: int, current_weather: Dict) -> Dict:
        """
        Predict weather for the given date.
        
        Args:
            date: Date to predict for
            province_id: ID of province
            region_id: ID of region
            current_weather: Dict with 'med_temp', 'med_humid', 'med_rain' of previous day/current baseline
        """
        if not self.is_trained:
            return self._heuristic_predict(date, region_id)

        features = np.array([[
            date.month,
            date.timetuple().tm_yday,
            province_id,
            region_id,
            current_weather.get('temp', 30),
            current_weather.get('humid', 75),
            current_weather.get('rain', 0)
        ]])
        
        features_scaled = self.scaler.transform(features)
        pred = self.model.predict(features_scaled)[0]
        
        return {
            "temperature": round(pred[0], 1),
            "humidity": round(pred[1], 1),
            "rainfall": round(max(0, pred[2]), 1),
            "date": date.strftime("%Y-%m-%d")
        }

    def _generate_synthetic_weather_data(self, n_samples=1000):
        """Generate synthetic weather data if real data is missing."""
        data = []
        for _ in range(n_samples):
            month = np.random.randint(1, 13)
            # Simple seasonality
            base_temp = 25 + 5 * np.sin((month - 1) * np.pi / 6)
            temp = base_temp + np.random.normal(0, 3)
            humid = 80 + np.random.normal(0, 10)
            rain = max(0, (200 if 5 <= month <= 10 else 20) + np.random.normal(0, 50))
            
            data.append({
                'month': month,
                'day_of_year': np.random.randint(1, 366),
                'province_id': np.random.randint(0, 64),
                'region_id': np.random.randint(0, 4),
                'prev_temp': temp,
                'prev_humid': humid,
                'prev_rain': rain,
                'temperature': temp + np.random.normal(0, 1), # Target next day
                'humidity': humid + np.random.normal(0, 2),
                'rainfall': rain * np.random.uniform(0.5, 1.5)
            })
        return pd.DataFrame(data)

    def _heuristic_predict(self, date: datetime, region_id: int) -> Dict:
        """Fallback prediction if model not trained."""
        month = date.month
        base_temp = 25 + 5 * np.sin((month - 1) * np.pi / 6)
        if region_id == 0: # North - colder winter
            base_temp -= 5 if month in [12, 1, 2] else 0
        
        is_rainy_season = 5 <= month <= 10
        rainfall = np.random.uniform(10, 50) if is_rainy_season else np.random.uniform(0, 5)
        
        return {
            "temperature": round(base_temp, 1),
            "humidity": 80,
            "rainfall": round(rainfall, 1),
            "date": date.strftime("%Y-%m-%d"),
            "note": "Heuristic prediction (Model not trained)"
        }

    def save(self):
        joblib.dump({
            'model': self.model,
            'scaler': self.scaler,
            'is_trained': self.is_trained
        }, self.models_dir / "weather_forecaster.pkl")

    def load(self):
        path = self.models_dir / "weather_forecaster.pkl"
        if path.exists():
            data = joblib.load(path)
            self.model = data['model']
            self.scaler = data['scaler']
            self.is_trained = data['is_trained']
            return True
        return False
