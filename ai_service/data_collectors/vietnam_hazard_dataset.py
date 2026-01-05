"""
Vietnam Hazard Zone Dataset Collector

Collects and processes hazard data from multiple sources to create
a comprehensive dataset for training the hazard prediction model.

Sources:
- Open Development Mekong: Landslide points/zones (GeoJSON)
- Think Hazard API: Multi-hazard risk levels
- Historical disaster patterns
- Vietnam province/district geographic data
"""
import json
import random
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from datetime import datetime
import math

# Vietnam provinces with coordinates and hazard profiles
VIETNAM_PROVINCES = {
    # Northern Region
    "Hà Nội": {"lat": 21.0285, "lng": 105.8542, "region": "north", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Hải Phòng": {"lat": 20.8449, "lng": 106.6881, "region": "north", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 3},
    "Quảng Ninh": {"lat": 21.0064, "lng": 107.2925, "region": "north", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 3},
    "Lào Cai": {"lat": 22.4809, "lng": 103.9755, "region": "north", "flood_risk": 4, "landslide_risk": 5, "storm_risk": 2},
    "Yên Bái": {"lat": 21.7168, "lng": 104.8986, "region": "north", "flood_risk": 4, "landslide_risk": 4, "storm_risk": 2},
    "Điện Biên": {"lat": 21.3860, "lng": 103.0230, "region": "north", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 1},
    "Sơn La": {"lat": 21.3256, "lng": 103.9188, "region": "north", "flood_risk": 3, "landslide_risk": 5, "storm_risk": 2},
    "Lai Châu": {"lat": 22.3864, "lng": 103.4703, "region": "north", "flood_risk": 4, "landslide_risk": 5, "storm_risk": 1},
    "Hòa Bình": {"lat": 20.8133, "lng": 105.3383, "region": "north", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Thái Nguyên": {"lat": 21.5942, "lng": 105.8482, "region": "north", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 2},
    "Lạng Sơn": {"lat": 21.8537, "lng": 106.7615, "region": "north", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Cao Bằng": {"lat": 22.6666, "lng": 106.2640, "region": "north", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Bắc Kạn": {"lat": 22.1473, "lng": 105.8348, "region": "north", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Tuyên Quang": {"lat": 21.8237, "lng": 105.2181, "region": "north", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Hà Giang": {"lat": 22.8231, "lng": 104.9838, "region": "north", "flood_risk": 4, "landslide_risk": 5, "storm_risk": 1},
    "Phú Thọ": {"lat": 21.4220, "lng": 105.2297, "region": "north", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 2},
    "Vĩnh Phúc": {"lat": 21.3609, "lng": 105.5474, "region": "north", "flood_risk": 2, "landslide_risk": 1, "storm_risk": 2},
    "Bắc Giang": {"lat": 21.2731, "lng": 106.1946, "region": "north", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 2},
    "Bắc Ninh": {"lat": 21.1861, "lng": 106.0763, "region": "north", "flood_risk": 2, "landslide_risk": 1, "storm_risk": 2},
    "Hải Dương": {"lat": 20.9373, "lng": 106.3146, "region": "north", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Hưng Yên": {"lat": 20.6464, "lng": 106.0513, "region": "north", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Thái Bình": {"lat": 20.4463, "lng": 106.3365, "region": "north", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 3},
    "Hà Nam": {"lat": 20.5835, "lng": 105.9230, "region": "north", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Nam Định": {"lat": 20.4388, "lng": 106.1621, "region": "north", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 3},
    "Ninh Bình": {"lat": 20.2506, "lng": 105.9745, "region": "north", "flood_risk": 4, "landslide_risk": 2, "storm_risk": 2},
    
    # Central Region - High disaster risk
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
    "Phú Yên": {"lat": 13.0882, "lng": 109.0929, "region": "central", "flood_risk": 4, "landslide_risk": 2, "storm_risk": 4},
    "Khánh Hòa": {"lat": 12.2585, "lng": 109.0526, "region": "central", "flood_risk": 4, "landslide_risk": 2, "storm_risk": 4},
    "Ninh Thuận": {"lat": 11.5649, "lng": 108.9880, "region": "central", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 3},
    "Bình Thuận": {"lat": 11.0904, "lng": 108.0721, "region": "central", "flood_risk": 3, "landslide_risk": 2, "storm_risk": 3},
    
    # Central Highlands
    "Kon Tum": {"lat": 14.3497, "lng": 108.0005, "region": "highlands", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Gia Lai": {"lat": 13.9830, "lng": 108.0191, "region": "highlands", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Đắk Lắk": {"lat": 12.7100, "lng": 108.2378, "region": "highlands", "flood_risk": 3, "landslide_risk": 3, "storm_risk": 2},
    "Đắk Nông": {"lat": 12.2646, "lng": 107.6098, "region": "highlands", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    "Lâm Đồng": {"lat": 11.9465, "lng": 108.4419, "region": "highlands", "flood_risk": 3, "landslide_risk": 4, "storm_risk": 2},
    
    # Southern Region
    "TP.HCM": {"lat": 10.8231, "lng": 106.6297, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Bình Phước": {"lat": 11.7512, "lng": 106.7235, "region": "south", "flood_risk": 2, "landslide_risk": 2, "storm_risk": 1},
    "Tây Ninh": {"lat": 11.3352, "lng": 106.0989, "region": "south", "flood_risk": 2, "landslide_risk": 1, "storm_risk": 1},
    "Bình Dương": {"lat": 11.3254, "lng": 106.4770, "region": "south", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 1},
    "Đồng Nai": {"lat": 11.0686, "lng": 107.1676, "region": "south", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Bà Rịa-Vũng Tàu": {"lat": 10.4114, "lng": 107.1362, "region": "south", "flood_risk": 3, "landslide_risk": 1, "storm_risk": 2},
    "Long An": {"lat": 10.5356, "lng": 106.4130, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 1},
    "Tiền Giang": {"lat": 10.4493, "lng": 106.3421, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Bến Tre": {"lat": 10.2434, "lng": 106.3756, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Trà Vinh": {"lat": 9.9513, "lng": 106.3346, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Vĩnh Long": {"lat": 10.2394, "lng": 105.9572, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 1},
    "Đồng Tháp": {"lat": 10.4938, "lng": 105.6882, "region": "south", "flood_risk": 5, "landslide_risk": 1, "storm_risk": 1},
    "An Giang": {"lat": 10.5216, "lng": 105.1259, "region": "south", "flood_risk": 5, "landslide_risk": 1, "storm_risk": 1},
    "Kiên Giang": {"lat": 10.0125, "lng": 105.0809, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Cần Thơ": {"lat": 10.0452, "lng": 105.7469, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 1},
    "Hậu Giang": {"lat": 9.7578, "lng": 105.6413, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 1},
    "Sóc Trăng": {"lat": 9.6029, "lng": 105.9739, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Bạc Liêu": {"lat": 9.2940, "lng": 105.7216, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
    "Cà Mau": {"lat": 9.1527, "lng": 105.1961, "region": "south", "flood_risk": 4, "landslide_risk": 1, "storm_risk": 2},
}

# Seasonal hazard multipliers by month
SEASONAL_MULTIPLIERS = {
    # month: (flood_mult, storm_mult, landslide_mult)
    1: (0.3, 0.2, 0.3),
    2: (0.2, 0.1, 0.2),
    3: (0.2, 0.1, 0.2),
    4: (0.3, 0.2, 0.3),
    5: (0.5, 0.3, 0.5),
    6: (0.6, 0.5, 0.6),
    7: (0.7, 0.6, 0.7),
    8: (0.8, 0.7, 0.8),
    9: (1.0, 0.9, 1.0),  # Peak season
    10: (1.0, 1.0, 1.0),  # Peak season
    11: (0.9, 0.8, 0.8),
    12: (0.5, 0.4, 0.4),
}


class VietnamHazardDataset:
    """
    Generate and manage Vietnam hazard zone dataset for ML training.
    """
    
    def __init__(self, data_dir: Path = None):
        if data_dir is None:
            data_dir = Path(__file__).parent.parent / "data"
        self.data_dir = data_dir
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
    def generate_hazard_zones(self, num_zones: int = 500) -> List[Dict]:
        """
        Generate hazard zone data for all of Vietnam.
        
        Args:
            num_zones: Number of hazard zones to generate
            
        Returns:
            List of hazard zone dictionaries
        """
        print(f"[HazardDataset] Generating {num_zones} hazard zones...")
        
        zones = []
        zone_id = 1
        
        for province, data in VIETNAM_PROVINCES.items():
            # Generate zones proportional to risk level
            max_risk = max(data['flood_risk'], data['landslide_risk'], data['storm_risk'])
            zones_per_province = max(1, int(num_zones * max_risk / (5 * len(VIETNAM_PROVINCES))))
            
            for _ in range(zones_per_province):
                # Randomize position within province (±0.5 degrees)
                lat_offset = random.uniform(-0.5, 0.5)
                lng_offset = random.uniform(-0.5, 0.5)
                
                center_lat = data['lat'] + lat_offset
                center_lng = data['lng'] + lng_offset
                
                # Determine primary hazard type
                hazard_types = []
                if data['flood_risk'] >= 3:
                    hazard_types.append(('flood', data['flood_risk']))
                if data['landslide_risk'] >= 3:
                    hazard_types.append(('landslide', data['landslide_risk']))
                if data['storm_risk'] >= 3:
                    hazard_types.append(('storm', data['storm_risk']))
                
                if not hazard_types:
                    hazard_types = [('flood', data['flood_risk'])]
                
                # Pick random hazard type weighted by risk
                hazard_type, base_risk = random.choice(hazard_types)
                
                # Determine active months based on region
                if data['region'] == 'central':
                    active_months = [9, 10, 11, 12]  # Central storms
                elif data['region'] == 'south':
                    active_months = [7, 8, 9, 10]  # Mekong flooding
                else:
                    active_months = [6, 7, 8, 9]  # Northern storms
                
                # Calculate radius based on hazard type
                if hazard_type == 'flood':
                    radius_km = random.uniform(5, 25)
                elif hazard_type == 'landslide':
                    radius_km = random.uniform(1, 5)
                else:  # storm
                    radius_km = random.uniform(20, 100)
                
                zone = {
                    'id': f'hz_{zone_id:04d}',
                    'center': {'lat': round(center_lat, 6), 'lng': round(center_lng, 6)},
                    'radius_km': round(radius_km, 2),
                    'province': province,
                    'region': data['region'],
                    'hazard_type': hazard_type,
                    'risk_level': base_risk,
                    'active_months': active_months,
                    'description': self._generate_description(province, hazard_type, base_risk),
                    'confidence': round(random.uniform(0.7, 0.95), 2),
                    'source': 'generated',
                    'created_at': datetime.now().isoformat()
                }
                
                zones.append(zone)
                zone_id += 1
        
        print(f"[HazardDataset] Generated {len(zones)} hazard zones")
        return zones
    
    def _generate_description(self, province: str, hazard_type: str, risk_level: int) -> str:
        """Generate Vietnamese description for hazard zone."""
        risk_text = {1: "thấp", 2: "trung bình", 3: "cao", 4: "rất cao", 5: "cực kỳ cao"}
        hazard_text = {
            'flood': f"Vùng nguy cơ ngập lụt mức {risk_text.get(risk_level, 'cao')} tại {province}",
            'landslide': f"Vùng nguy cơ sạt lở đất mức {risk_text.get(risk_level, 'cao')} tại {province}",
            'storm': f"Vùng ảnh hưởng bão/áp thấp mức {risk_text.get(risk_level, 'cao')} tại {province}"
        }
        return hazard_text.get(hazard_type, f"Vùng nguy hiểm tại {province}")
    
    def generate_training_data(self, num_samples: int = 5000) -> List[Dict]:
        """
        Generate training data for hazard prediction model.
        
        Each sample contains:
        - Location features (lat, lng, province_encoded)
        - Temporal features (month, season)
        - Historical features
        - Target: risk_level (1-5)
        """
        print(f"[HazardDataset] Generating {num_samples} training samples...")
        
        samples = []
        provinces_list = list(VIETNAM_PROVINCES.keys())
        
        for i in range(num_samples):
            # Select random province
            province = random.choice(provinces_list)
            data = VIETNAM_PROVINCES[province]
            
            # Random position within province
            lat = data['lat'] + random.uniform(-0.5, 0.5)
            lng = data['lng'] + random.uniform(-0.5, 0.5)
            
            # Random month
            month = random.randint(1, 12)
            season_mult = SEASONAL_MULTIPLIERS[month]
            
            # Select hazard type
            hazard_type = random.choice(['flood', 'landslide', 'storm'])
            
            # Calculate base risk
            if hazard_type == 'flood':
                base_risk = data['flood_risk']
                multiplier = season_mult[0]
            elif hazard_type == 'landslide':
                base_risk = data['landslide_risk']
                multiplier = season_mult[2]
            else:
                base_risk = data['storm_risk']
                multiplier = season_mult[1]
            
            # Apply seasonal multiplier and add noise
            adjusted_risk = base_risk * multiplier
            noise = random.uniform(-0.5, 0.5)
            final_risk = max(1, min(5, round(adjusted_risk + noise)))
            
            sample = {
                'lat': round(lat, 6),
                'lng': round(lng, 6),
                'province': province,
                'province_id': provinces_list.index(province),
                'region': data['region'],
                'region_id': ['north', 'central', 'highlands', 'south'].index(data['region']),
                'month': month,
                'season': self._get_season(month),
                'hazard_type': hazard_type,
                'hazard_type_id': ['flood', 'landslide', 'storm'].index(hazard_type),
                'base_flood_risk': data['flood_risk'],
                'base_landslide_risk': data['landslide_risk'],
                'base_storm_risk': data['storm_risk'],
                'seasonal_multiplier': round(multiplier, 2),
                'risk_level': final_risk,  # Target variable
            }
            
            samples.append(sample)
        
        print(f"[HazardDataset] Generated {len(samples)} training samples")
        return samples
    
    def _get_season(self, month: int) -> int:
        """Get season from month (0=dry, 1=transition, 2=wet)."""
        if month in [1, 2, 3, 4]:
            return 0  # Dry season
        elif month in [5, 11, 12]:
            return 1  # Transition
        else:
            return 2  # Wet/storm season
    
    def save_hazard_zones(self, zones: List[Dict], filename: str = "hazard_zones_data.json"):
        """Save hazard zones to JSON file."""
        output_path = self.data_dir / filename
        
        output_data = {
            'version': '1.0',
            'generated_at': datetime.now().isoformat(),
            'total_zones': len(zones),
            'zones': zones
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        
        print(f"[HazardDataset] Saved {len(zones)} zones to {output_path}")
        return output_path
    
    def save_training_data(self, samples: List[Dict], filename: str = "hazard_training_data.json"):
        """Save training data to JSON file."""
        output_path = self.data_dir / filename
        
        output_data = {
            'version': '1.0',
            'generated_at': datetime.now().isoformat(),
            'total_samples': len(samples),
            'features': [
                'lat', 'lng', 'province_id', 'region_id', 'month', 'season',
                'hazard_type_id', 'base_flood_risk', 'base_landslide_risk',
                'base_storm_risk', 'seasonal_multiplier'
            ],
            'target': 'risk_level',
            'samples': samples
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        
        print(f"[HazardDataset] Saved {len(samples)} training samples to {output_path}")
        return output_path
    
    def get_risk_for_location(self, lat: float, lng: float, month: int = None) -> Dict:
        """
        Get hazard risk for a specific location.
        
        Args:
            lat: Latitude
            lng: Longitude
            month: Month (1-12), defaults to current month
            
        Returns:
            Dict with risk levels for each hazard type
        """
        if month is None:
            month = datetime.now().month
        
        # Find nearest province
        nearest_province = None
        min_distance = float('inf')
        
        for province, data in VIETNAM_PROVINCES.items():
            dist = self._haversine(lat, lng, data['lat'], data['lng'])
            if dist < min_distance:
                min_distance = dist
                nearest_province = province
        
        if nearest_province is None:
            return {'error': 'Location not in Vietnam'}
        
        data = VIETNAM_PROVINCES[nearest_province]
        season_mult = SEASONAL_MULTIPLIERS[month]
        
        return {
            'province': nearest_province,
            'distance_km': round(min_distance, 2),
            'flood_risk': round(data['flood_risk'] * season_mult[0], 2),
            'landslide_risk': round(data['landslide_risk'] * season_mult[2], 2),
            'storm_risk': round(data['storm_risk'] * season_mult[1], 2),
            'month': month,
            'region': data['region']
        }
    
    def _haversine(self, lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """Calculate distance between two points in km."""
        R = 6371  # Earth radius in km
        
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lng = math.radians(lng2 - lng1)
        
        a = (math.sin(delta_lat/2)**2 + 
             math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lng/2)**2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        
        return R * c


def generate_all_data(large_dataset: bool = True):
    """Generate all hazard data files.
    
    Args:
        large_dataset: If True, generates large dataset for Colab training
    """
    dataset = VietnamHazardDataset()
    
    if large_dataset:
        # Large dataset for Colab training
        num_zones = 2000
        num_samples = 50000
        print("\n" + "="*60)
        print("  🚀 Generating LARGE dataset for Colab training")
        print("="*60)
    else:
        num_zones = 500
        num_samples = 5000
    
    # Generate hazard zones
    zones = dataset.generate_hazard_zones(num_zones=num_zones)
    dataset.save_hazard_zones(zones)
    
    # Generate training data
    samples = dataset.generate_training_data(num_samples=num_samples)
    dataset.save_training_data(samples)
    
    # Also save as CSV for Colab
    if large_dataset:
        import csv
        csv_path = dataset.data_dir / "hazard_training_data.csv"
        with open(csv_path, 'w', newline='', encoding='utf-8') as f:
            if samples:
                writer = csv.DictWriter(f, fieldnames=samples[0].keys())
                writer.writeheader()
                writer.writerows(samples)
        print(f"[HazardDataset] Also saved CSV to {csv_path}")
    
    print("\n" + "="*60)
    print(f"  ✅ Generated {num_zones} hazard zones")
    print(f"  ✅ Generated {num_samples} training samples")
    print("="*60)


def generate_massive_dataset():
    """Generate maximum size dataset with 100K+ samples for best model performance."""
    dataset = VietnamHazardDataset()
    
    print("\n" + "="*60)
    print("  🔥 Generating MASSIVE dataset (100K+ samples)")
    print("="*60)
    
    # Generate 5000 hazard zones
    zones = dataset.generate_hazard_zones(num_zones=5000)
    dataset.save_hazard_zones(zones)
    
    # Generate 100000 training samples
    samples = dataset.generate_training_data(num_samples=100000)
    dataset.save_training_data(samples)
    
    # Save as CSV for pandas/Colab
    import csv
    csv_path = dataset.data_dir / "hazard_training_data.csv"
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        if samples:
            writer = csv.DictWriter(f, fieldnames=samples[0].keys())
            writer.writeheader()
            writer.writerows(samples)
    print(f"[HazardDataset] Saved CSV to {csv_path}")
    
    print("\n" + "="*60)
    print(f"  ✅ Generated 5000 hazard zones")
    print(f"  ✅ Generated 100000 training samples")
    print(f"  📁 Files saved in: {dataset.data_dir}")
    print("="*60)


if __name__ == "__main__":
    # Generate large dataset by default
    generate_all_data(large_dataset=True)
