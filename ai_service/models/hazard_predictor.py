"""
Hazard Zone Predictor Model

ML model for predicting disaster hazard risk levels based on location and time.
Uses XGBoost for multi-class classification of risk levels (1-5).
"""
import json
import numpy as np
import joblib
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from datetime import datetime
import math

import sys
sys.path.append(str(Path(__file__).parent.parent))

try:
    from sklearn.ensemble import GradientBoostingClassifier
    from sklearn.preprocessing import StandardScaler, LabelEncoder
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    print("[HazardPredictor] Warning: scikit-learn not available, using rule-based fallback")


class HazardZonePredictor:
    """
    Hazard Zone Prediction Model
    
    Predicts disaster risk levels for any location in Vietnam based on:
    - Geographic location (lat, lng)
    - Province/region characteristics
    - Time of year (month, season)
    - Historical hazard patterns
    """
    
    def __init__(self, data_dir: Path = None, cold_start: bool = True):
        if data_dir is None:
            data_dir = Path(__file__).parent.parent / "data"
        
        self.data_dir = data_dir
        self.models_dir = data_dir / "models"
        self.models_dir.mkdir(parents=True, exist_ok=True)
        
        self.model = None
        self.scaler = None
        self.is_trained = False
        
        # Load hazard zones data
        self.hazard_zones = self._load_hazard_zones()
        
        # Try to load existing model
        if not self._load_model():
            if cold_start and HAS_SKLEARN:
                print("[HazardPredictor] No existing model, bootstrapping from data...")
                self._bootstrap_model()
            else:
                print("[HazardPredictor] Using rule-based prediction")
    
    def _load_hazard_zones(self) -> List[Dict]:
        """Load pre-generated hazard zones data."""
        zones_file = self.data_dir / "hazard_zones_data.json"
        
        if zones_file.exists():
            try:
                with open(zones_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    zones = data.get('zones', [])
                    print(f"[HazardPredictor] Loaded {len(zones)} hazard zones")
                    return zones
            except Exception as e:
                print(f"[HazardPredictor] Error loading zones: {e}")
        
        return []
    
    def _bootstrap_model(self):
        """Bootstrap model from training data or generate synthetic data."""
        training_file = self.data_dir / "hazard_training_data.json"
        
        if training_file.exists():
            print("[HazardPredictor] Loading training data from file...")
            with open(training_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                samples = data.get('samples', [])
        else:
            print("[HazardPredictor] Generating synthetic training data...")
            # Import and generate data
            try:
                from data_collectors.vietnam_hazard_dataset import VietnamHazardDataset
                dataset = VietnamHazardDataset(self.data_dir)
                samples = dataset.generate_training_data(num_samples=3000)
                dataset.save_training_data(samples)
            except ImportError:
                print("[HazardPredictor] Could not generate training data")
                return
        
        if not samples:
            print("[HazardPredictor] No training data available")
            return
        
        # Prepare features and target
        X = np.array([
            [
                s['lat'],
                s['lng'],
                s['province_id'],
                s['region_id'],
                s['month'],
                s['season'],
                s['hazard_type_id'],
                s['base_flood_risk'],
                s['base_landslide_risk'],
                s['base_storm_risk'],
                s['seasonal_multiplier']
            ]
            for s in samples
        ])
        y = np.array([s['risk_level'] for s in samples])
        
        # Train model
        print(f"[HazardPredictor] Training on {len(samples)} samples...")
        
        self.scaler = StandardScaler()
        X_scaled = self.scaler.fit_transform(X)
        
        self.model = GradientBoostingClassifier(
            n_estimators=100,
            max_depth=5,
            random_state=42
        )
        self.model.fit(X_scaled, y)
        self.is_trained = True
        
        print("[HazardPredictor] Model trained successfully")
        self.save()
    
    def predict_risk(
        self, 
        lat: float, 
        lng: float, 
        month: int = None,
        hazard_type: str = 'flood'
    ) -> Dict:
        """
        Predict hazard risk for a specific location.
        
        Args:
            lat: Latitude
            lng: Longitude  
            month: Month (1-12), defaults to current
            hazard_type: 'flood', 'landslide', or 'storm'
            
        Returns:
            Dict with risk_level, confidence, and details
        """
        if month is None:
            month = datetime.now().month
        
        # Get province info
        province_info = self._get_nearest_province(lat, lng)
        
        if self.is_trained and self.model is not None:
            # Use ML prediction
            features = self._extract_features(lat, lng, month, hazard_type, province_info)
            features_scaled = self.scaler.transform([features])
            
            risk_level = int(self.model.predict(features_scaled)[0])
            
            # Get confidence from probability
            proba = self.model.predict_proba(features_scaled)[0]
            confidence = float(max(proba))
        else:
            # Rule-based fallback
            risk_level, confidence = self._rule_based_prediction(
                lat, lng, month, hazard_type, province_info
            )
        
        return {
            'lat': lat,
            'lng': lng,
            'risk_level': risk_level,
            'risk_label': self._get_risk_label(risk_level),
            'confidence': round(confidence, 2),
            'hazard_type': hazard_type,
            'month': month,
            'province': province_info.get('province', 'Unknown'),
            'explanation': self._generate_explanation(risk_level, hazard_type, province_info)
        }
    
    def _extract_features(
        self, 
        lat: float, 
        lng: float, 
        month: int,
        hazard_type: str,
        province_info: Dict
    ) -> List[float]:
        """Extract features for ML prediction."""
        hazard_type_id = {'flood': 0, 'landslide': 1, 'storm': 2}.get(hazard_type, 0)
        season = self._get_season(month)
        seasonal_mult = self._get_seasonal_multiplier(month, hazard_type)
        
        return [
            lat,
            lng,
            province_info.get('province_id', 0),
            province_info.get('region_id', 0),
            month,
            season,
            hazard_type_id,
            province_info.get('flood_risk', 3),
            province_info.get('landslide_risk', 2),
            province_info.get('storm_risk', 2),
            seasonal_mult
        ]
    
    def _rule_based_prediction(
        self,
        lat: float,
        lng: float, 
        month: int,
        hazard_type: str,
        province_info: Dict
    ) -> Tuple[int, float]:
        """Rule-based prediction fallback."""
        base_risk_key = f'{hazard_type}_risk'
        base_risk = province_info.get(base_risk_key, 2)
        
        seasonal_mult = self._get_seasonal_multiplier(month, hazard_type)
        adjusted_risk = base_risk * seasonal_mult
        
        # Add some noise for realism
        noise = np.random.uniform(-0.3, 0.3)
        final_risk = max(1, min(5, round(adjusted_risk + noise)))
        
        confidence = 0.7 + (base_risk * 0.05)  # Higher base risk = more confident
        
        return int(final_risk), min(0.95, confidence)
    
    def _get_seasonal_multiplier(self, month: int, hazard_type: str) -> float:
        """Get seasonal multiplier for hazard type."""
        multipliers = {
            1: {'flood': 0.3, 'storm': 0.2, 'landslide': 0.3},
            2: {'flood': 0.2, 'storm': 0.1, 'landslide': 0.2},
            3: {'flood': 0.2, 'storm': 0.1, 'landslide': 0.2},
            4: {'flood': 0.3, 'storm': 0.2, 'landslide': 0.3},
            5: {'flood': 0.5, 'storm': 0.3, 'landslide': 0.5},
            6: {'flood': 0.6, 'storm': 0.5, 'landslide': 0.6},
            7: {'flood': 0.7, 'storm': 0.6, 'landslide': 0.7},
            8: {'flood': 0.8, 'storm': 0.7, 'landslide': 0.8},
            9: {'flood': 1.0, 'storm': 0.9, 'landslide': 1.0},
            10: {'flood': 1.0, 'storm': 1.0, 'landslide': 1.0},
            11: {'flood': 0.9, 'storm': 0.8, 'landslide': 0.8},
            12: {'flood': 0.5, 'storm': 0.4, 'landslide': 0.4},
        }
        return multipliers.get(month, {}).get(hazard_type, 0.5)
    
    def _get_season(self, month: int) -> int:
        """Get season from month."""
        if month in [1, 2, 3, 4]:
            return 0  # Dry
        elif month in [5, 11, 12]:
            return 1  # Transition
        else:
            return 2  # Wet/Storm
    
    def _get_nearest_province(self, lat: float, lng: float) -> Dict:
        """Find nearest province to coordinates."""
        # Import province data
        try:
            from data_collectors.vietnam_hazard_dataset import VIETNAM_PROVINCES
        except ImportError:
            return {'province': 'Unknown', 'province_id': 0, 'region_id': 0}
        
        nearest = None
        min_dist = float('inf')
        province_idx = 0
        
        provinces_list = list(VIETNAM_PROVINCES.keys())
        
        for idx, (province, data) in enumerate(VIETNAM_PROVINCES.items()):
            dist = self._haversine(lat, lng, data['lat'], data['lng'])
            if dist < min_dist:
                min_dist = dist
                nearest = province
                province_idx = idx
        
        if nearest:
            data = VIETNAM_PROVINCES[nearest]
            region_id = ['north', 'central', 'highlands', 'south'].index(data['region'])
            return {
                'province': nearest,
                'province_id': province_idx,
                'region': data['region'],
                'region_id': region_id,
                'flood_risk': data['flood_risk'],
                'landslide_risk': data['landslide_risk'],
                'storm_risk': data['storm_risk'],
                'distance_km': round(min_dist, 2)
            }
        
        return {'province': 'Unknown', 'province_id': 0, 'region_id': 0}
    
    def _haversine(self, lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """Calculate distance between two points in km."""
        R = 6371
        lat1_rad, lat2_rad = math.radians(lat1), math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lng = math.radians(lng2 - lng1)
        
        a = (math.sin(delta_lat/2)**2 + 
             math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lng/2)**2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c
    
    def _get_risk_label(self, risk_level: int) -> str:
        """Get human-readable risk label."""
        labels = {
            1: 'very_low',
            2: 'low', 
            3: 'medium',
            4: 'high',
            5: 'very_high'
        }
        return labels.get(risk_level, 'unknown')
    
    def _generate_explanation(self, risk_level: int, hazard_type: str, province_info: Dict) -> str:
        """Generate explanation for prediction."""
        province = province_info.get('province', 'khu vực này')
        risk_text = {
            1: 'Rất thấp',
            2: 'Thấp',
            3: 'Trung bình',
            4: 'Cao',
            5: 'Rất cao'
        }.get(risk_level, 'Không xác định')
        
        hazard_text = {
            'flood': 'ngập lụt',
            'landslide': 'sạt lở đất',
            'storm': 'bão'
        }.get(hazard_type, 'thiên tai')
        
        return f"Nguy cơ {hazard_text} mức {risk_text} tại {province}"
    
    def get_hazard_zones(
        self,
        province: str = None,
        month: int = None,
        hazard_type: str = None,
        min_risk: int = 1
    ) -> List[Dict]:
        """
        Get hazard zones filtered by criteria.
        
        Args:
            province: Filter by province name
            month: Filter by active month (None = show all regardless of month)
            hazard_type: Filter by hazard type
            min_risk: Minimum risk level to include
            
        Returns:
            List of matching hazard zones
        """
        # Note: month=None means show all zones regardless of active month
        # This allows showing all zones on the map year-round
        
        filtered = []
        
        for zone in self.hazard_zones:
            # Filter by province
            if province and zone.get('province') != province:
                continue
            
            # Filter by month ONLY if explicitly specified
            if month is not None and month not in zone.get('active_months', []):
                continue
            
            # Filter by hazard type
            if hazard_type and zone.get('hazard_type') != hazard_type:
                continue
            
            # Filter by min risk
            if zone.get('risk_level', 0) < min_risk:
                continue
            
            filtered.append(zone)
        
        return filtered
    
    def get_all_zones_for_map(self, month: int = None) -> List[Dict]:
        """
        Get all hazard zones formatted for map display.
        
        Returns zones with only essential fields for Flutter map rendering.
        """
        if month is None:
            month = datetime.now().month
        
        zones = self.get_hazard_zones(month=month, min_risk=2)
        
        return [
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
    
    def save(self):
        """Save trained model to disk."""
        if not self.is_trained:
            return
        
        model_path = self.models_dir / "hazard_predictor.pkl"
        model_data = {
            'model': self.model,
            'scaler': self.scaler,
            'is_trained': self.is_trained
        }
        
        joblib.dump(model_data, model_path)
        print(f"[HazardPredictor] Model saved to {model_path}")
    
    def _load_model(self) -> bool:
        """Load model from disk."""
        model_path = self.models_dir / "hazard_predictor.pkl"
        
        if not model_path.exists():
            return False
        
        try:
            model_data = joblib.load(model_path)
            self.model = model_data['model']
            self.scaler = model_data['scaler']
            self.is_trained = model_data['is_trained']
            print(f"[HazardPredictor] Model loaded from {model_path}")
            return True
        except Exception as e:
            print(f"[HazardPredictor] Error loading model: {e}")
            return False


if __name__ == "__main__":
    # Test the predictor
    predictor = HazardZonePredictor(cold_start=True)
    
    # Test prediction
    result = predictor.predict_risk(
        lat=16.0544,  # Đà Nẵng
        lng=108.2022,
        month=10,
        hazard_type='flood'
    )
    
    print("\n" + "="*60)
    print("  TEST PREDICTION")
    print("="*60)
    print(f"  Location: {result['province']} ({result['lat']}, {result['lng']})")
    print(f"  Hazard Type: {result['hazard_type']}")
    print(f"  Risk Level: {result['risk_level']} ({result['risk_label']})")
    print(f"  Confidence: {result['confidence']}")
    print(f"  Explanation: {result['explanation']}")
    
    # Test zones
    zones = predictor.get_all_zones_for_map(month=10)
    print(f"\n  Total hazard zones for October: {len(zones)}")
