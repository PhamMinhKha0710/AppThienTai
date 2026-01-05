"""
Hazard Prediction Model Training Script
Run this directly to train the XGBoost model for hazard zone prediction.

Usage:
  cd ai_service
  python train_hazard_model.py
"""
import json
import random
import math
import os
from datetime import datetime
from pathlib import Path

print("="*60)
print("  🌊 VIETNAM HAZARD ZONE PREDICTION - MODEL TRAINING")
print("="*60)

# Install dependencies if needed
try:
    import numpy as np
    import pandas as pd
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler
    from sklearn.ensemble import GradientBoostingClassifier
    from sklearn.metrics import accuracy_score, classification_report
    import joblib
except ImportError:
    print("Installing dependencies...")
    os.system("pip install numpy pandas scikit-learn joblib")
    import numpy as np
    import pandas as pd
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler
    from sklearn.ensemble import GradientBoostingClassifier
    from sklearn.metrics import accuracy_score, classification_report
    import joblib

# Vietnam provinces data
VIETNAM_PROVINCES = {
    "Hà Nội": {"lat": 21.0285, "lng": 105.8542, "region": "north", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Hải Phòng": {"lat": 20.8449, "lng": 106.6881, "region": "north", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 3},
    "Lào Cai": {"lat": 22.4809, "lng": 103.9755, "region": "north", "flood_risk": 4, "landslide_risk": 5, "storm_risk": 2},
    "Sơn La": {"lat": 21.3256, "lng": 103.9188, "region": "north", "flood_risk": 3, "landslide_risk": 5, "storm_risk": 2},
    "Hà Giang": {"lat": 22.8231, "lng": 104.9838, "region": "north", "flood_risk": 4, "landslide_risk": 5, "storm_risk": 1},
    "Thanh Hóa": {"lat": 19.8067, "lng": 105.7852, "region": "central", "flood_risk": 5, "landslide_risk": 3, "storm_risk": 4},
    "Nghệ An": {"lat": 19.2342, "lng": 104.9200, "region": "central", "flood_risk": 5, "landslide_risk": 4, "storm_risk": 4},
    "Hà Tĩnh": {"lat": 18.3559, "lng": 105.8877, "region": "central", "flood_risk": 5, "landslide_risk": 3, "storm_risk": 5},
    "Quảng Bình": {"lat": 17.4690, "lng": 106.6222, "region": "central", "flood_risk": 5, "landslide_risk": 4, "storm_risk": 5},
    "Quảng Trị": {"lat": 16.8163, "lng": 107.1003, "region": "central", "flood_risk": 5, "landslide_risk": 4, "storm_risk": 5},
    "Thừa Thiên Huế": {"lat": 16.4637, "lng": 107.5909, "region": "central", "flood_risk": 5, "landslide_risk": 4, "storm_risk": 5},
    "Đà Nẵng": {"lat": 16.0544, "lng": 108.2022, "region": "central", "flood_risk": 4, "landslide_risk": 2, "storm_risk": 4},
    "Quảng Nam": {"lat": 15.5735, "lng": 108.4741, "region": "central", "flood_risk": 5, "landslide_risk": 4, "storm_risk": 5},
    "Quảng Ngãi": {"lat": 15.1214, "lng": 108.8044, "region": "central", "flood_risk": 5, "landslide_risk": 3, "storm_risk": 4},
    "Bình Định": {"lat": 13.7765, "lng": 109.2234, "region": "central", "flood_risk": 4, "landslide_risk": 3, "storm_risk": 4},
    "Khánh Hòa": {"lat": 12.2585, "lng": 109.0526, "region": "central", "flood_risk": 4, "landslide_risk": 2, "storm_risk": 4},
    "Kon Tum": {"lat": 14.3497, "lng": 108.0005, "region": "highlands", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Gia Lai": {"lat": 13.9830, "lng": 108.0191, "region": "highlands", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Đắk Lắk": {"lat": 12.7100, "lng": 108.2378, "region": "highlands", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Lâm Đồng": {"lat": 11.9465, "lng": 108.4419, "region": "highlands", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "TP.HCM": {"lat": 10.8231, "lng": 106.6297, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Đồng Tháp": {"lat": 10.4938, "lng": 105.6882, "region": "south", "flood_risk": 5, "landslide_risk": 1, "storm_risk": 1},
    "An Giang": {"lat": 10.5216, "lng": 105.1259, "region": "south", "flood_risk": 5, "landslide_risk": 1, "storm_risk": 1},
    "Cần Thơ": {"lat": 10.0452, "lng": 105.7469, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 1},
    "Cà Mau": {"lat": 9.1527, "lng": 105.1961, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
}

SEASONAL_MULTIPLIERS = {
    1: (0.3, 0.2, 0.3), 2: (0.2, 0.1, 0.2), 3: (0.2, 0.1, 0.2), 4: (0.3, 0.2, 0.3),
    5: (0.5, 0.3, 0.5), 6: (0.6, 0.5, 0.6), 7: (0.7, 0.6, 0.7), 8: (0.8, 0.7, 0.8),
    9: (1.0, 0.9, 1.0), 10: (1.0, 1.0, 1.0), 11: (0.9, 0.8, 0.8), 12: (0.5, 0.4, 0.4),
}

def generate_training_data(num_samples=50000):
    """Generate large training dataset."""
    print(f"\n🔄 Generating {num_samples:,} training samples...")
    
    samples = []
    provinces_list = list(VIETNAM_PROVINCES.keys())
    regions = ['north', 'central', 'highlands', 'south']
    hazard_types = ['flood', 'landslide', 'storm']
    
    for i in range(num_samples):
        if i % 10000 == 0 and i > 0:
            print(f"  Progress: {i:,}/{num_samples:,}")
        
        province = random.choice(provinces_list)
        data = VIETNAM_PROVINCES[province]
        
        lat = data['lat'] + random.uniform(-0.5, 0.5)
        lng = data['lng'] + random.uniform(-0.5, 0.5)
        month = random.randint(1, 12)
        season_mult = SEASONAL_MULTIPLIERS[month]
        hazard_type = random.choice(hazard_types)
        hazard_type_id = hazard_types.index(hazard_type)
        
        if hazard_type == 'flood':
            base_risk = data['flood_risk']
            multiplier = season_mult[0]
        elif hazard_type == 'landslide':
            base_risk = data['landslide_risk']
            multiplier = season_mult[2]
        else:
            base_risk = data['storm_risk']
            multiplier = season_mult[1]
        
        adjusted_risk = base_risk * multiplier
        noise = random.uniform(-0.5, 0.5)
        final_risk = max(1, min(5, round(adjusted_risk + noise)))
        
        if month in [1, 2, 3, 4]:
            season = 0
        elif month in [5, 11, 12]:
            season = 1
        else:
            season = 2
        
        sample = {
            'lat': round(lat, 6),
            'lng': round(lng, 6),
            'province_id': provinces_list.index(province),
            'region_id': regions.index(data['region']),
            'month': month,
            'season': season,
            'hazard_type_id': hazard_type_id,
            'base_flood_risk': data['flood_risk'],
            'base_landslide_risk': data['landslide_risk'],
            'base_storm_risk': data['storm_risk'],
            'seasonal_multiplier': round(multiplier, 2),
            'risk_level': final_risk,
        }
        samples.append(sample)
    
    df = pd.DataFrame(samples)
    print(f"✅ Generated {len(df):,} samples")
    return df


def train_model():
    """Train the hazard prediction model."""
    
    # Generate data
    df = generate_training_data(num_samples=50000)
    
    # Features and target
    feature_columns = [
        'lat', 'lng', 'province_id', 'region_id', 'month', 'season',
        'hazard_type_id', 'base_flood_risk', 'base_landslide_risk',
        'base_storm_risk', 'seasonal_multiplier'
    ]
    
    X = df[feature_columns].values
    y = df['risk_level'].values
    
    # Split data
    print("\n📊 Splitting data...")
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    print(f"  Training: {X_train.shape[0]:,} samples")
    print(f"  Testing:  {X_test.shape[0]:,} samples")
    
    # Scale
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train
    print("\n🚀 Training GradientBoosting model...")
    print("  (This may take 1-2 minutes)")
    
    model = GradientBoostingClassifier(
        n_estimators=150,
        max_depth=6,
        learning_rate=0.1,
        subsample=0.8,
        random_state=42,
        verbose=1
    )
    
    model.fit(X_train_scaled, y_train)
    
    # Evaluate
    print("\n📈 Evaluating model...")
    y_pred = model.predict(X_test_scaled)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"\n✅ Model Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    print("\n📋 Classification Report:")
    print(classification_report(y_test, y_pred, 
          target_names=['Risk 1', 'Risk 2', 'Risk 3', 'Risk 4', 'Risk 5']))
    
    # Save model
    print("\n💾 Saving model...")
    models_dir = Path(__file__).parent / "data" / "models"
    models_dir.mkdir(parents=True, exist_ok=True)
    
    model_data = {
        'model': model,
        'scaler': scaler,
        'is_trained': True,
        'accuracy': accuracy,
        'trained_at': datetime.now().isoformat(),
        'num_samples': len(df),
        'feature_columns': feature_columns
    }
    
    model_path = models_dir / "hazard_predictor.pkl"
    joblib.dump(model_data, model_path)
    
    print(f"✅ Model saved to: {model_path}")
    
    # Test prediction
    print("\n🧪 Testing prediction...")
    test_locations = [
        ("Đà Nẵng", 16.0544, 108.2022, 10, 'flood'),
        ("Quảng Bình", 17.4690, 106.6222, 10, 'storm'),
        ("Lào Cai", 22.4809, 103.9755, 9, 'landslide'),
    ]
    
    risk_labels = {1: 'Rất thấp', 2: 'Thấp', 3: 'Trung bình', 4: 'Cao', 5: 'Rất cao'}
    
    for name, lat, lng, month, hazard in test_locations:
        provinces_list = list(VIETNAM_PROVINCES.keys())
        regions = ['north', 'central', 'highlands', 'south']
        hazard_types = ['flood', 'landslide', 'storm']
        
        prov_data = VIETNAM_PROVINCES.get(name, list(VIETNAM_PROVINCES.values())[0])
        
        features = [
            lat, lng,
            provinces_list.index(name) if name in provinces_list else 0,
            regions.index(prov_data['region']),
            month,
            0 if month in [1,2,3,4] else (1 if month in [5,11,12] else 2),
            hazard_types.index(hazard),
            prov_data['flood_risk'],
            prov_data['landslide_risk'],
            prov_data['storm_risk'],
            SEASONAL_MULTIPLIERS[month][hazard_types.index(hazard)]
        ]
        
        features_scaled = scaler.transform([features])
        risk = model.predict(features_scaled)[0]
        
        print(f"  📍 {name} ({hazard}, tháng {month}): Risk {risk} - {risk_labels[risk]}")
    
    print("\n" + "="*60)
    print("  ✅ TRAINING COMPLETE!")
    print("="*60)
    print(f"  Model saved to: {model_path}")
    print(f"  Accuracy: {accuracy*100:.2f}%")
    print("  Restart AI service to use new model")
    print("="*60)
    
    return model, scaler, accuracy


if __name__ == "__main__":
    train_model()
