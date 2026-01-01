"""Model Retraining Service"""
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from models.alert_scorer import AlertScoringModel
from services.data_collector import DataCollector
from config import MIN_SAMPLES_FOR_RETRAIN


class ModelRetrainer:
    """
    Handles model retraining when sufficient data is collected
    
    Monitors data collection and triggers retraining when:
    - Minimum sample threshold is reached
    - Performance degradation is detected
    - Scheduled retraining time (weekly/monthly)
    """
    
    def __init__(self, data_collector: DataCollector):
        self.data_collector = data_collector
        print("[ModelRetrainer] Initialized")
    
    def retrain_scorer(
        self,
        min_samples: int = MIN_SAMPLES_FOR_RETRAIN,
        test_size: float = 0.2
    ) -> dict:
        """
        Retrain alert scoring model
        
        Args:
            min_samples: Minimum samples required for retraining
            test_size: Fraction of data to use for testing
            
        Returns:
            Dict with retraining results and metrics
        """
        print(f"[ModelRetrainer] Starting scorer retraining (min_samples={min_samples})...")
        
        # Fetch training data
        training_data = self.data_collector.get_training_data(
            min_samples=min_samples,
            days=30
        )
        
        if len(training_data) < min_samples:
            return {
                'success': False,
                'reason': 'insufficient_data',
                'samples_collected': len(training_data),
                'samples_required': min_samples
            }
        
        print(f"[ModelRetrainer] Found {len(training_data)} training samples")
        
        # Prepare data
        X = []
        y = []
        
        for sample in training_data:
            features = sample['features']
            # Convert dict to array in correct order
            feature_array = [
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
            ]
            X.append(feature_array)
            y.append(sample['actual_score'])
        
        X = np.array(X)
        y = np.array(y)
        
        # Split train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42
        )
        
        # Create new model (no cold start)
        scorer = AlertScoringModel(cold_start=False)
        
        # Train
        X_train_scaled = scorer.scaler.fit_transform(X_train)
        scorer.model.fit(X_train_scaled, y_train)
        scorer.is_trained = True
        
        # Evaluate
        X_test_scaled = scorer.scaler.transform(X_test)
        y_pred = scorer.model.predict(X_test_scaled)
        
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        print(f"[ModelRetrainer] Training complete:")
        print(f"  - MAE: {mae:.2f}")
        print(f"  - R² Score: {r2:.3f}")
        print(f"  - Train samples: {len(X_train)}")
        print(f"  - Test samples: {len(X_test)}")
        
        # Save new model
        scorer.save()
        
        # Log performance
        self.data_collector.log_model_performance(
            model_name='scorer',
            metric_name='mae',
            metric_value=mae,
            sample_size=len(X_test)
        )
        self.data_collector.log_model_performance(
            model_name='scorer',
            metric_name='r2',
            metric_value=r2,
            sample_size=len(X_test)
        )
        
        return {
            'success': True,
            'samples_used': len(training_data),
            'train_size': len(X_train),
            'test_size': len(X_test),
            'metrics': {
                'mae': float(mae),
                'r2_score': float(r2)
            },
            'feature_importance': scorer.get_feature_importance()
        }
    
    def check_retraining_needed(self, days_since_last: int = 7) -> bool:
        """
        Check if retraining is needed
        
        Args:
            days_since_last: Days since last retraining
            
        Returns:
            True if retraining is recommended
        """
        # Check if enough data collected
        training_data = self.data_collector.get_training_data(
            min_samples=MIN_SAMPLES_FOR_RETRAIN,
            days=30
        )
        
        if len(training_data) >= MIN_SAMPLES_FOR_RETRAIN:
            return True
        
        # Add more sophisticated checks here:
        # - Performance degradation detection
        # - Time-based scheduling
        # - Data drift detection
        
        return False
    
    def get_retraining_status(self) -> dict:
        """Get status of retraining requirements"""
        training_data = self.data_collector.get_training_data(
            min_samples=0,
            days=30
        )
        
        return {
            'samples_collected': len(training_data),
            'samples_required': MIN_SAMPLES_FOR_RETRAIN,
            'ready_for_retraining': len(training_data) >= MIN_SAMPLES_FOR_RETRAIN,
            'progress_percentage': min(100, (len(training_data) / MIN_SAMPLES_FOR_RETRAIN) * 100)
        }


import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from models.alert_scorer import AlertScoringModel
from services.data_collector import DataCollector
from config import MIN_SAMPLES_FOR_RETRAIN


class ModelRetrainer:
    """
    Handles model retraining when sufficient data is collected
    
    Monitors data collection and triggers retraining when:
    - Minimum sample threshold is reached
    - Performance degradation is detected
    - Scheduled retraining time (weekly/monthly)
    """
    
    def __init__(self, data_collector: DataCollector):
        self.data_collector = data_collector
        print("[ModelRetrainer] Initialized")
    
    def retrain_scorer(
        self,
        min_samples: int = MIN_SAMPLES_FOR_RETRAIN,
        test_size: float = 0.2
    ) -> dict:
        """
        Retrain alert scoring model
        
        Args:
            min_samples: Minimum samples required for retraining
            test_size: Fraction of data to use for testing
            
        Returns:
            Dict with retraining results and metrics
        """
        print(f"[ModelRetrainer] Starting scorer retraining (min_samples={min_samples})...")
        
        # Fetch training data
        training_data = self.data_collector.get_training_data(
            min_samples=min_samples,
            days=30
        )
        
        if len(training_data) < min_samples:
            return {
                'success': False,
                'reason': 'insufficient_data',
                'samples_collected': len(training_data),
                'samples_required': min_samples
            }
        
        print(f"[ModelRetrainer] Found {len(training_data)} training samples")
        
        # Prepare data
        X = []
        y = []
        
        for sample in training_data:
            features = sample['features']
            # Convert dict to array in correct order
            feature_array = [
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
            ]
            X.append(feature_array)
            y.append(sample['actual_score'])
        
        X = np.array(X)
        y = np.array(y)
        
        # Split train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=test_size, random_state=42
        )
        
        # Create new model (no cold start)
        scorer = AlertScoringModel(cold_start=False)
        
        # Train
        X_train_scaled = scorer.scaler.fit_transform(X_train)
        scorer.model.fit(X_train_scaled, y_train)
        scorer.is_trained = True
        
        # Evaluate
        X_test_scaled = scorer.scaler.transform(X_test)
        y_pred = scorer.model.predict(X_test_scaled)
        
        mae = mean_absolute_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        
        print(f"[ModelRetrainer] Training complete:")
        print(f"  - MAE: {mae:.2f}")
        print(f"  - R² Score: {r2:.3f}")
        print(f"  - Train samples: {len(X_train)}")
        print(f"  - Test samples: {len(X_test)}")
        
        # Save new model
        scorer.save()
        
        # Log performance
        self.data_collector.log_model_performance(
            model_name='scorer',
            metric_name='mae',
            metric_value=mae,
            sample_size=len(X_test)
        )
        self.data_collector.log_model_performance(
            model_name='scorer',
            metric_name='r2',
            metric_value=r2,
            sample_size=len(X_test)
        )
        
        return {
            'success': True,
            'samples_used': len(training_data),
            'train_size': len(X_train),
            'test_size': len(X_test),
            'metrics': {
                'mae': float(mae),
                'r2_score': float(r2)
            },
            'feature_importance': scorer.get_feature_importance()
        }
    
    def check_retraining_needed(self, days_since_last: int = 7) -> bool:
        """
        Check if retraining is needed
        
        Args:
            days_since_last: Days since last retraining
            
        Returns:
            True if retraining is recommended
        """
        # Check if enough data collected
        training_data = self.data_collector.get_training_data(
            min_samples=MIN_SAMPLES_FOR_RETRAIN,
            days=30
        )
        
        if len(training_data) >= MIN_SAMPLES_FOR_RETRAIN:
            return True
        
        # Add more sophisticated checks here:
        # - Performance degradation detection
        # - Time-based scheduling
        # - Data drift detection
        
        return False
    
    def get_retraining_status(self) -> dict:
        """Get status of retraining requirements"""
        training_data = self.data_collector.get_training_data(
            min_samples=0,
            days=30
        )
        
        return {
            'samples_collected': len(training_data),
            'samples_required': MIN_SAMPLES_FOR_RETRAIN,
            'ready_for_retraining': len(training_data) >= MIN_SAMPLES_FOR_RETRAIN,
            'progress_percentage': min(100, (len(training_data) / MIN_SAMPLES_FOR_RETRAIN) * 100)
        }



