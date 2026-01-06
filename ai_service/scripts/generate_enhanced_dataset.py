"""
Generate Enhanced Training Dataset with Real Historical Weather Data

This script creates a training dataset by:
1. Using Vietnam province data as base
2. Enriching with REAL historical weather from Open-Meteo (100% free!)
3. Adding temporal features
4. Creating labeled samples for training

This will replace the synthetic data with real weather patterns.
"""
import sys
from pathlib import Path
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import time
import random

sys.path.append(str(Path(__file__).parent.parent))

from data_collectors.openmeteo_collector import OpenMeteoCollector
from data_collectors.vietnam_hazard_dataset import VIETNAM_PROVINCES
from config import DATA_DIR

# Output directory
ENHANCED_DATA_DIR = DATA_DIR / "enhanced"
ENHANCED_DATA_DIR.mkdir(parents=True, exist_ok=True)


def generate_enhanced_samples(
    num_samples: int = 5000,
    start_date: str = "2020-01-01",
    end_date: str = "2024-01-01",
    with_weather: bool = True
):
    """
    Generate training samples with real historical weather
    
    Args:
        num_samples: Number of samples to generate
        start_date: Start date for historical data
        end_date: End date for historical data
        with_weather: Whether to fetch real weather data (slower)
    """
    print("=" * 70)
    print("  🌟 ENHANCED DATASET GENERATOR WITH REAL WEATHER DATA")
    print("=" * 70)
    print(f"\n📊 Configuration:")
    print(f"  Samples: {num_samples}")
    print(f"  Date range: {start_date} to {end_date}")
    print(f"  Real weather: {'Yes (using Open-Meteo)' if with_weather else 'No'}")
    print(f"  Provinces: {len(VIETNAM_PROVINCES)}")
    
    collector = OpenMeteoCollector(cache_enabled=True) if with_weather else None
    
    samples = []
    provinces_list = list(VIETNAM_PROVINCES.keys())
    
    # Convert dates
    start = datetime.fromisoformat(start_date)
    end = datetime.fromisoformat(end_date)
    date_range_days = (end - start).days
    
    print(f"\n🔄 Generating {num_samples} samples...")
    
    for i in range(num_samples):
        if (i + 1) % 100 == 0:
            print(f"  Progress: {i+1}/{num_samples} ({(i+1)/num_samples*100:.1f}%)")
        
        # Select random province
        province = random.choice(provinces_list)
        province_data = VIETNAM_PROVINCES[province]
        
        # Random position within province
        lat = province_data['lat'] + random.uniform(-0.5, 0.5)
        lng = province_data['lng'] + random.uniform(-0.5, 0.5)
        
        # Random date
        random_days = random.randint(0, date_range_days)
        sample_date = start + timedelta(days=random_days)
        month = sample_date.month
        
        # Hazard type
        hazard_type = random.choice(['flood', 'landslide', 'storm'])
        hazard_type_id = ['flood', 'landslide', 'storm'].index(hazard_type)
        
        # Base features
        province_id = provinces_list.index(province)
        region_id = ['north', 'central', 'highlands', 'south'].index(province_data['region'])
        season = get_season(month)
        
        # Base risk from province
        base_flood_risk = province_data['flood_risk']
        base_landslide_risk = province_data['landslide_risk']
        base_storm_risk = province_data['storm_risk']
        
        # Sample data
        sample = {
            'lat': round(lat, 6),
            'lng': round(lng, 6),
            'province': province,
            'province_id': province_id,
            'region': province_data['region'],
            'region_id': region_id,
            'date': sample_date.strftime('%Y-%m-%d'),
            'month': month,
            'season': season,
            'hazard_type': hazard_type,
            'hazard_type_id': hazard_type_id,
            'base_flood_risk': base_flood_risk,
            'base_landslide_risk': base_landslide_risk,
            'base_storm_risk': base_storm_risk,
        }
        
        # Fetch REAL weather data if requested
        if with_weather and collector:
            try:
                # Get weather 30 days before the sample date
                lookback_start = sample_date - timedelta(days=30)
                
                weather_summary = collector.get_weather_for_disaster_event(
                    lat, lng,
                    sample_date.strftime('%Y-%m-%d'),
                    lookback_days=30
                )
                
                if weather_summary:
                    # Add weather features
                    sample.update({
                        'weather_avg_temp': round(weather_summary.get('avg_temperature', 25), 2),
                        'weather_max_temp': round(weather_summary.get('max_temperature', 30), 2),
                        'weather_min_temp': round(weather_summary.get('min_temperature', 20), 2),
                        'weather_total_precip_30d': round(weather_summary.get('total_precipitation', 0), 2),
                        'weather_max_daily_precip': round(weather_summary.get('max_daily_precipitation', 0), 2),
                        'weather_avg_wind': round(weather_summary.get('avg_wind_speed', 10), 2),
                        'weather_max_wind': round(weather_summary.get('max_wind_speed', 20), 2),
                        'weather_days_with_rain': int(weather_summary.get('days_with_rain', 0)),
                        'weather_days_heavy_rain': int(weather_summary.get('days_with_heavy_rain', 0)),
                    })
                else:
                    # Use defaults if weather fetch fails
                    sample.update(get_default_weather_features())
                
                # Small delay to avoid rate limiting
                if (i + 1) % 10 == 0:
                    time.sleep(0.1)
                    
            except Exception as e:
                print(f"  ⚠️ Weather fetch failed for sample {i+1}: {e}")
                sample.update(get_default_weather_features())
        else:
            # Use default weather features
            sample.update(get_default_weather_features())
        
        # Calculate risk level based on features
        sample['risk_level'] = calculate_risk_level(sample, province_data)
        
        samples.append(sample)
    
    print(f"\n✅ Generated {len(samples)} samples")
    
    # Convert to DataFrame
    df = pd.DataFrame(samples)
    
    # Save to CSV
    output_file = ENHANCED_DATA_DIR / f"enhanced_training_data_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    df.to_csv(output_file, index=False)
    
    print(f"\n📁 Saved to: {output_file}")
    print(f"   Size: {output_file.stat().st_size / 1024:.1f} KB")
    print(f"   Rows: {len(df)}")
    print(f"   Columns: {len(df.columns)}")
    
    # Summary statistics
    print(f"\n📊 Dataset Summary:")
    print(f"   Risk levels distribution:")
    for level in sorted(df['risk_level'].unique()):
        count = len(df[df['risk_level'] == level])
        print(f"     Level {level}: {count} ({count/len(df)*100:.1f}%)")
    
    print(f"\n   Hazard types distribution:")
    for htype in df['hazard_type'].unique():
        count = len(df[df['hazard_type'] == htype])
        print(f"     {htype}: {count} ({count/len(df)*100:.1f}%)")
    
    if with_weather:
        print(f"\n   Weather statistics:")
        print(f"     Avg precipitation (30d): {df['weather_total_precip_30d'].mean():.1f} mm")
        print(f"     Max precipitation (1d): {df['weather_max_daily_precip'].mean():.1f} mm")
        print(f"     Avg temperature: {df['weather_avg_temp'].mean():.1f}°C")
    
    print("\n" + "=" * 70)
    
    return df, output_file


def get_season(month: int) -> int:
    """Get season from month (0=dry, 1=transition, 2=wet)"""
    if month in [1, 2, 3, 4]:
        return 0  # Dry season
    elif month in [5, 11, 12]:
        return 1  # Transition
    else:
        return 2  # Wet/storm season


def get_default_weather_features() -> dict:
    """Get default weather features (used when API fetch fails)"""
    return {
        'weather_avg_temp': 25.0,
        'weather_max_temp': 30.0,
        'weather_min_temp': 20.0,
        'weather_total_precip_30d': 100.0,
        'weather_max_daily_precip': 20.0,
        'weather_avg_wind': 10.0,
        'weather_max_wind': 20.0,
        'weather_days_with_rain': 10,
        'weather_days_heavy_rain': 1,
    }


def calculate_risk_level(sample: dict, province_data: dict) -> int:
    """
    Calculate risk level based on features
    
    Uses:
    - Base risk from province
    - Weather conditions (if available)
    - Season
    - Hazard type
    """
    hazard_type = sample['hazard_type']
    month = sample['month']
    
    # Get base risk
    base_risk = province_data.get(f'{hazard_type}_risk', 3)
    
    # Seasonal multiplier (higher risk in wet season)
    seasonal_multipliers = {
        0: 0.5,  # Dry season - lower risk
        1: 0.8,  # Transition
        2: 1.2,  # Wet season - higher risk
    }
    seasonal_factor = seasonal_multipliers.get(sample['season'], 1.0)
    
    # Weather adjustment (if available)
    weather_factor = 1.0
    if 'weather_total_precip_30d' in sample:
        # High precipitation increases flood/landslide risk
        if hazard_type in ['flood', 'landslide']:
            if sample['weather_total_precip_30d'] > 300:
                weather_factor = 1.3
            elif sample['weather_total_precip_30d'] > 150:
                weather_factor = 1.1
        
        # High wind increases storm risk
        if hazard_type == 'storm':
            if sample.get('weather_max_wind', 0) > 60:
                weather_factor = 1.3
            elif sample.get('weather_max_wind', 0) > 40:
                weather_factor = 1.1
    
    # Calculate final risk
    risk_value = base_risk * seasonal_factor * weather_factor
    
    # Add some random noise
    risk_value += random.uniform(-0.5, 0.5)
    
    # Clamp to 1-5
    risk_level = max(1, min(5, round(risk_value)))
    
    return risk_level


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate enhanced training dataset with real weather')
    parser.add_argument(
        '--samples',
        type=int,
        default=5000,
        help='Number of samples to generate (default: 5000)'
    )
    parser.add_argument(
        '--no-weather',
        action='store_true',
        help='Skip fetching real weather data (faster, but less accurate)'
    )
    parser.add_argument(
        '--start-date',
        type=str,
        default='2020-01-01',
        help='Start date for historical data (YYYY-MM-DD)'
    )
    parser.add_argument(
        '--end-date',
        type=str,
        default='2024-01-01',
        help='End date for historical data (YYYY-MM-DD)'
    )
    
    args = parser.parse_args()
    
    df, output_file = generate_enhanced_samples(
        num_samples=args.samples,
        start_date=args.start_date,
        end_date=args.end_date,
        with_weather=not args.no_weather
    )
    
    print(f"\n✅ Dataset ready for training!")
    print(f"📄 File: {output_file}")
