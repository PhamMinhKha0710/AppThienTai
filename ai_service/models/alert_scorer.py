"""Alert Scoring Model using Random Forest with Cold Start Strategy"""
import numpy as np
import joblib
from pathlib import Path
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from datetime import datetime, timedelta
import math

import sys
sys.path.append(str(Path(__file__).parent.parent))
from config import (
    RF_N_ESTIMATORS, RF_MAX_DEPTH, RF_RANDOM_STATE,
    MODELS_DIR, SYNTHETIC_SAMPLES, N_FEATURES
)


class AlertScoringModel:
    """
    ML-based Alert Scoring Model with Cold Start Bootstrap
    
    Uses Random Forest to predict alert priority scores (0-100) based on:
    - Alert properties (severity, type, age, location)
    - User context (location, history, time)
    - Alert characteristics (content, images, guide)
    
    Cold start strategy: Generate synthetic data from rule-based formulas
    """
    
    def __init__(self, cold_start=True):
        self.model = RandomForestRegressor(
            n_estimators=RF_N_ESTIMATORS,
            max_depth=RF_MAX_DEPTH,
            random_state=RF_RANDOM_STATE,
            n_jobs=-1
        )
        self.scaler = StandardScaler()
        self.cold_start = cold_start
        self.is_trained = False
        
        # Try to load existing model
        if not self._load_model():
            if cold_start:
                print("[AlertScorer] No existing model found. Bootstrapping from rules...")
                self._bootstrap_from_rules()
    
    def _bootstrap_from_rules(self):
        """Generate synthetic training data from rule-based system"""
        print(f"[AlertScorer] Generating {SYNTHETIC_SAMPLES} synthetic samples...")
        
        X_synthetic = self._generate_synthetic_features(n_samples=SYNTHETIC_SAMPLES)
        y_synthetic = self._apply_rule_based_scoring(X_synthetic)
        
        # Train initial model
        X_scaled = self.scaler.fit_transform(X_synthetic)
        self.model.fit(X_scaled, y_synthetic)
        self.is_trained = True
        
        print(f"[AlertScorer] Bootstrap complete. Model trained on {SYNTHETIC_SAMPLES} samples.")
        
        # Save model
        self.save()
    
    def _generate_synthetic_features(self, n_samples: int) -> np.ndarray:
        """Generate synthetic feature vectors"""
        np.random.seed(42)
        
        features = np.zeros((n_samples, N_FEATURES))
        
        for i in range(n_samples):
            # Alert properties
            features[i, 0] = np.random.choice([1, 2, 3, 4])  # severity_score (low to critical)
            features[i, 1] = np.random.choice([1, 2, 3, 4])  # alert_type_score
            features[i, 2] = np.random.exponential(12)  # hours_since_created
            features[i, 3] = np.random.exponential(20)  # distance_km
            features[i, 4] = np.random.choice([0, 1])  # target_audience_match
            
            # Contextual features
            features[i, 5] = np.random.poisson(5)  # user_previous_interactions
            features[i, 6] = np.random.randint(0, 24)  # time_of_day
            features[i, 7] = np.random.randint(0, 7)  # day_of_week
            features[i, 8] = np.random.choice([0, 1, 2, 3, 4])  # weather_severity
            
            # Alert characteristics
            features[i, 9] = np.random.randint(50, 500)  # content_length
            features[i, 10] = np.random.choice([0, 1])  # has_images
            features[i, 11] = np.random.choice([0, 1])  # has_safety_guide
            
            # Social signals
            features[i, 12] = np.random.poisson(3)  # similar_alerts_count
            features[i, 13] = np.random.beta(2, 2)  # alert_engagement_rate
            features[i, 14] = np.random.uniform(0.5, 1.0)  # source_reliability
        
        return features
    
    def _apply_rule_based_scoring(self, X: np.ndarray) -> np.ndarray:
        """
        Apply rule-based scoring formula (mimics AlertScoringService in Dart)
        
        Score = 0.35*Severity + 0.20*Type + 0.15*TimeDecay + 0.20*Distance + 0.10*Audience
        """
        scores = np.zeros(len(X))
        
        for i, features in enumerate(X):
            # Severity score (0-4 -> 25-100)
            severity_score = 25 * features[0]  # 1->25, 2->50, 3->75, 4->100
            
            # Type score (0-4 -> 30-100)
            type_score = 30 + 17.5 * features[1]
            
            # Time decay score (exponential decay)
            hours = features[2]
            time_decay_score = 100 * math.exp(-0.05 * hours)
            
            # Distance score (inverse distance weighting)
            distance = features[3]
            if distance >= 50:
                distance_score = 0
            else:
                ratio = 1 - (distance / 50)
                distance_score = 100 * ratio * ratio
            
            # Audience score
            audience_match = features[4]
            audience_score = 100 if audience_match else 50
            
            # Weighted sum
            final_score = (
                0.35 * severity_score +
                0.20 * type_score +
                0.15 * time_decay_score +
                0.20 * distance_score +
                0.10 * audience_score
            )
            
            scores[i] = np.clip(final_score, 0, 100)
        
        return scores
    
    def predict(self, features: dict) -> float:
        """
        Predict priority score for an alert
        
        Args:
            features: Dict containing all feature values
            
        Returns:
            Priority score (0-100)
        """
        if not self.is_trained:
            raise RuntimeError("Model not trained. Call _bootstrap_from_rules() first.")
        
        X = self._features_to_array(features)
        X_scaled = self.scaler.transform(X.reshape(1, -1))
        score = self.model.predict(X_scaled)[0]
        
        return float(np.clip(score, 0, 100))
    
    def predict_with_confidence(self, features: dict) -> tuple[float, float]:
        """
        Predict score with confidence interval
        
        Returns:
            (score, confidence): Tuple of score and confidence (std of tree predictions)
        """
        X = self._features_to_array(features)
        X_scaled = self.scaler.transform(X.reshape(1, -1))
        
        # Get predictions from all trees
        tree_predictions = np.array([
            tree.predict(X_scaled)[0] 
            for tree in self.model.estimators_
        ])
        
        score = np.mean(tree_predictions)
        confidence = 1.0 - (np.std(tree_predictions) / 100.0)  # Normalize to 0-1
        
        return float(np.clip(score, 0, 100)), float(np.clip(confidence, 0, 1))
    
    def _features_to_array(self, features: dict) -> np.ndarray:
        """Convert feature dict to numpy array in correct order"""
        return np.array([
            features.get('severity_score', 0),
            features.get('alert_type_score', 0),
            features.get('hours_since_created', 0),
            features.get('distance_km', 0),
            features.get('target_audience_match', 0),
            features.get('user_previous_interactions', 0),
            features.get('time_of_day', 0),
            features.get('day_of_week', 0),
            features.get('weather_severity', 0),
            features.get('content_length', 0),
            features.get('has_images', 0),
            features.get('has_safety_guide', 0),
            features.get('similar_alerts_count', 0),
            features.get('alert_engagement_rate', 0),
            features.get('source_reliability', 1.0),
        ])
    
    def update_online(self, features: dict, actual_score: float):
        """
        Online learning update (for future batch retraining)
        
        Note: Random Forest doesn't support true online learning,
        so we just log the data for batch retraining later.
        """
        # This would be implemented by DataCollector
        pass
    
    def save(self, path: Path = None):
        """Save model and scaler to disk"""
        if path is None:
            path = MODELS_DIR / "alert_scorer.pkl"
        
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'is_trained': self.is_trained
        }
        
        joblib.dump(model_data, path)
        print(f"[AlertScorer] Model saved to {path}")
    
    def _load_model(self, path: Path = None) -> bool:
        """Load model and scaler from disk"""
        if path is None:
            path = MODELS_DIR / "alert_scorer.pkl"
        
        if not path.exists():
            return False
        
        try:
            model_data = joblib.load(path)
            self.model = model_data['model']
            self.scaler = model_data['scaler']
            self.is_trained = model_data['is_trained']
            print(f"[AlertScorer] Model loaded from {path}")
            return True
        except Exception as e:
            print(f"[AlertScorer] Error loading model: {e}")
            return False
    
    def get_feature_importance(self) -> dict:
        """Get feature importance from Random Forest"""
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


import numpy as np
import joblib
from pathlib import Path
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from datetime import datetime, timedelta
import math

import sys
sys.path.append(str(Path(__file__).parent.parent))
from config import (
    RF_N_ESTIMATORS, RF_MAX_DEPTH, RF_RANDOM_STATE,
    MODELS_DIR, SYNTHETIC_SAMPLES, N_FEATURES
)


class AlertScoringModel:
    """
    ML-based Alert Scoring Model with Cold Start Bootstrap
    
    Uses Random Forest to predict alert priority scores (0-100) based on:
    - Alert properties (severity, type, age, location)
    - User context (location, history, time)
    - Alert characteristics (content, images, guide)
    
    Cold start strategy: Generate synthetic data from rule-based formulas
    """
    
    def __init__(self, cold_start=True):
        self.model = RandomForestRegressor(
            n_estimators=RF_N_ESTIMATORS,
            max_depth=RF_MAX_DEPTH,
            random_state=RF_RANDOM_STATE,
            n_jobs=-1
        )
        self.scaler = StandardScaler()
        self.cold_start = cold_start
        self.is_trained = False
        
        # Try to load existing model
        if not self._load_model():
            if cold_start:
                print("[AlertScorer] No existing model found. Bootstrapping from rules...")
                self._bootstrap_from_rules()
    
    def _bootstrap_from_rules(self):
        """Generate synthetic training data from rule-based system"""
        print(f"[AlertScorer] Generating {SYNTHETIC_SAMPLES} synthetic samples...")
        
        X_synthetic = self._generate_synthetic_features(n_samples=SYNTHETIC_SAMPLES)
        y_synthetic = self._apply_rule_based_scoring(X_synthetic)
        
        # Train initial model
        X_scaled = self.scaler.fit_transform(X_synthetic)
        self.model.fit(X_scaled, y_synthetic)
        self.is_trained = True
        
        print(f"[AlertScorer] Bootstrap complete. Model trained on {SYNTHETIC_SAMPLES} samples.")
        
        # Save model
        self.save()
    
    def _generate_synthetic_features(self, n_samples: int) -> np.ndarray:
        """Generate synthetic feature vectors"""
        np.random.seed(42)
        
        features = np.zeros((n_samples, N_FEATURES))
        
        for i in range(n_samples):
            # Alert properties
            features[i, 0] = np.random.choice([1, 2, 3, 4])  # severity_score (low to critical)
            features[i, 1] = np.random.choice([1, 2, 3, 4])  # alert_type_score
            features[i, 2] = np.random.exponential(12)  # hours_since_created
            features[i, 3] = np.random.exponential(20)  # distance_km
            features[i, 4] = np.random.choice([0, 1])  # target_audience_match
            
            # Contextual features
            features[i, 5] = np.random.poisson(5)  # user_previous_interactions
            features[i, 6] = np.random.randint(0, 24)  # time_of_day
            features[i, 7] = np.random.randint(0, 7)  # day_of_week
            features[i, 8] = np.random.choice([0, 1, 2, 3, 4])  # weather_severity
            
            # Alert characteristics
            features[i, 9] = np.random.randint(50, 500)  # content_length
            features[i, 10] = np.random.choice([0, 1])  # has_images
            features[i, 11] = np.random.choice([0, 1])  # has_safety_guide
            
            # Social signals
            features[i, 12] = np.random.poisson(3)  # similar_alerts_count
            features[i, 13] = np.random.beta(2, 2)  # alert_engagement_rate
            features[i, 14] = np.random.uniform(0.5, 1.0)  # source_reliability
        
        return features
    
    def _apply_rule_based_scoring(self, X: np.ndarray) -> np.ndarray:
        """
        Apply rule-based scoring formula (mimics AlertScoringService in Dart)
        
        Score = 0.35*Severity + 0.20*Type + 0.15*TimeDecay + 0.20*Distance + 0.10*Audience
        """
        scores = np.zeros(len(X))
        
        for i, features in enumerate(X):
            # Severity score (0-4 -> 25-100)
            severity_score = 25 * features[0]  # 1->25, 2->50, 3->75, 4->100
            
            # Type score (0-4 -> 30-100)
            type_score = 30 + 17.5 * features[1]
            
            # Time decay score (exponential decay)
            hours = features[2]
            time_decay_score = 100 * math.exp(-0.05 * hours)
            
            # Distance score (inverse distance weighting)
            distance = features[3]
            if distance >= 50:
                distance_score = 0
            else:
                ratio = 1 - (distance / 50)
                distance_score = 100 * ratio * ratio
            
            # Audience score
            audience_match = features[4]
            audience_score = 100 if audience_match else 50
            
            # Weighted sum
            final_score = (
                0.35 * severity_score +
                0.20 * type_score +
                0.15 * time_decay_score +
                0.20 * distance_score +
                0.10 * audience_score
            )
            
            scores[i] = np.clip(final_score, 0, 100)
        
        return scores
    
    def predict(self, features: dict) -> float:
        """
        Predict priority score for an alert
        
        Args:
            features: Dict containing all feature values
            
        Returns:
            Priority score (0-100)
        """
        if not self.is_trained:
            raise RuntimeError("Model not trained. Call _bootstrap_from_rules() first.")
        
        X = self._features_to_array(features)
        X_scaled = self.scaler.transform(X.reshape(1, -1))
        score = self.model.predict(X_scaled)[0]
        
        return float(np.clip(score, 0, 100))
    
    def predict_with_confidence(self, features: dict) -> tuple[float, float]:
        """
        Predict score with confidence interval
        
        Returns:
            (score, confidence): Tuple of score and confidence (std of tree predictions)
        """
        X = self._features_to_array(features)
        X_scaled = self.scaler.transform(X.reshape(1, -1))
        
        # Get predictions from all trees
        tree_predictions = np.array([
            tree.predict(X_scaled)[0] 
            for tree in self.model.estimators_
        ])
        
        score = np.mean(tree_predictions)
        confidence = 1.0 - (np.std(tree_predictions) / 100.0)  # Normalize to 0-1
        
        return float(np.clip(score, 0, 100)), float(np.clip(confidence, 0, 1))
    
    def _features_to_array(self, features: dict) -> np.ndarray:
        """Convert feature dict to numpy array in correct order"""
        return np.array([
            features.get('severity_score', 0),
            features.get('alert_type_score', 0),
            features.get('hours_since_created', 0),
            features.get('distance_km', 0),
            features.get('target_audience_match', 0),
            features.get('user_previous_interactions', 0),
            features.get('time_of_day', 0),
            features.get('day_of_week', 0),
            features.get('weather_severity', 0),
            features.get('content_length', 0),
            features.get('has_images', 0),
            features.get('has_safety_guide', 0),
            features.get('similar_alerts_count', 0),
            features.get('alert_engagement_rate', 0),
            features.get('source_reliability', 1.0),
        ])
    
    def update_online(self, features: dict, actual_score: float):
        """
        Online learning update (for future batch retraining)
        
        Note: Random Forest doesn't support true online learning,
        so we just log the data for batch retraining later.
        """
        # This would be implemented by DataCollector
        pass
    
    def save(self, path: Path = None):
        """Save model and scaler to disk"""
        if path is None:
            path = MODELS_DIR / "alert_scorer.pkl"
        
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'is_trained': self.is_trained
        }
        
        joblib.dump(model_data, path)
        print(f"[AlertScorer] Model saved to {path}")
    
    def _load_model(self, path: Path = None) -> bool:
        """Load model and scaler from disk"""
        if path is None:
            path = MODELS_DIR / "alert_scorer.pkl"
        
        if not path.exists():
            return False
        
        try:
            model_data = joblib.load(path)
            self.model = model_data['model']
            self.scaler = model_data['scaler']
            self.is_trained = model_data['is_trained']
            print(f"[AlertScorer] Model loaded from {path}")
            return True
        except Exception as e:
            print(f"[AlertScorer] Error loading model: {e}")
            return False
    
    def get_feature_importance(self) -> dict:
        """Get feature importance from Random Forest"""
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



