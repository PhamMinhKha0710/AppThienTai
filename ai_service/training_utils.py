"""
Training Utilities for Alert Scoring Model

Provides utilities for:
- Feature extraction
- Data preprocessing
- Ground truth score calculation
- Model training and evaluation
"""
import numpy as np
import pandas as pd
from datetime import datetime
from typing import List, Dict, Tuple
import math
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import joblib


class TrainingDataProcessor:
    """Process and prepare training data"""
    
    @staticmethod
    def extract_features(alert_data: dict, user_context: dict = None) -> dict:
        """
        Extract 15 features from alert data
        
        Args:
            alert_data: Alert dict with keys: severity, alert_type, content, etc.
            user_context: Optional user context dict
            
        Returns:
            Dict with 15 feature values
        """
        # Severity score mapping
        severity_map = {
            'low': 1,
            'medium': 2,
            'high': 3,
            'critical': 4
        }
        
        # Alert type score mapping
        type_map = {
            'general': 1,
            'weather': 2,
            'evacuation': 3,
            'disaster': 4
        }
        
        # Time calculations
        created_at_str = alert_data.get('created_at', datetime.now().isoformat())
        try:
            created_at = datetime.fromisoformat(created_at_str.replace('Z', '+00:00'))
        except:
            created_at = datetime.now()
        
        now = datetime.now()
        hours_since_created = (now - created_at.replace(tzinfo=None)).total_seconds() / 3600
        
        # Distance calculation
        distance_km = 0.0
        if alert_data.get('lat') and alert_data.get('lng'):
            if user_context and user_context.get('lat') and user_context.get('lng'):
                distance_km = TrainingDataProcessor._haversine_distance(
                    alert_data['lat'], alert_data['lng'],
                    user_context['lat'], user_context['lng']
                )
            else:
                # Default distance if no user location
                distance_km = 25.0  # Average distance
        
        # Target audience match
        user_role = user_context.get('role', 'victim') if user_context else 'victim'
        target_audience_match = 1.0 if user_role in ['victim', 'all'] else 0.5
        
        # Extract features
        features = {
            # Alert properties
            'severity_score': severity_map.get(alert_data.get('severity', 'low'), 1),
            'alert_type_score': type_map.get(alert_data.get('alert_type', 'general'), 1),
            'hours_since_created': max(0, hours_since_created),
            'distance_km': distance_km,
            'target_audience_match': target_audience_match,
            
            # Contextual features
            'user_previous_interactions': user_context.get('previous_interactions', 0) if user_context else 0,
            'time_of_day': now.hour,
            'day_of_week': now.weekday(),
            'weather_severity': alert_data.get('weather_severity', 0),
            
            # Alert characteristics
            'content_length': len(alert_data.get('content', '')),
            'has_images': 1.0 if alert_data.get('has_images', False) else 0.0,
            'has_safety_guide': 1.0 if alert_data.get('has_safety_guide', False) else 0.0,
            
            # Social signals
            'similar_alerts_count': alert_data.get('similar_alerts_count', 0),
            'alert_engagement_rate': alert_data.get('engagement_rate', 0.5),
            'source_reliability': alert_data.get('source_reliability', alert_data.get('confidence', 1.0)),
        }
        
        return features
    
    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        R = 6371.0  # Earth radius in kilometers
        
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        distance = R * c
        return distance
    
    @staticmethod
    def calculate_ground_truth_score(features: dict) -> float:
        """
        Calculate ground truth score using rule-based formula
        
        Formula: 0.35*Severity + 0.20*Type + 0.15*TimeDecay + 0.20*Distance + 0.10*Audience
        
        Args:
            features: Feature dict
            
        Returns:
            Ground truth score (0-100)
        """
        # Severity score (1-4 -> 25-100)
        severity_score = 25 * features['severity_score']
        
        # Type score (1-4 -> 30-100)
        type_score = 30 + 17.5 * features['alert_type_score']
        
        # Time decay score (exponential decay)
        hours = features['hours_since_created']
        time_decay_score = 100 * math.exp(-0.05 * hours)
        
        # Distance score (inverse distance weighting)
        distance = features['distance_km']
        if distance >= 50:
            distance_score = 0
        else:
            ratio = 1 - (distance / 50)
            distance_score = 100 * ratio * ratio
        
        # Audience score
        audience_match = features['target_audience_match']
        audience_score = 100 if audience_match >= 0.8 else 50
        
        # Weighted sum
        final_score = (
            0.35 * severity_score +
            0.20 * type_score +
            0.15 * time_decay_score +
            0.20 * distance_score +
            0.10 * audience_score
        )
        
        return float(np.clip(final_score, 0, 100))
    
    @staticmethod
    def prepare_training_data(alerts: List[Dict], min_confidence: float = 0.8) -> Tuple[np.ndarray, np.ndarray]:
        """
        Prepare training data from alerts
        
        Args:
            alerts: List of alert dicts
            min_confidence: Minimum confidence score to include
            
        Returns:
            Tuple of (X, y) where X is feature matrix and y is target scores
        """
        X = []
        y = []
        
        for alert in alerts:
            # Filter by confidence
            confidence = alert.get('confidence', alert.get('source_reliability', 1.0))
            if confidence < min_confidence:
                continue
            
            # Extract features
            features = TrainingDataProcessor.extract_features(alert)
            
            # Calculate ground truth score
            ground_truth = TrainingDataProcessor.calculate_ground_truth_score(features)
            
            # Convert features to array (in correct order)
            feature_array = [
                features['severity_score'],
                features['alert_type_score'],
                features['hours_since_created'],
                features['distance_km'],
                features['target_audience_match'],
                features['user_previous_interactions'],
                features['time_of_day'],
                features['day_of_week'],
                features['weather_severity'],
                features['content_length'],
                features['has_images'],
                features['has_safety_guide'],
                features['similar_alerts_count'],
                features['alert_engagement_rate'],
                features['source_reliability'],
            ]
            
            X.append(feature_array)
            y.append(ground_truth)
        
        return np.array(X), np.array(y)


class ModelTrainer:
    """Train Alert Scoring Model"""
    
    def __init__(self, n_estimators: int = 100, max_depth: int = 10, random_state: int = 42):
        """
        Initialize trainer
        
        Args:
            n_estimators: Number of trees in Random Forest
            max_depth: Maximum depth of trees
            random_state: Random seed
        """
        self.model = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=max_depth,
            random_state=random_state,
            n_jobs=-1
        )
        self.scaler = StandardScaler()
        self.is_trained = False
    
    def train(self, X: np.ndarray, y: np.ndarray, test_size: float = 0.2) -> Dict:
        """
        Train model on data
        
        Args:
            X: Feature matrix
            y: Target scores
            test_size: Fraction of data for testing
            
        Returns:
            Dict with training metrics
        """
        print(f"Training on {len(X)} samples...")
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Train model
        print("Training Random Forest...")
        self.model.fit(X_train_scaled, y_train)
        self.is_trained = True
        
        # Evaluate
        y_pred_train = self.model.predict(X_train_scaled)
        y_pred_test = self.model.predict(X_test_scaled)
        
        # Calculate metrics
        train_mae = mean_absolute_error(y_train, y_pred_train)
        test_mae = mean_absolute_error(y_test, y_pred_test)
        train_rmse = np.sqrt(mean_squared_error(y_train, y_pred_train))
        test_rmse = np.sqrt(mean_squared_error(y_test, y_pred_test))
        train_r2 = r2_score(y_train, y_pred_train)
        test_r2 = r2_score(y_test, y_pred_test)
        
        # Cross-validation
        cv_scores = cross_val_score(
            self.model, X_train_scaled, y_train,
            cv=5, scoring='neg_mean_absolute_error', n_jobs=-1
        )
        cv_mae = -cv_scores.mean()
        cv_std = cv_scores.std()
        
        metrics = {
            'training_samples': len(X_train),
            'test_samples': len(X_test),
            'train_mae': float(train_mae),
            'test_mae': float(test_mae),
            'train_rmse': float(train_rmse),
            'test_rmse': float(test_rmse),
            'train_r2': float(train_r2),
            'test_r2': float(test_r2),
            'cv_mae_mean': float(cv_mae),
            'cv_mae_std': float(cv_std),
            'feature_importance': self.get_feature_importance()
        }
        
        print(f"\nTraining Results:")
        print(f"  Train MAE: {train_mae:.2f}")
        print(f"  Test MAE: {test_mae:.2f}")
        print(f"  Test R²: {test_r2:.3f}")
        print(f"  CV MAE: {cv_mae:.2f} ± {cv_std:.2f}")
        
        return metrics
    
    def get_feature_importance(self) -> Dict[str, float]:
        """Get feature importance from trained model"""
        if not self.is_trained:
            return {}
        
        feature_names = [
            'severity_score', 'alert_type_score', 'hours_since_created',
            'distance_km', 'target_audience_match', 'user_previous_interactions',
            'time_of_day', 'day_of_week', 'weather_severity',
            'content_length', 'has_images', 'has_safety_guide',
            'similar_alerts_count', 'alert_engagement_rate', 'source_reliability'
        ]
        
        importances = self.model.feature_importances_
        
        return {
            name: float(importance)
            for name, importance in zip(feature_names, importances)
        }
    
    def save_model(self, model_path: str, scaler_path: str):
        """Save model and scaler to disk"""
        if not self.is_trained:
            raise RuntimeError("Model not trained yet")
        
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'is_trained': True
        }
        
        joblib.dump(model_data, model_path)
        print(f"Model saved to {model_path}")
    
    def load_model(self, model_path: str):
        """Load model and scaler from disk"""
        model_data = joblib.load(model_path)
        self.model = model_data['model']
        self.scaler = model_data['scaler']
        self.is_trained = model_data['is_trained']
        print(f"Model loaded from {model_path}")


def generate_synthetic_data(n_samples: int = 1000) -> List[Dict]:
    """
    Generate synthetic training data for cold start
    
    Args:
        n_samples: Number of samples to generate
        
    Returns:
        List of synthetic alert dicts
    """
    np.random.seed(42)
    synthetic_alerts = []
    
    severities = ['low', 'medium', 'high', 'critical']
    alert_types = ['general', 'weather', 'evacuation', 'disaster']
    provinces = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Quảng Bình', 'Thừa Thiên Huế']
    
    for i in range(n_samples):
        alert = {
            'id': f'SYNTHETIC_{i}',
            'source': 'SYNTHETIC',
            'source_reliability': 0.8,
            'content': f"Synthetic alert {i}",
            'severity': np.random.choice(severities),
            'alert_type': np.random.choice(alert_types),
            'province': np.random.choice(provinces),
            'lat': 10.0 + np.random.uniform(-2, 2),
            'lng': 106.0 + np.random.uniform(-2, 2),
            'created_at': (datetime.now() - pd.Timedelta(hours=np.random.exponential(12))).isoformat(),
            'verified': True,
            'confidence': 0.8,
            'has_images': np.random.choice([True, False]),
            'has_safety_guide': np.random.choice([True, False]),
            'similar_alerts_count': np.random.poisson(3),
            'engagement_rate': np.random.beta(2, 2),
        }
        
        synthetic_alerts.append(alert)
    
    return synthetic_alerts










