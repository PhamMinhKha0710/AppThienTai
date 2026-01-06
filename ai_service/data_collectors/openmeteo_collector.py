"""
Open-Meteo Weather Data Collector

Free, unlimited weather API for historical and real-time data.
No API key required!
"""
import requests
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import (
    OPEN_METEO_FORECAST_URL,
    OPEN_METEO_ARCHIVE_URL,
    WEATHER_CACHE_DIR,
    WEATHER_API_TIMEOUT
)


class OpenMeteoCollector:
    """Collect weather data from Open-Meteo API (100% free)"""
    
    def __init__(self, cache_enabled: bool = True):
        self.forecast_url = OPEN_METEO_FORECAST_URL
        self.archive_url = OPEN_METEO_ARCHIVE_URL
        self.cache_enabled = cache_enabled
        
        if cache_enabled:
            WEATHER_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    
    def get_current_weather(self, lat: float, lng: float) -> Dict:
        """
        Get current weather conditions
        
        Args:
            lat: Latitude
            lng: Longitude
            
        Returns:
            Dict with current weather data
        """
        params = {
            "latitude": lat,
            "longitude": lng,
            "current": [
                "temperature_2m",
                "precipitation",
                "rain",
                "wind_speed_10m",
                "wind_gusts_10m",
                "relative_humidity_2m",
                "cloud_cover",
                "pressure_msl"
            ],
            "timezone": "Asia/Bangkok"
        }
        
        try:
            response = requests.get(
                self.forecast_url,
                params=params,
                timeout=WEATHER_API_TIMEOUT
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"Error fetching current weather: {e}")
            return {}
    
    def get_forecast(self, lat: float, lng: float, days: int = 7) -> Dict:
        """
        Get weather forecast
        
        Args:
            lat: Latitude
            lng: Longitude
            days: Number of days to forecast (max 16)
            
        Returns:
            Dict with forecast data
        """
        params = {
            "latitude": lat,
            "longitude": lng,
            "daily": [
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "rain_sum",
                "wind_speed_10m_max",
                "wind_gusts_10m_max"
            ],
            "timezone": "Asia/Bangkok",
            "forecast_days": min(days, 16)
        }
        
        try:
            response = requests.get(
                self.forecast_url,
                params=params,
                timeout=WEATHER_API_TIMEOUT
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"Error fetching forecast: {e}")
            return {}
    
    def get_historical_weather(
        self,
        lat: float,
        lng: float,
        start_date: str,
        end_date: str
    ) -> Dict:
        """
        Get historical weather data
        
        Args:
            lat: Latitude
            lng: Longitude
            start_date: Start date (YYYY-MM-DD)
            end_date: End date (YYYY-MM-DD)
            
        Returns:
            Dict with historical daily weather data
        """
        # Check cache first
        if self.cache_enabled:
            cache_key = f"{lat}_{lng}_{start_date}_{end_date}"
            cache_file = WEATHER_CACHE_DIR / f"{cache_key}.json"
            
            if cache_file.exists():
                print(f"[Cache] Loading from {cache_file}")
                with open(cache_file, 'r') as f:
                    return json.load(f)
        
        params = {
            "latitude": lat,
            "longitude": lng,
            "start_date": start_date,
            "end_date": end_date,
            "daily": [
                "temperature_2m_max",
                "temperature_2m_min",
                "temperature_2m_mean",
                "precipitation_sum",
                "rain_sum",
                "wind_speed_10m_max",
                "wind_gusts_10m_max",
                "relative_humidity_2m_mean",
                "pressure_msl_mean"
            ],
            "timezone": "Asia/Bangkok"
        }
        
        try:
            response = requests.get(
                self.archive_url,
                params=params,
                timeout=WEATHER_API_TIMEOUT
            )
            response.raise_for_status()
            data = response.json()
            
            # Cache the result
            if self.cache_enabled:
                with open(cache_file, 'w') as f:
                    json.dump(data, f, indent=2)
            
            return data
        except Exception as e:
            print(f"Error fetching historical weather: {e}")
            return {}
    
    def get_weather_for_disaster_event(
        self,
        lat: float,
        lng: float,
        event_date: str,
        lookback_days: int = 30
    ) -> Dict:
        """
        Get weather data before a disaster event
        
        Args:
            lat: Event latitude
            lng: Event longitude
            event_date: Date of disaster (YYYY-MM-DD)
            lookback_days: Days before event to fetch
            
        Returns:
            Dict with weather summary
        """
        event = datetime.fromisoformat(event_date)
        start = event - timedelta(days=lookback_days)
        
        data = self.get_historical_weather(
            lat, lng,
            start.strftime("%Y-%m-%d"),
            event_date
        )
        
        if not data or 'daily' not in data:
            return {}
        
        daily = data['daily']
        
        # Calculate summary statistics
        summary = {
            'event_date': event_date,
            'lookback_days': lookback_days,
            'avg_temperature': sum(daily['temperature_2m_mean']) / len(daily['temperature_2m_mean']),
            'max_temperature': max(daily['temperature_2m_max']),
            'min_temperature': min(daily['temperature_2m_min']),
            'total_precipitation': sum(daily['precipitation_sum']),
            'max_daily_precipitation': max(daily['precipitation_sum']),
            'avg_wind_speed': sum(daily['wind_speed_10m_max']) / len(daily['wind_speed_10m_max']),
            'max_wind_speed': max(daily['wind_speed_10m_max']),
            'days_with_rain': sum(1 for p in daily['precipitation_sum'] if p > 0),
            'days_with_heavy_rain': sum(1 for p in daily['precipitation_sum'] if p > 50),  # >50mm
        }
        
        return summary


if __name__ == "__main__":
    # Test the collector
    collector = OpenMeteoCollector()
    
    print("=" * 60)
    print("  TESTING OPEN-METEO COLLECTOR")
    print("=" * 60)
    
    # Test location: Da Nang
    lat, lng = 16.0544, 108.2022
    print(f"\nLocation: Da Nang ({lat}, {lng})")
    
    # Test 1: Current weather
    print("\n[Test 1] Current Weather:")
    current = collector.get_current_weather(lat, lng)
    if current and 'current' in current:
        c = current['current']
        print(f"  Temperature: {c.get('temperature_2m')}°C")
        print(f"  Precipitation: {c.get('precipitation')} mm")
        print(f"  Wind Speed: {c.get('wind_speed_10m')} km/h")
        print(f"  Humidity: {c.get('relative_humidity_2m')}%")
    
    # Test 2: 7-day forecast
    print("\n[Test 2] 7-Day Forecast:")
    forecast = collector.get_forecast(lat, lng, days=7)
    if forecast and 'daily' in forecast:
        print(f"  Forecast days: {len(forecast['daily']['time'])}")
        print(f"  Max temp range: {min(forecast['daily']['temperature_2m_max'])}°C - {max(forecast['daily']['temperature_2m_max'])}°C")
        print(f"  Total precipitation: {sum(forecast['daily']['precipitation_sum'])} mm")
    
    # Test 3: Historical weather (last 30 days)
    print("\n[Test 3] Historical Weather (last 30 days):")
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)
    
    historical = collector.get_historical_weather(
        lat, lng,
        start_date.strftime("%Y-%m-%d"),
        end_date.strftime("%Y-%m-%d")
    )
    
    if historical and 'daily' in historical:
        daily = historical['daily']
        print(f"  Days: {len(daily['time'])}")
        print(f"  Avg temp: {sum(daily['temperature_2m_mean']) / len(daily['temperature_2m_mean']):.1f}°C")
        print(f"  Total rainfall: {sum(daily['precipitation_sum']):.1f} mm")
        print(f"  Max wind: {max(daily['wind_speed_10m_max']):.1f} km/h")
    
    # Test 4: Event weather (simulate disaster on Oct 15, 2023)
    print("\n[Test 4] Weather Before Disaster Event:")
    summary = collector.get_weather_for_disaster_event(
        lat, lng,
        "2023-10-15",
        lookback_days=30
    )
    
    if summary:
        print(f"  Total precipitation 30 days before: {summary['total_precipitation']:.1f} mm")
        print(f"  Max daily precipitation: {summary['max_daily_precipitation']:.1f} mm")
        print(f"  Days with heavy rain (>50mm): {summary['days_with_heavy_rain']}")
        print(f"  Max wind speed: {summary['max_wind_speed']:.1f} km/h")
    
    print("\n" + "=" * 60)
    print("✅ All tests completed!")
    print("=" * 60)
