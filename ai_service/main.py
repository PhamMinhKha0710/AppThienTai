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
from models.hazard_predictor import HazardZonePredictor
from models.weather_forecaster import WeatherForecaster  # NEW
from data_collectors.openmeteo_collector import OpenMeteoCollector
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
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize models and services (singleton pattern)
print("[API] Initializing models...")
scorer = AlertScoringModel(cold_start=True)
duplicate_detector = SemanticDuplicateDetector()
timing_model = NotificationTimingModel()
hazard_predictor = HazardZonePredictor(cold_start=True)
weather_forecaster = WeatherForecaster()  # NEW
weather_collector = OpenMeteoCollector(cache_enabled=True)
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


# Weather Schemas
class WeatherPredictRequest(BaseModel):
    """Request for weather prediction"""
    date: str = Field(..., description="YYYY-MM-DD")
    province_id: int = Field(..., description="Province ID (0-63)")
    region_id: int = Field(default=1, description="Region ID (0-3)")
    current_temp: Optional[float] = Field(default=30.0, description="Current temperature")
    current_humid: Optional[float] = Field(default=75.0, description="Current humidity")
    current_rain: Optional[float] = Field(default=0.0, description="Current rainfall mm")


class WeatherPredictResponse(BaseModel):
    """Response for weather prediction"""
    date: str
    temperature: float
    humidity: float
    rainfall: float
    note: Optional[str] = None


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
            "hazard": "/api/v1/hazard/predict",
            "weather": "/api/v1/weather/predict"  # NEW
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
            "timing_model": "loaded",
            "weather_forecaster": "loaded" if weather_forecaster.is_trained else "not_trained"
        },
        "database": "connected"
    }


@app.post("/api/v1/score", response_model=AlertScoreResponse)
async def score_alert(request: AlertScoreRequest):
    """
    Score alert priority using ML model
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


# ===================== Weather Prediction Endpoint =====================

@app.post("/api/v1/weather/predict", response_model=WeatherPredictResponse)
async def predict_weather(request: WeatherPredictRequest):
    """
    Predict next-day weather using AI model.
    """
    try:
        from datetime import datetime
        target_date = datetime.strptime(request.date, "%Y-%m-%d")
        
        current_weather = {
            'temp': request.current_temp,
            'humid': request.current_humid,
            'rain': request.current_rain
        }
        
        result = weather_forecaster.predict(
            date=target_date,
            province_id=request.province_id,
            region_id=request.region_id,
            current_weather=current_weather
        )
        
        return WeatherPredictResponse(**result)
    
    except Exception as e:
        print(f"[API] Error in predict_weather: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ===================== Hazard Zone Endpoints =====================

class HazardPredictRequest(BaseModel):
    """Request schema for hazard prediction"""
    lat: float = Field(..., description="Latitude")
    lng: float = Field(..., description="Longitude")
    month: Optional[int] = Field(default=None, description="Month (1-12), defaults to current")
    hazard_type: str = Field(default="flood", description="Hazard type: flood, landslide, storm")
    include_weather: bool = Field(default=True, description="Include real-time weather data")


class HazardPredictResponse(BaseModel):
    """Response schema for hazard prediction"""
    lat: float
    lng: float
    risk_level: int = Field(..., description="Risk level 1-5")
    risk_label: str
    confidence: float
    hazard_type: str
    month: int
    province: str
    explanation: str
    current_weather: Optional[Dict] = Field(default=None, description="Current weather conditions")
    forecast: Optional[Dict] = Field(default=None, description="Weather forecast")


class HazardZone(BaseModel):
    """Hazard zone for map display"""
    id: str
    lat: float
    lng: float
    radius_km: float
    hazard_type: str
    risk_level: int
    description: str


@app.post("/api/v1/hazard/predict", response_model=HazardPredictResponse)
async def predict_hazard_risk(request: HazardPredictRequest):
    """
    Predict hazard risk for a specific location.
    
    Returns risk level (1-5) based on:
    - Geographic location
    - Historical hazard patterns
    - Seasonal factors
    - Real-time weather data (if requested)
    """
    try:
        # Get base prediction
        result = hazard_predictor.predict_risk(
            lat=request.lat,
            lng=request.lng,
            month=request.month,
            hazard_type=request.hazard_type
        )
        
        # Enrich with real-time weather if requested
        if request.include_weather:
            try:
                # Get current weather
                current_weather_data = weather_collector.get_current_weather(
                    lat=request.lat,
                    lng=request.lng
                )
                
                # Get 7-day forecast
                forecast_data = weather_collector.get_forecast(
                    lat=request.lat,
                    lng=request.lng,
                    days=7
                )
                
                # Format weather for response
                if current_weather_data and 'current' in current_weather_data:
                    current = current_weather_data['current']
                    result['current_weather'] = {
                        'temperature': current.get('temperature_2m'),
                        'precipitation': current.get('precipitation', 0),
                        'rain': current.get('rain', 0),
                        'wind_speed': current.get('wind_speed_10m'),
                        'wind_gusts': current.get('wind_gusts_10m'),
                        'humidity': current.get('relative_humidity_2m'),
                        'cloud_cover': current.get('cloud_cover'),
                        'pressure': current.get('pressure_msl'),
                    }
                
                # Format forecast
                if forecast_data and 'daily' in forecast_data:
                    daily = forecast_data['daily']
                    result['forecast'] = {
                        'days': len(daily.get('time', [])),
                        'total_precipitation': sum(daily.get('precipitation_sum', [])),
                        'max_temperature': max(daily.get('temperature_2m_max', [20])),
                        'min_temperature': min(daily.get('temperature_2m_min', [15])),
                        'max_wind': max(daily.get('wind_speed_10m_max', [0])),
                    }
                    
                    # Adjust risk based on forecast
                    total_precip = sum(daily.get('precipitation_sum', []))
                    max_wind = max(daily.get('wind_speed_10m_max', [0]))
                    
                    # Increase risk if heavy rain forecast for flood/landslide
                    if request.hazard_type in ['flood', 'landslide']:
                        if total_precip > 200:  # >200mm in 7 days
                            result['risk_level'] = min(5, result['risk_level'] + 1)
                            result['explanation'] += f" ⚠️ Dự báo mưa lớn: {total_precip:.0f}mm trong 7 ngày tới!"
                        elif total_precip > 100:
                            result['explanation'] += f" Dự báo mưa: {total_precip:.0f}mm trong 7 ngày tới."
                    
                    # Increase risk if strong wind forecast for storm
                    if request.hazard_type == 'storm' and max_wind > 60:
                        result['risk_level'] = min(5, result['risk_level'] + 1)
                        result['explanation'] += f" ⚠️ Dự báo gió mạnh: {max_wind:.0f} km/h!"
                        
            except Exception as weather_error:
                print(f"[API] Warning: Could not fetch weather data: {weather_error}")
                # Continue without weather data
                pass
        
        return HazardPredictResponse(**result)
    
    except Exception as e:
        print(f"[API] Error in predict_hazard_risk: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/hazard/zones")
async def get_hazard_zones(
    province: Optional[str] = None,
    month: Optional[int] = None,
    hazard_type: Optional[str] = None,
    min_risk: int = 2
):
    """
    Get hazard zones for map display.
    
    Filters:
    - province: Filter by province name
    - month: Filter by active month (1-12)
    - hazard_type: flood, landslide, or storm
    - min_risk: Minimum risk level (default: 2)
    """
    try:
        zones = hazard_predictor.get_hazard_zones(
            province=province,
            month=month,
            hazard_type=hazard_type,
            min_risk=min_risk
        )
        
        # Format for Flutter map
        formatted_zones = [
            {
                'id': z['id'],
                'lat': z['center']['lat'],
                'lng': z['center']['lng'],
                'radius_km': z['radius_km'],
                'hazard_type': z['hazard_type'],
                'risk_level': z['risk_level'],
                'description': z['description']
            }
            for z in zones
        ]
        
        return {
            'total': len(formatted_zones),
            'month': month,
            'zones': formatted_zones
        }
    
    except Exception as e:
        print(f"[API] Error in get_hazard_zones: {e}")
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

