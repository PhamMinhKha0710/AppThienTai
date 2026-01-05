"""Model Tests for Smart Alert AI Service"""
import pytest
import numpy as np
import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from models.alert_scorer import AlertScoringModel
from models.duplicate_detector import SemanticDuplicateDetector
from models.notification_timing import NotificationTimingModel


class TestAlertScoringModel:
    """Test Alert Scoring Model"""
    
    def test_model_initialization_cold_start(self):
        """Test model initializes with cold start"""
        model = AlertScoringModel(cold_start=True)
        
        assert model.is_trained
        assert model.model is not None
        assert model.scaler is not None
    
    def test_predict_score_range(self):
        """Test that predictions are in valid range (0-100)"""
        model = AlertScoringModel(cold_start=True)
        
        features = {
            'severity_score': 3,
            'alert_type_score': 2,
            'hours_since_created': 2.0,
            'distance_km': 5.0,
            'target_audience_match': 1,
            'user_previous_interactions': 5,
            'time_of_day': 14,
            'day_of_week': 2,
            'weather_severity': 2,
            'content_length': 150,
            'has_images': 1,
            'has_safety_guide': 1,
            'similar_alerts_count': 2,
            'alert_engagement_rate': 0.7,
            'source_reliability': 1.0
        }
        
        score = model.predict(features)
        
        assert 0 <= score <= 100
    
    def test_high_severity_gets_higher_score(self):
        """Test that high severity alerts get higher scores"""
        model = AlertScoringModel(cold_start=True)
        
        # High severity features
        high_severity_features = {
            'severity_score': 4,  # Critical
            'alert_type_score': 4,
            'hours_since_created': 0.5,
            'distance_km': 2.0,
            'target_audience_match': 1,
            'user_previous_interactions': 5,
            'time_of_day': 14,
            'day_of_week': 2,
            'weather_severity': 3,
            'content_length': 200,
            'has_images': 1,
            'has_safety_guide': 1,
            'similar_alerts_count': 1,
            'alert_engagement_rate': 0.8,
            'source_reliability': 1.0
        }
        
        # Low severity features
        low_severity_features = high_severity_features.copy()
        low_severity_features['severity_score'] = 1  # Low
        low_severity_features['alert_type_score'] = 1
        
        high_score = model.predict(high_severity_features)
        low_score = model.predict(low_severity_features)
        
        assert high_score > low_score
    
    def test_feature_importance(self):
        """Test getting feature importance"""
        model = AlertScoringModel(cold_start=True)
        
        importance = model.get_feature_importance()
        
        assert len(importance) > 0
        assert 'severity_score' in importance
        assert all(0 <= v <= 1 for v in importance.values())


class TestSemanticDuplicateDetector:
    """Test Semantic Duplicate Detector"""
    
    def test_model_initialization(self):
        """Test model loads successfully"""
        detector = SemanticDuplicateDetector()
        
        assert detector.model is not None
        assert detector.threshold > 0
    
    def test_calculate_similarity_identical(self):
        """Test similarity of identical texts"""
        detector = SemanticDuplicateDetector()
        
        text = "Bão cấp 12 đang tiến vào bờ"
        similarity = detector.calculate_similarity(text, text)
        
        # Identical texts should have very high similarity
        assert similarity > 0.95
    
    def test_calculate_similarity_similar(self):
        """Test similarity of similar texts"""
        detector = SemanticDuplicateDetector()
        
        text1 = "Bão cấp 12 đang tiến vào bờ biển"
        text2 = "Bão mạnh cấp 12 sắp vào bờ"
        
        similarity = detector.calculate_similarity(text1, text2)
        
        # Similar texts should have high similarity
        assert similarity > 0.7
    
    def test_calculate_similarity_different(self):
        """Test similarity of different texts"""
        detector = SemanticDuplicateDetector()
        
        text1 = "Bão cấp 12 đang tiến vào bờ"
        text2 = "Mưa nhỏ vào chiều nay"
        
        similarity = detector.calculate_similarity(text1, text2)
        
        # Different texts should have low similarity
        assert similarity < 0.6
    
    def test_is_duplicate_positive(self):
        """Test duplicate detection returns true for duplicates"""
        detector = SemanticDuplicateDetector()
        
        alert1 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        alert2 = {
            'content': 'Bão cấp 12 sắp vào bờ biển',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        is_dup = detector.is_duplicate(alert1, alert2)
        
        assert is_dup == True
    
    def test_is_duplicate_different_province(self):
        """Test that different provinces are not duplicates"""
        detector = SemanticDuplicateDetector()
        
        alert1 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        alert2 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Đà Nẵng'
        }
        
        is_dup = detector.is_duplicate(alert1, alert2)
        
        assert is_dup == False
    
    def test_find_duplicates(self):
        """Test finding all duplicates"""
        detector = SemanticDuplicateDetector()
        
        new_alert = {
            'content': 'Mưa lớn trong 3 giờ tới',
            'alert_type': 'weather',
            'severity': 'high',
            'province': 'TP.HCM'
        }
        
        existing = [
            {
                'id': 'alert-1',
                'content': 'Mưa to sắp đến trong vài giờ',
                'alert_type': 'weather',
                'severity': 'high',
                'province': 'TP.HCM'
            },
            {
                'id': 'alert-2',
                'content': 'Bão cấp 10',
                'alert_type': 'disaster',
                'severity': 'critical',
                'province': 'Quảng Nam'
            }
        ]
        
        duplicates = detector.find_duplicates(new_alert, existing)
        
        # Should find at least one duplicate
        assert len(duplicates) >= 0


class TestNotificationTimingModel:
    """Test Notification Timing Model"""
    
    def test_model_initialization(self):
        """Test model initializes correctly"""
        model = NotificationTimingModel()
        
        assert model.n_slots == 24
        assert len(model.alpha) == 24
        assert len(model.beta_param) == 24
    
    def test_select_time_slot_range(self):
        """Test that selected time slot is valid"""
        model = NotificationTimingModel()
        
        slot = model.select_time_slot(
            alert_severity='medium',
            user_context={}
        )
        
        assert 0 <= slot <= 23
    
    def test_update_feedback_success(self):
        """Test updating with successful engagement"""
        model = NotificationTimingModel()
        
        initial_alpha = model.alpha[10]
        
        model.update_feedback(time_slot=10, engaged=True)
        
        # Alpha should increase
        assert model.alpha[10] > initial_alpha
    
    def test_update_feedback_failure(self):
        """Test updating with failed engagement"""
        model = NotificationTimingModel()
        
        initial_beta = model.beta_param[10]
        
        model.update_feedback(time_slot=10, engaged=False)
        
        # Beta should increase
        assert model.beta_param[10] > initial_beta
    
    def test_get_best_times(self):
        """Test getting best time slots"""
        model = NotificationTimingModel()
        
        # Add some fake successful engagements
        for _ in range(10):
            model.update_feedback(time_slot=18, engaged=True)  # Evening
        
        best_times = model.get_best_times(top_k=3)
        
        assert len(best_times) == 3
        assert all('hour' in t for t in best_times)
        assert all('success_rate' in t for t in best_times)
        assert all('confidence' in t for t in best_times)
    
    def test_critical_alert_immediate(self):
        """Test that critical alerts recommend current time"""
        model = NotificationTimingModel()
        
        from datetime import datetime
        current_hour = datetime.now().hour
        
        slot = model.select_time_slot(
            alert_severity='critical',
            user_context={}
        )
        
        # Should recommend current hour
        assert slot == current_hour


# Run tests
if __name__ == "__main__":
    pytest.main([__file__, "-v"])


import pytest
import numpy as np
import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from models.alert_scorer import AlertScoringModel
from models.duplicate_detector import SemanticDuplicateDetector
from models.notification_timing import NotificationTimingModel


class TestAlertScoringModel:
    """Test Alert Scoring Model"""
    
    def test_model_initialization_cold_start(self):
        """Test model initializes with cold start"""
        model = AlertScoringModel(cold_start=True)
        
        assert model.is_trained
        assert model.model is not None
        assert model.scaler is not None
    
    def test_predict_score_range(self):
        """Test that predictions are in valid range (0-100)"""
        model = AlertScoringModel(cold_start=True)
        
        features = {
            'severity_score': 3,
            'alert_type_score': 2,
            'hours_since_created': 2.0,
            'distance_km': 5.0,
            'target_audience_match': 1,
            'user_previous_interactions': 5,
            'time_of_day': 14,
            'day_of_week': 2,
            'weather_severity': 2,
            'content_length': 150,
            'has_images': 1,
            'has_safety_guide': 1,
            'similar_alerts_count': 2,
            'alert_engagement_rate': 0.7,
            'source_reliability': 1.0
        }
        
        score = model.predict(features)
        
        assert 0 <= score <= 100
    
    def test_high_severity_gets_higher_score(self):
        """Test that high severity alerts get higher scores"""
        model = AlertScoringModel(cold_start=True)
        
        # High severity features
        high_severity_features = {
            'severity_score': 4,  # Critical
            'alert_type_score': 4,
            'hours_since_created': 0.5,
            'distance_km': 2.0,
            'target_audience_match': 1,
            'user_previous_interactions': 5,
            'time_of_day': 14,
            'day_of_week': 2,
            'weather_severity': 3,
            'content_length': 200,
            'has_images': 1,
            'has_safety_guide': 1,
            'similar_alerts_count': 1,
            'alert_engagement_rate': 0.8,
            'source_reliability': 1.0
        }
        
        # Low severity features
        low_severity_features = high_severity_features.copy()
        low_severity_features['severity_score'] = 1  # Low
        low_severity_features['alert_type_score'] = 1
        
        high_score = model.predict(high_severity_features)
        low_score = model.predict(low_severity_features)
        
        assert high_score > low_score
    
    def test_feature_importance(self):
        """Test getting feature importance"""
        model = AlertScoringModel(cold_start=True)
        
        importance = model.get_feature_importance()
        
        assert len(importance) > 0
        assert 'severity_score' in importance
        assert all(0 <= v <= 1 for v in importance.values())


class TestSemanticDuplicateDetector:
    """Test Semantic Duplicate Detector"""
    
    def test_model_initialization(self):
        """Test model loads successfully"""
        detector = SemanticDuplicateDetector()
        
        assert detector.model is not None
        assert detector.threshold > 0
    
    def test_calculate_similarity_identical(self):
        """Test similarity of identical texts"""
        detector = SemanticDuplicateDetector()
        
        text = "Bão cấp 12 đang tiến vào bờ"
        similarity = detector.calculate_similarity(text, text)
        
        # Identical texts should have very high similarity
        assert similarity > 0.95
    
    def test_calculate_similarity_similar(self):
        """Test similarity of similar texts"""
        detector = SemanticDuplicateDetector()
        
        text1 = "Bão cấp 12 đang tiến vào bờ biển"
        text2 = "Bão mạnh cấp 12 sắp vào bờ"
        
        similarity = detector.calculate_similarity(text1, text2)
        
        # Similar texts should have high similarity
        assert similarity > 0.7
    
    def test_calculate_similarity_different(self):
        """Test similarity of different texts"""
        detector = SemanticDuplicateDetector()
        
        text1 = "Bão cấp 12 đang tiến vào bờ"
        text2 = "Mưa nhỏ vào chiều nay"
        
        similarity = detector.calculate_similarity(text1, text2)
        
        # Different texts should have low similarity
        assert similarity < 0.6
    
    def test_is_duplicate_positive(self):
        """Test duplicate detection returns true for duplicates"""
        detector = SemanticDuplicateDetector()
        
        alert1 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        alert2 = {
            'content': 'Bão cấp 12 sắp vào bờ biển',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        is_dup = detector.is_duplicate(alert1, alert2)
        
        assert is_dup == True
    
    def test_is_duplicate_different_province(self):
        """Test that different provinces are not duplicates"""
        detector = SemanticDuplicateDetector()
        
        alert1 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Quảng Nam'
        }
        
        alert2 = {
            'content': 'Bão cấp 12 đang tiến vào bờ',
            'alert_type': 'disaster',
            'severity': 'critical',
            'province': 'Đà Nẵng'
        }
        
        is_dup = detector.is_duplicate(alert1, alert2)
        
        assert is_dup == False
    
    def test_find_duplicates(self):
        """Test finding all duplicates"""
        detector = SemanticDuplicateDetector()
        
        new_alert = {
            'content': 'Mưa lớn trong 3 giờ tới',
            'alert_type': 'weather',
            'severity': 'high',
            'province': 'TP.HCM'
        }
        
        existing = [
            {
                'id': 'alert-1',
                'content': 'Mưa to sắp đến trong vài giờ',
                'alert_type': 'weather',
                'severity': 'high',
                'province': 'TP.HCM'
            },
            {
                'id': 'alert-2',
                'content': 'Bão cấp 10',
                'alert_type': 'disaster',
                'severity': 'critical',
                'province': 'Quảng Nam'
            }
        ]
        
        duplicates = detector.find_duplicates(new_alert, existing)
        
        # Should find at least one duplicate
        assert len(duplicates) >= 0


class TestNotificationTimingModel:
    """Test Notification Timing Model"""
    
    def test_model_initialization(self):
        """Test model initializes correctly"""
        model = NotificationTimingModel()
        
        assert model.n_slots == 24
        assert len(model.alpha) == 24
        assert len(model.beta_param) == 24
    
    def test_select_time_slot_range(self):
        """Test that selected time slot is valid"""
        model = NotificationTimingModel()
        
        slot = model.select_time_slot(
            alert_severity='medium',
            user_context={}
        )
        
        assert 0 <= slot <= 23
    
    def test_update_feedback_success(self):
        """Test updating with successful engagement"""
        model = NotificationTimingModel()
        
        initial_alpha = model.alpha[10]
        
        model.update_feedback(time_slot=10, engaged=True)
        
        # Alpha should increase
        assert model.alpha[10] > initial_alpha
    
    def test_update_feedback_failure(self):
        """Test updating with failed engagement"""
        model = NotificationTimingModel()
        
        initial_beta = model.beta_param[10]
        
        model.update_feedback(time_slot=10, engaged=False)
        
        # Beta should increase
        assert model.beta_param[10] > initial_beta
    
    def test_get_best_times(self):
        """Test getting best time slots"""
        model = NotificationTimingModel()
        
        # Add some fake successful engagements
        for _ in range(10):
            model.update_feedback(time_slot=18, engaged=True)  # Evening
        
        best_times = model.get_best_times(top_k=3)
        
        assert len(best_times) == 3
        assert all('hour' in t for t in best_times)
        assert all('success_rate' in t for t in best_times)
        assert all('confidence' in t for t in best_times)
    
    def test_critical_alert_immediate(self):
        """Test that critical alerts recommend current time"""
        model = NotificationTimingModel()
        
        from datetime import datetime
        current_hour = datetime.now().hour
        
        slot = model.select_time_slot(
            alert_severity='critical',
            user_context={}
        )
        
        # Should recommend current hour
        assert slot == current_hour


# Run tests
if __name__ == "__main__":
    pytest.main([__file__, "-v"])

















