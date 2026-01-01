"""API Tests for Smart Alert AI Service"""
import pytest
from fastapi.testclient import TestClient
import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from main import app

client = TestClient(app)


class TestHealthEndpoint:
    """Test health check endpoint"""
    
    def test_health_check(self):
        """Test health check returns 200"""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        
        data = response.json()
        assert "status" in data
        assert data["status"] == "healthy"
        assert "models" in data


class TestScoringEndpoint:
    """Test alert scoring endpoint"""
    
    def test_score_alert_success(self):
        """Test scoring an alert successfully"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-123",
            "severity": "high",
            "alert_type": "weather",
            "content": "Mưa lớn trong 3 giờ tới",
            "province": "TP.HCM",
            "district": "Quận 1",
            "lat": 10.762622,
            "lng": 106.660172,
            "created_at": "2024-01-01T10:00:00Z",
            "user_lat": 10.762622,
            "user_lng": 106.660172,
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        
        data = response.json()
        assert "alert_id" in data
        assert "priority_score" in data
        assert "confidence" in data
        assert "explanation" in data
        
        # Score should be between 0 and 100
        assert 0 <= data["priority_score"] <= 100
        
        # Confidence should be between 0 and 1
        assert 0 <= data["confidence"] <= 1
    
    def test_score_alert_critical_severity(self):
        """Test that critical alerts get high scores"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-critical",
            "severity": "critical",
            "alert_type": "disaster",
            "content": "Động đất mạnh 7.0 độ Richter",
            "province": "Đà Nẵng",
            "district": "Hải Châu",
            "lat": 16.054407,
            "lng": 108.202164,
            "created_at": "2024-01-01T10:00:00Z",
            "user_lat": 16.054407,
            "user_lng": 108.202164,
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Critical alerts should have high scores (>70)
        assert data["priority_score"] > 70
    
    def test_score_alert_missing_fields(self):
        """Test scoring with minimal required fields"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-minimal",
            "severity": "medium",
            "alert_type": "general",
            "content": "Test alert",
            "province": "Hà Nội",
            "created_at": "2024-01-01T10:00:00Z",
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "priority_score" in data


class TestDuplicateEndpoint:
    """Test duplicate detection endpoint"""
    
    def test_check_duplicate_exact_match(self):
        """Test duplicate detection with exact match"""
        response = client.post("/api/v1/duplicate/check", json={
            "new_alert": {
                "id": "new-1",
                "content": "Bão cấp 12 đang tiến vào bờ",
                "alert_type": "disaster",
                "severity": "critical",
                "province": "Quảng Nam"
            },
            "existing_alerts": [
                {
                    "id": "existing-1",
                    "content": "Bão cấp 12 sắp vào bờ biển",
                    "alert_type": "disaster",
                    "severity": "critical",
                    "province": "Quảng Nam"
                }
            ]
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "is_duplicate" in data
        assert "duplicates" in data
        assert "best_match" in data
        
        # Should detect duplicate
        assert data["is_duplicate"] == True
        assert len(data["duplicates"]) > 0
        
        # Should have high similarity
        if data["best_match"]:
            assert data["best_match"]["similarity"] > 0.8
    
    def test_check_duplicate_no_match(self):
        """Test duplicate detection with no match"""
        response = client.post("/api/v1/duplicate/check", json={
            "new_alert": {
                "id": "new-2",
                "content": "Mưa nhỏ vào chiều nay",
                "alert_type": "weather",
                "severity": "low",
                "province": "TP.HCM"
            },
            "existing_alerts": [
                {
                    "id": "existing-2",
                    "content": "Động đất mạnh tại miền Trung",
                    "alert_type": "disaster",
                    "severity": "critical",
                    "province": "Đà Nẵng"
                }
            ]
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Should not detect duplicate
        assert data["is_duplicate"] == False
        assert len(data["duplicates"]) == 0


class TestTimingEndpoint:
    """Test notification timing endpoint"""
    
    def test_recommend_timing_success(self):
        """Test timing recommendation"""
        response = client.post("/api/v1/timing/recommend", json={
            "alert_severity": "medium",
            "user_id": "user-123",
            "user_context": {}
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "recommended_hour" in data
        assert "top_times" in data
        assert "strategy" in data
        
        # Hour should be 0-23
        assert 0 <= data["recommended_hour"] <= 23
        
        # Should have top times
        assert len(data["top_times"]) > 0
    
    def test_recommend_timing_critical_alert(self):
        """Test that critical alerts recommend immediate timing"""
        response = client.post("/api/v1/timing/recommend", json={
            "alert_severity": "critical",
            "user_id": "user-456",
            "user_context": {}
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Critical alerts should recommend current or near-current hour
        # (within a few hours)
        from datetime import datetime
        current_hour = datetime.now().hour
        recommended = data["recommended_hour"]
        
        # Allow some flexibility for testing
        assert abs(recommended - current_hour) <= 3 or \
               abs(recommended - current_hour) >= 21  # Account for day wrap


class TestFeedbackEndpoint:
    """Test feedback logging endpoint"""
    
    def test_log_engagement_success(self):
        """Test logging user engagement"""
        response = client.post("/api/v1/feedback/engagement", json={
            "alert_id": "test-alert-1",
            "user_id": "user-789",
            "action": "click",
            "time_slot": 14
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "status" in data
        assert data["status"] == "logged"
        assert data["alert_id"] == "test-alert-1"
    
    def test_log_engagement_different_actions(self):
        """Test logging different action types"""
        actions = ["view", "click", "dismiss", "share"]
        
        for action in actions:
            response = client.post("/api/v1/feedback/engagement", json={
                "alert_id": f"test-{action}",
                "user_id": "user-123",
                "action": action,
                "time_slot": 10
            })
            
            assert response.status_code == 200


class TestStatsEndpoints:
    """Test statistics endpoints"""
    
    def test_get_engagement_stats(self):
        """Test getting engagement statistics"""
        response = client.get("/api/v1/stats/engagement?days=7")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "period_days" in data
        assert "stats" in data
    
    def test_get_duplicate_stats(self):
        """Test getting duplicate detection statistics"""
        response = client.get("/api/v1/stats/duplicate?days=7")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "period_days" in data
        assert "stats" in data
    
    def test_get_timing_stats(self):
        """Test getting timing statistics"""
        response = client.get("/api/v1/stats/timing")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "all_time_slots" in data
        assert "best_times" in data


class TestModelEndpoints:
    """Test model management endpoints"""
    
    def test_get_feature_importance(self):
        """Test getting feature importance"""
        response = client.get("/api/v1/model/feature-importance")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "model" in data
        assert "feature_importance" in data
        assert "top_features" in data
    
    def test_get_retraining_status(self):
        """Test getting retraining status"""
        response = client.get("/api/v1/model/retraining-status")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "samples_collected" in data
        assert "samples_required" in data
        assert "ready_for_retraining" in data
        assert "progress_percentage" in data


# Run tests
if __name__ == "__main__":
    pytest.main([__file__, "-v"])


import pytest
from fastapi.testclient import TestClient
import sys
from pathlib import Path

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))

from main import app

client = TestClient(app)


class TestHealthEndpoint:
    """Test health check endpoint"""
    
    def test_health_check(self):
        """Test health check returns 200"""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        
        data = response.json()
        assert "status" in data
        assert data["status"] == "healthy"
        assert "models" in data


class TestScoringEndpoint:
    """Test alert scoring endpoint"""
    
    def test_score_alert_success(self):
        """Test scoring an alert successfully"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-123",
            "severity": "high",
            "alert_type": "weather",
            "content": "Mưa lớn trong 3 giờ tới",
            "province": "TP.HCM",
            "district": "Quận 1",
            "lat": 10.762622,
            "lng": 106.660172,
            "created_at": "2024-01-01T10:00:00Z",
            "user_lat": 10.762622,
            "user_lng": 106.660172,
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        
        data = response.json()
        assert "alert_id" in data
        assert "priority_score" in data
        assert "confidence" in data
        assert "explanation" in data
        
        # Score should be between 0 and 100
        assert 0 <= data["priority_score"] <= 100
        
        # Confidence should be between 0 and 1
        assert 0 <= data["confidence"] <= 1
    
    def test_score_alert_critical_severity(self):
        """Test that critical alerts get high scores"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-critical",
            "severity": "critical",
            "alert_type": "disaster",
            "content": "Động đất mạnh 7.0 độ Richter",
            "province": "Đà Nẵng",
            "district": "Hải Châu",
            "lat": 16.054407,
            "lng": 108.202164,
            "created_at": "2024-01-01T10:00:00Z",
            "user_lat": 16.054407,
            "user_lng": 108.202164,
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Critical alerts should have high scores (>70)
        assert data["priority_score"] > 70
    
    def test_score_alert_missing_fields(self):
        """Test scoring with minimal required fields"""
        response = client.post("/api/v1/score", json={
            "alert_id": "test-minimal",
            "severity": "medium",
            "alert_type": "general",
            "content": "Test alert",
            "province": "Hà Nội",
            "created_at": "2024-01-01T10:00:00Z",
            "user_role": "victim"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "priority_score" in data


class TestDuplicateEndpoint:
    """Test duplicate detection endpoint"""
    
    def test_check_duplicate_exact_match(self):
        """Test duplicate detection with exact match"""
        response = client.post("/api/v1/duplicate/check", json={
            "new_alert": {
                "id": "new-1",
                "content": "Bão cấp 12 đang tiến vào bờ",
                "alert_type": "disaster",
                "severity": "critical",
                "province": "Quảng Nam"
            },
            "existing_alerts": [
                {
                    "id": "existing-1",
                    "content": "Bão cấp 12 sắp vào bờ biển",
                    "alert_type": "disaster",
                    "severity": "critical",
                    "province": "Quảng Nam"
                }
            ]
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "is_duplicate" in data
        assert "duplicates" in data
        assert "best_match" in data
        
        # Should detect duplicate
        assert data["is_duplicate"] == True
        assert len(data["duplicates"]) > 0
        
        # Should have high similarity
        if data["best_match"]:
            assert data["best_match"]["similarity"] > 0.8
    
    def test_check_duplicate_no_match(self):
        """Test duplicate detection with no match"""
        response = client.post("/api/v1/duplicate/check", json={
            "new_alert": {
                "id": "new-2",
                "content": "Mưa nhỏ vào chiều nay",
                "alert_type": "weather",
                "severity": "low",
                "province": "TP.HCM"
            },
            "existing_alerts": [
                {
                    "id": "existing-2",
                    "content": "Động đất mạnh tại miền Trung",
                    "alert_type": "disaster",
                    "severity": "critical",
                    "province": "Đà Nẵng"
                }
            ]
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Should not detect duplicate
        assert data["is_duplicate"] == False
        assert len(data["duplicates"]) == 0


class TestTimingEndpoint:
    """Test notification timing endpoint"""
    
    def test_recommend_timing_success(self):
        """Test timing recommendation"""
        response = client.post("/api/v1/timing/recommend", json={
            "alert_severity": "medium",
            "user_id": "user-123",
            "user_context": {}
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "recommended_hour" in data
        assert "top_times" in data
        assert "strategy" in data
        
        # Hour should be 0-23
        assert 0 <= data["recommended_hour"] <= 23
        
        # Should have top times
        assert len(data["top_times"]) > 0
    
    def test_recommend_timing_critical_alert(self):
        """Test that critical alerts recommend immediate timing"""
        response = client.post("/api/v1/timing/recommend", json={
            "alert_severity": "critical",
            "user_id": "user-456",
            "user_context": {}
        })
        
        assert response.status_code == 200
        data = response.json()
        
        # Critical alerts should recommend current or near-current hour
        # (within a few hours)
        from datetime import datetime
        current_hour = datetime.now().hour
        recommended = data["recommended_hour"]
        
        # Allow some flexibility for testing
        assert abs(recommended - current_hour) <= 3 or \
               abs(recommended - current_hour) >= 21  # Account for day wrap


class TestFeedbackEndpoint:
    """Test feedback logging endpoint"""
    
    def test_log_engagement_success(self):
        """Test logging user engagement"""
        response = client.post("/api/v1/feedback/engagement", json={
            "alert_id": "test-alert-1",
            "user_id": "user-789",
            "action": "click",
            "time_slot": 14
        })
        
        assert response.status_code == 200
        data = response.json()
        
        assert "status" in data
        assert data["status"] == "logged"
        assert data["alert_id"] == "test-alert-1"
    
    def test_log_engagement_different_actions(self):
        """Test logging different action types"""
        actions = ["view", "click", "dismiss", "share"]
        
        for action in actions:
            response = client.post("/api/v1/feedback/engagement", json={
                "alert_id": f"test-{action}",
                "user_id": "user-123",
                "action": action,
                "time_slot": 10
            })
            
            assert response.status_code == 200


class TestStatsEndpoints:
    """Test statistics endpoints"""
    
    def test_get_engagement_stats(self):
        """Test getting engagement statistics"""
        response = client.get("/api/v1/stats/engagement?days=7")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "period_days" in data
        assert "stats" in data
    
    def test_get_duplicate_stats(self):
        """Test getting duplicate detection statistics"""
        response = client.get("/api/v1/stats/duplicate?days=7")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "period_days" in data
        assert "stats" in data
    
    def test_get_timing_stats(self):
        """Test getting timing statistics"""
        response = client.get("/api/v1/stats/timing")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "all_time_slots" in data
        assert "best_times" in data


class TestModelEndpoints:
    """Test model management endpoints"""
    
    def test_get_feature_importance(self):
        """Test getting feature importance"""
        response = client.get("/api/v1/model/feature-importance")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "model" in data
        assert "feature_importance" in data
        assert "top_features" in data
    
    def test_get_retraining_status(self):
        """Test getting retraining status"""
        response = client.get("/api/v1/model/retraining-status")
        
        assert response.status_code == 200
        data = response.json()
        
        assert "samples_collected" in data
        assert "samples_required" in data
        assert "ready_for_retraining" in data
        assert "progress_percentage" in data


# Run tests
if __name__ == "__main__":
    pytest.main([__file__, "-v"])



