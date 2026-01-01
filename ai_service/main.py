"""
Smart Alert AI Service - FastAPI Application

Provides AI-powered:
- Alert priority scoring using Machine Learning
- Semantic duplicate detection using Sentence Transformers
- Intelligent notification timing using Contextual Bandit
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
import uvicorn

# Import models and services
from models.alert_scorer import AlertScoringModel
from models.duplicate_detector import SemanticDuplicateDetector
from models.notification_timing import NotificationTimingModel
from services.data_collector import DataCollector
from services.model_trainer import ModelRetrainer
from utils.features import FeatureExtractor
from utils.metrics import MetricsCalculator

# Initialize FastAPI app
app = FastAPI(
    title="Smart Alert AI Service",
    version="1.0.0",
    description="AI-powered alert prioritization and optimization",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize models and services (singleton pattern)
print("[API] Initializing models...")
scorer = AlertScoringModel(cold_start=True)
duplicate_detector = SemanticDuplicateDetector()
timing_model = NotificationTimingModel()
data_collector = DataCollector()
model_retrainer = ModelRetrainer(data_collector)
feature_extractor = FeatureExtractor()
metrics_calculator = MetricsCalculator()
print("[API] All models initialized successfully")


# ===================== Pydantic Schemas =====================

class AlertScoreRequest(BaseModel):
    """Request schema for alert scoring"""
    alert_id: str
    severity: str = Field(..., description="Alert severity: low, medium, high, critical")
    alert_type: str = Field(..., description="Alert type: general, weather, evacuation, disaster")
    content: str
    province: str
    district: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    created_at: str = Field(..., description="ISO 8601 datetime string")
    user_lat: Optional[float] = None
    user_lng: Optional[float] = None
    user_role: str = Field(default="victim", description="User role: victim, volunteer, admin")
    
    class Config:
        json_schema_extra = {
            "example": {
                "alert_id": "alert-123",
                "severity": "high",
                "alert_type": "weather",
                "content": "Mưa lớn trong 3 giờ tới, nguy cơ ngập lụt",
                "province": "TP.HCM",
                "district": "Quận 1",
                "lat": 10.762622,
                "lng": 106.660172,
                "created_at": "2024-01-15T10:00:00Z",
                "user_lat": 10.762622,
                "user_lng": 106.660172,
                "user_role": "victim"
            }
        }


class AlertScoreResponse(BaseModel):
    """Response schema for alert scoring"""
    alert_id: str
    priority_score: float = Field(..., description="Priority score (0-100)")
    confidence: float = Field(..., description="Confidence score (0-1)")
    explanation: Dict


class DuplicateCheckRequest(BaseModel):
    """Request schema for duplicate detection"""
    new_alert: Dict
    existing_alerts: List[Dict]
    threshold: Optional[float] = Field(default=0.85, description="Similarity threshold (0-1)")


class DuplicateCheckResponse(BaseModel):
    """Response schema for duplicate detection"""
    is_duplicate: bool
    duplicates: List[Dict]
    best_match: Optional[Dict] = None


class NotificationTimingRequest(BaseModel):
    """Request schema for notification timing"""
    alert_severity: str
    user_id: str
    user_context: Optional[Dict] = {}


class NotificationTimingResponse(BaseModel):
    """Response schema for notification timing"""
    recommended_hour: int = Field(..., description="Recommended hour (0-23)")
    top_times: List[Dict]
    strategy: str = "thompson_sampling"


class FeedbackRequest(BaseModel):
    """Request schema for user feedback"""
    alert_id: str
    user_id: str
    action: str = Field(..., description="Action: view, click, dismiss, share")
    time_slot: Optional[int] = Field(default=None, description="Hour of day (0-23)")
    actual_score: Optional[float] = None


# ===================== API Endpoints =====================

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Smart Alert AI Service",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "docs": "/docs",
            "health": "/api/v1/health",
            "score": "/api/v1/score",
            "duplicate": "/api/v1/duplicate/check",
            "timing": "/api/v1/timing/recommend",
            "feedback": "/api/v1/feedback/engagement"
        }
    }


@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "models": {
            "scorer": "loaded" if scorer.is_trained else "not_trained",
            "duplicate_detector": "loaded",
            "timing_model": "loaded"
        },
        "database": "connected"
    }


@app.post("/api/v1/score", response_model=AlertScoreResponse)
async def score_alert(request: AlertScoreRequest):
    """
    Score alert priority using ML model
    
    Returns priority score (0-100) based on multiple factors:
    - Alert severity and type
    - Distance from user
    - Time decay
    - User context
    """
    try:
        # Extract features
        features = feature_extractor.extract_features(request.dict())
        
        # Predict score
        score, confidence = scorer.predict_with_confidence(features)
        
        # Generate explanation
        explanation = feature_extractor.generate_explanation(features, score)
        
        # Log for future training
        data_collector.log_prediction(
            alert_id=request.alert_id,
            features=features,
            predicted_score=score
        )
        
        return AlertScoreResponse(
            alert_id=request.alert_id,
            priority_score=score,
            confidence=confidence,
            explanation=explanation
        )
    
    except Exception as e:
        print(f"[API] Error in score_alert: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/duplicate/check", response_model=DuplicateCheckResponse)
async def check_duplicate(request: DuplicateCheckRequest):
    """
    Check if alert is duplicate using semantic similarity
    
    Uses Sentence Transformers to understand semantic meaning,
    providing much better duplicate detection than text matching.
    """
    try:
        # Find duplicates
        duplicates = duplicate_detector.find_duplicates(
            new_alert=request.new_alert,
            existing_alerts=request.existing_alerts,
            return_all=True
        )
        
        is_duplicate = len(duplicates) > 0
        best_match = duplicates[0] if duplicates else None
        
        # Log duplicate check
        if is_duplicate:
            data_collector.log_duplicate_check(
                alert_id=request.new_alert.get('id', 'unknown'),
                is_duplicate=True,
                best_match_id=best_match['alert'].get('id'),
                similarity=best_match['similarity']
            )
        
        return DuplicateCheckResponse(
            is_duplicate=is_duplicate,
            duplicates=duplicates,
            best_match=best_match
        )
    
    except Exception as e:
        print(f"[API] Error in check_duplicate: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/timing/recommend", response_model=NotificationTimingResponse)
async def recommend_timing(request: NotificationTimingRequest):
    """
    Recommend best notification timing
    
    Uses Thompson Sampling (Multi-Armed Bandit) to learn optimal
    notification times based on user engagement patterns.
    """
    try:
        # Get best time slot
        best_slot = timing_model.select_time_slot(
            alert_severity=request.alert_severity,
            user_context=request.user_context
        )
        
        # Get top 3 times
        top_times = timing_model.get_best_times(top_k=3)
        
        return NotificationTimingResponse(
            recommended_hour=best_slot,
            top_times=top_times,
            strategy="thompson_sampling"
        )
    
    except Exception as e:
        print(f"[API] Error in recommend_timing: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/feedback/engagement")
async def log_engagement(request: FeedbackRequest):
    """
    Log user engagement for online learning
    
    Stores user feedback to improve models over time:
    - Updates notification timing model immediately
    - Stores data for batch retraining of scoring model
    """
    try:
        # Update notification timing model
        engaged = request.action in ['view', 'click', 'share']
        
        if request.time_slot is not None:
            timing_model.update_feedback(request.time_slot, engaged)
        
        # Update scoring model if actual score provided
        if request.actual_score is not None:
            features = data_collector.get_features(request.alert_id)
            if features:
                scorer.update_online(features, request.actual_score)
        
        # Store for batch retraining
        data_collector.log_engagement(
            alert_id=request.alert_id,
            user_id=request.user_id,
            action=request.action,
            time_slot=request.time_slot
        )
        
        return {
            "status": "logged",
            "alert_id": request.alert_id,
            "action": request.action
        }
    
    except Exception as e:
        print(f"[API] Error in log_engagement: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/engagement")
async def get_engagement_stats(days: int = 7):
    """Get engagement statistics"""
    try:
        stats = data_collector.get_engagement_stats(days=days)
        return {
            "period_days": days,
            "stats": stats
        }
    except Exception as e:
        print(f"[API] Error in get_engagement_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/duplicate")
async def get_duplicate_stats(days: int = 7):
    """Get duplicate detection statistics"""
    try:
        stats = data_collector.get_duplicate_stats(days=days)
        return {
            "period_days": days,
            "stats": stats
        }
    except Exception as e:
        print(f"[API] Error in get_duplicate_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/timing")
async def get_timing_stats():
    """Get notification timing statistics"""
    try:
        all_stats = timing_model.get_all_time_stats()
        best_times = timing_model.get_best_times(top_k=5)
        
        return {
            "all_time_slots": all_stats,
            "best_times": best_times
        }
    except Exception as e:
        print(f"[API] Error in get_timing_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/model/feature-importance")
async def get_feature_importance():
    """Get feature importance from scoring model"""
    try:
        importance = scorer.get_feature_importance()
        
        # Sort by importance
        sorted_features = sorted(
            importance.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            "model": "alert_scorer",
            "feature_importance": dict(sorted_features),
            "top_features": sorted_features[:5]
        }
    except Exception as e:
        print(f"[API] Error in get_feature_importance: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/model/retrain")
async def trigger_retraining(min_samples: int = 100):
    """
    Trigger model retraining (admin endpoint)
    
    WARNING: This can take several seconds to complete
    """
    try:
        # Check if retraining is needed
        status = model_retrainer.get_retraining_status()
        
        if not status['ready_for_retraining']:
            return {
                "status": "not_ready",
                "message": f"Not enough data for retraining. Need {status['samples_required']}, have {status['samples_collected']}",
                "progress": status
            }
        
        # Perform retraining
        result = model_retrainer.retrain_scorer(min_samples=min_samples)
        
        if result['success']:
            # Reload the model
            global scorer
            scorer = AlertScoringModel(cold_start=False)
            
            return {
                "status": "success",
                "message": "Model retrained successfully",
                "result": result
            }
        else:
            return {
                "status": "failed",
                "message": result.get('reason', 'Unknown error'),
                "result": result
            }
    
    except Exception as e:
        print(f"[API] Error in trigger_retraining: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/model/retraining-status")
async def get_retraining_status():
    """Get retraining status"""
    try:
        status = model_retrainer.get_retraining_status()
        return status
    except Exception as e:
        print(f"[API] Error in get_retraining_status: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Initialize FastAPI app
app = FastAPI(
    title="Smart Alert AI Service",
    version="1.0.0",
    description="AI-powered alert prioritization and optimization",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize models and services (singleton pattern)
print("[API] Initializing models...")
scorer = AlertScoringModel(cold_start=True)
duplicate_detector = SemanticDuplicateDetector()
timing_model = NotificationTimingModel()
data_collector = DataCollector()
model_retrainer = ModelRetrainer(data_collector)
feature_extractor = FeatureExtractor()
metrics_calculator = MetricsCalculator()
print("[API] All models initialized successfully")


# ===================== Pydantic Schemas =====================

class AlertScoreRequest(BaseModel):
    """Request schema for alert scoring"""
    alert_id: str
    severity: str = Field(..., description="Alert severity: low, medium, high, critical")
    alert_type: str = Field(..., description="Alert type: general, weather, evacuation, disaster")
    content: str
    province: str
    district: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    created_at: str = Field(..., description="ISO 8601 datetime string")
    user_lat: Optional[float] = None
    user_lng: Optional[float] = None
    user_role: str = Field(default="victim", description="User role: victim, volunteer, admin")
    
    class Config:
        json_schema_extra = {
            "example": {
                "alert_id": "alert-123",
                "severity": "high",
                "alert_type": "weather",
                "content": "Mưa lớn trong 3 giờ tới, nguy cơ ngập lụt",
                "province": "TP.HCM",
                "district": "Quận 1",
                "lat": 10.762622,
                "lng": 106.660172,
                "created_at": "2024-01-15T10:00:00Z",
                "user_lat": 10.762622,
                "user_lng": 106.660172,
                "user_role": "victim"
            }
        }


class AlertScoreResponse(BaseModel):
    """Response schema for alert scoring"""
    alert_id: str
    priority_score: float = Field(..., description="Priority score (0-100)")
    confidence: float = Field(..., description="Confidence score (0-1)")
    explanation: Dict


class DuplicateCheckRequest(BaseModel):
    """Request schema for duplicate detection"""
    new_alert: Dict
    existing_alerts: List[Dict]
    threshold: Optional[float] = Field(default=0.85, description="Similarity threshold (0-1)")


class DuplicateCheckResponse(BaseModel):
    """Response schema for duplicate detection"""
    is_duplicate: bool
    duplicates: List[Dict]
    best_match: Optional[Dict] = None


class NotificationTimingRequest(BaseModel):
    """Request schema for notification timing"""
    alert_severity: str
    user_id: str
    user_context: Optional[Dict] = {}


class NotificationTimingResponse(BaseModel):
    """Response schema for notification timing"""
    recommended_hour: int = Field(..., description="Recommended hour (0-23)")
    top_times: List[Dict]
    strategy: str = "thompson_sampling"


class FeedbackRequest(BaseModel):
    """Request schema for user feedback"""
    alert_id: str
    user_id: str
    action: str = Field(..., description="Action: view, click, dismiss, share")
    time_slot: Optional[int] = Field(default=None, description="Hour of day (0-23)")
    actual_score: Optional[float] = None


# ===================== API Endpoints =====================

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Smart Alert AI Service",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "docs": "/docs",
            "health": "/api/v1/health",
            "score": "/api/v1/score",
            "duplicate": "/api/v1/duplicate/check",
            "timing": "/api/v1/timing/recommend",
            "feedback": "/api/v1/feedback/engagement"
        }
    }


@app.get("/api/v1/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "models": {
            "scorer": "loaded" if scorer.is_trained else "not_trained",
            "duplicate_detector": "loaded",
            "timing_model": "loaded"
        },
        "database": "connected"
    }


@app.post("/api/v1/score", response_model=AlertScoreResponse)
async def score_alert(request: AlertScoreRequest):
    """
    Score alert priority using ML model
    
    Returns priority score (0-100) based on multiple factors:
    - Alert severity and type
    - Distance from user
    - Time decay
    - User context
    """
    try:
        # Extract features
        features = feature_extractor.extract_features(request.dict())
        
        # Predict score
        score, confidence = scorer.predict_with_confidence(features)
        
        # Generate explanation
        explanation = feature_extractor.generate_explanation(features, score)
        
        # Log for future training
        data_collector.log_prediction(
            alert_id=request.alert_id,
            features=features,
            predicted_score=score
        )
        
        return AlertScoreResponse(
            alert_id=request.alert_id,
            priority_score=score,
            confidence=confidence,
            explanation=explanation
        )
    
    except Exception as e:
        print(f"[API] Error in score_alert: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/duplicate/check", response_model=DuplicateCheckResponse)
async def check_duplicate(request: DuplicateCheckRequest):
    """
    Check if alert is duplicate using semantic similarity
    
    Uses Sentence Transformers to understand semantic meaning,
    providing much better duplicate detection than text matching.
    """
    try:
        # Find duplicates
        duplicates = duplicate_detector.find_duplicates(
            new_alert=request.new_alert,
            existing_alerts=request.existing_alerts,
            return_all=True
        )
        
        is_duplicate = len(duplicates) > 0
        best_match = duplicates[0] if duplicates else None
        
        # Log duplicate check
        if is_duplicate:
            data_collector.log_duplicate_check(
                alert_id=request.new_alert.get('id', 'unknown'),
                is_duplicate=True,
                best_match_id=best_match['alert'].get('id'),
                similarity=best_match['similarity']
            )
        
        return DuplicateCheckResponse(
            is_duplicate=is_duplicate,
            duplicates=duplicates,
            best_match=best_match
        )
    
    except Exception as e:
        print(f"[API] Error in check_duplicate: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/timing/recommend", response_model=NotificationTimingResponse)
async def recommend_timing(request: NotificationTimingRequest):
    """
    Recommend best notification timing
    
    Uses Thompson Sampling (Multi-Armed Bandit) to learn optimal
    notification times based on user engagement patterns.
    """
    try:
        # Get best time slot
        best_slot = timing_model.select_time_slot(
            alert_severity=request.alert_severity,
            user_context=request.user_context
        )
        
        # Get top 3 times
        top_times = timing_model.get_best_times(top_k=3)
        
        return NotificationTimingResponse(
            recommended_hour=best_slot,
            top_times=top_times,
            strategy="thompson_sampling"
        )
    
    except Exception as e:
        print(f"[API] Error in recommend_timing: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/feedback/engagement")
async def log_engagement(request: FeedbackRequest):
    """
    Log user engagement for online learning
    
    Stores user feedback to improve models over time:
    - Updates notification timing model immediately
    - Stores data for batch retraining of scoring model
    """
    try:
        # Update notification timing model
        engaged = request.action in ['view', 'click', 'share']
        
        if request.time_slot is not None:
            timing_model.update_feedback(request.time_slot, engaged)
        
        # Update scoring model if actual score provided
        if request.actual_score is not None:
            features = data_collector.get_features(request.alert_id)
            if features:
                scorer.update_online(features, request.actual_score)
        
        # Store for batch retraining
        data_collector.log_engagement(
            alert_id=request.alert_id,
            user_id=request.user_id,
            action=request.action,
            time_slot=request.time_slot
        )
        
        return {
            "status": "logged",
            "alert_id": request.alert_id,
            "action": request.action
        }
    
    except Exception as e:
        print(f"[API] Error in log_engagement: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/engagement")
async def get_engagement_stats(days: int = 7):
    """Get engagement statistics"""
    try:
        stats = data_collector.get_engagement_stats(days=days)
        return {
            "period_days": days,
            "stats": stats
        }
    except Exception as e:
        print(f"[API] Error in get_engagement_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/duplicate")
async def get_duplicate_stats(days: int = 7):
    """Get duplicate detection statistics"""
    try:
        stats = data_collector.get_duplicate_stats(days=days)
        return {
            "period_days": days,
            "stats": stats
        }
    except Exception as e:
        print(f"[API] Error in get_duplicate_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/stats/timing")
async def get_timing_stats():
    """Get notification timing statistics"""
    try:
        all_stats = timing_model.get_all_time_stats()
        best_times = timing_model.get_best_times(top_k=5)
        
        return {
            "all_time_slots": all_stats,
            "best_times": best_times
        }
    except Exception as e:
        print(f"[API] Error in get_timing_stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/model/feature-importance")
async def get_feature_importance():
    """Get feature importance from scoring model"""
    try:
        importance = scorer.get_feature_importance()
        
        # Sort by importance
        sorted_features = sorted(
            importance.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            "model": "alert_scorer",
            "feature_importance": dict(sorted_features),
            "top_features": sorted_features[:5]
        }
    except Exception as e:
        print(f"[API] Error in get_feature_importance: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/model/retrain")
async def trigger_retraining(min_samples: int = 100):
    """
    Trigger model retraining (admin endpoint)
    
    WARNING: This can take several seconds to complete
    """
    try:
        # Check if retraining is needed
        status = model_retrainer.get_retraining_status()
        
        if not status['ready_for_retraining']:
            return {
                "status": "not_ready",
                "message": f"Not enough data for retraining. Need {status['samples_required']}, have {status['samples_collected']}",
                "progress": status
            }
        
        # Perform retraining
        result = model_retrainer.retrain_scorer(min_samples=min_samples)
        
        if result['success']:
            # Reload the model
            global scorer
            scorer = AlertScoringModel(cold_start=False)
            
            return {
                "status": "success",
                "message": "Model retrained successfully",
                "result": result
            }
        else:
            return {
                "status": "failed",
                "message": result.get('reason', 'Unknown error'),
                "result": result
            }
    
    except Exception as e:
        print(f"[API] Error in trigger_retraining: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/model/retraining-status")
async def get_retraining_status():
    """Get retraining status"""
    try:
        status = model_retrainer.get_retraining_status()
        return status
    except Exception as e:
        print(f"[API] Error in get_retraining_status: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ===================== Main =====================

if __name__ == "__main__":
    import config
    
    print(f"""
    ============================================================
        Smart Alert AI Service - FastAPI Application
                        Version 1.0.0
    ============================================================
      API Documentation: http://localhost:{config.API_PORT}/docs
      Health Check:      http://localhost:{config.API_PORT}/api/v1/health
    ============================================================
    """)
    
    uvicorn.run(
        "main:app",
        host=config.API_HOST,
        port=config.API_PORT,
        reload=True,
        log_level="info"
    )

