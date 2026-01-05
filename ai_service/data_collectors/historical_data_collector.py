"""
Historical Disaster Data Collector

Collects historical disaster data for training patterns and seasonal analysis
"""
import pandas as pd
import requests
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import json


class HistoricalDataCollector:
    """
    Collect historical disaster data for training
    
    Sources:
    - EM-DAT (Emergency Events Database): https://www.emdat.be/
    - Government archives
    - Research papers
    """
    
    # Sample historical data structure (would be replaced with actual API calls)
    SAMPLE_HISTORICAL_DATA = [
        {
            'event_id': 'VN_FLOOD_2020_10',
            'event_type': 'flood',
            'date': '2020-10-15',
            'provinces_affected': ['Quảng Bình', 'Quảng Trị', 'Thừa Thiên Huế'],
            'severity': 'critical',
            'casualties': 102,
            'economic_loss_usd': 1200000000,
            'affected_population': 500000,
            'warning_issued': True,
            'warning_lead_time_hours': 24,
            'sources': ['NCHMF', 'DDMFC', 'News'],
            'verified': True
        },
        # Add more sample data...
    ]
    
    def __init__(self):
        """Initialize historical data collector"""
        pass
    
    def fetch_historical_disasters(
        self,
        start_year: int = 2000,
        end_year: int = None,
        province: Optional[str] = None,
        event_type: Optional[str] = None
    ) -> List[Dict]:
        """
        Fetch historical disaster data
        
        Args:
            start_year: Start year for data
            end_year: End year (default: current year)
            province: Filter by province (optional)
            event_type: Filter by event type (optional)
            
        Returns:
            List of historical disaster records
        """
        if end_year is None:
            end_year = datetime.now().year
        
        print(f"[Historical] Fetching disasters from {start_year} to {end_year}")
        
        # In production, this would fetch from EM-DAT API or database
        # For now, return sample data structure
        historical_data = self._fetch_from_emdat(start_year, end_year, province, event_type)
        
        # If EM-DAT not available, use sample data
        if not historical_data:
            historical_data = self._generate_sample_data(start_year, end_year, province, event_type)
        
        print(f"[Historical] Fetched {len(historical_data)} historical records")
        return historical_data
    
    def _fetch_from_emdat(
        self,
        start_year: int,
        end_year: int,
        province: Optional[str],
        event_type: Optional[str]
    ) -> List[Dict]:
        """
        Fetch from EM-DAT database
        
        Note: EM-DAT requires registration and API access
        This is a placeholder for actual implementation
        """
        # EM-DAT API endpoint (requires authentication)
        # api_url = "https://api.emdat.be/disasters"
        
        # For now, return empty (would need actual API credentials)
        print("[Historical] EM-DAT API access requires registration")
        return []
    
    def _generate_sample_data(
        self,
        start_year: int,
        end_year: int,
        province: Optional[str],
        event_type: Optional[str]
    ) -> List[Dict]:
        """
        Generate sample historical data for training
        
        In production, this would be replaced with actual data fetching
        """
        historical_data = []
        
        # Generate sample flood events
        for year in range(start_year, end_year + 1):
            # Typical flood season in Vietnam: September-November
            for month in [9, 10, 11]:
                # Generate 1-3 flood events per month
                num_events = 2  # Average
                
                for i in range(num_events):
                    day = 15 + (i * 10)  # Spread throughout month
                    if day > 28:
                        day = 28
                    
                    event_date = f"{year}-{month:02d}-{day:02d}"
                    
                    # Sample provinces (Central Vietnam flood-prone areas)
                    affected_provinces = [
                        'Quảng Bình', 'Quảng Trị', 'Thừa Thiên Huế',
                        'Quảng Nam', 'Quảng Ngãi', 'Bình Định'
                    ]
                    
                    if province and province not in affected_provinces:
                        continue
                    
                    event = {
                        'event_id': f'VN_FLOOD_{year}_{month}_{i}',
                        'event_type': 'flood',
                        'date': event_date,
                        'provinces_affected': [affected_provinces[i % len(affected_provinces)]],
                        'severity': 'high' if i % 2 == 0 else 'critical',
                        'casualties': 50 + (i * 20),
                        'economic_loss_usd': 500000000 + (i * 200000000),
                        'affected_population': 200000 + (i * 100000),
                        'warning_issued': True,
                        'warning_lead_time_hours': 12 + (i * 6),
                        'sources': ['NCHMF', 'DDMFC'],
                        'verified': True,
                        'confidence': 0.95
                    }
                    
                    if not event_type or event['event_type'] == event_type:
                        historical_data.append(event)
        
        # Generate sample storm events (typhoon season: June-December)
        for year in range(start_year, end_year + 1):
            for month in [6, 7, 8, 9, 10, 11, 12]:
                if month % 2 == 0:  # Every other month
                    event_date = f"{year}-{month:02d}-15"
                    
                    event = {
                        'event_id': f'VN_STORM_{year}_{month}',
                        'event_type': 'weather',
                        'date': event_date,
                        'provinces_affected': ['Toàn quốc'],
                        'severity': 'high',
                        'casualties': 30,
                        'economic_loss_usd': 300000000,
                        'affected_population': 1000000,
                        'warning_issued': True,
                        'warning_lead_time_hours': 48,
                        'sources': ['NCHMF'],
                        'verified': True,
                        'confidence': 1.0
                    }
                    
                    if not event_type or event['event_type'] == event_type:
                        historical_data.append(event)
        
        return historical_data
    
    def get_seasonal_patterns(self, province: str, month: int) -> Dict:
        """
        Get historical probability of disasters by province and month
        
        Args:
            province: Province name
            month: Month (1-12)
            
        Returns:
            Dict with probabilities and patterns:
            {
                'flood_probability': 0.0-1.0,
                'storm_probability': 0.0-1.0,
                'drought_probability': 0.0-1.0,
                'avg_severity': 1-5,
                'sample_size': int
            }
        """
        # Fetch historical data for this province and month
        historical = self.fetch_historical_disasters(
            start_year=2000,
            province=province
        )
        
        # Filter by month
        month_events = [
            event for event in historical
            if datetime.fromisoformat(event['date']).month == month
        ]
        
        if not month_events:
            return {
                'flood_probability': 0.1,
                'storm_probability': 0.1,
                'drought_probability': 0.05,
                'avg_severity': 2.0,
                'sample_size': 0
            }
        
        # Calculate probabilities
        total_events = len(month_events)
        flood_count = sum(1 for e in month_events if e['event_type'] == 'flood')
        storm_count = sum(1 for e in month_events if e['event_type'] == 'weather')
        drought_count = sum(1 for e in month_events if e['event_type'] == 'drought')
        
        # Calculate average severity
        severity_map = {'low': 1, 'medium': 2, 'high': 3, 'critical': 4}
        avg_severity = sum(
            severity_map.get(e.get('severity', 'medium'), 2)
            for e in month_events
        ) / total_events
        
        return {
            'flood_probability': flood_count / max(total_events, 1),
            'storm_probability': storm_count / max(total_events, 1),
            'drought_probability': drought_count / max(total_events, 1),
            'avg_severity': avg_severity,
            'sample_size': total_events
        }
    
    def convert_to_training_format(self, historical_event: Dict) -> Dict:
        """
        Convert historical event to training data format
        
        Args:
            historical_event: Historical disaster record
            
        Returns:
            Alert dict in training format
        """
        event_date = datetime.fromisoformat(historical_event['date'])
        
        # Use first affected province
        province = historical_event['provinces_affected'][0] if historical_event['provinces_affected'] else 'Toàn quốc'
        
        return {
            'id': historical_event['event_id'],
            'source': 'HISTORICAL',
            'source_reliability': historical_event.get('confidence', 0.95),
            'content': f"Historical {historical_event['event_type']} event in {province}",
            'severity': historical_event['severity'],
            'alert_type': historical_event['event_type'],
            'province': province,
            'district': None,
            'lat': None,
            'lng': None,
            'created_at': event_date.isoformat(),
            'verified': historical_event.get('verified', True),
            'confidence': historical_event.get('confidence', 0.95),
            'metadata': {
                'casualties': historical_event.get('casualties', 0),
                'economic_loss': historical_event.get('economic_loss_usd', 0),
                'affected_population': historical_event.get('affected_population', 0),
                'warning_lead_time': historical_event.get('warning_lead_time_hours', 0)
            }
        }


if __name__ == "__main__":
    # Test collector
    collector = HistoricalDataCollector()
    
    # Get seasonal patterns
    patterns = collector.get_seasonal_patterns('Quảng Bình', 10)
    print(f"\nSeasonal patterns for Quảng Bình in October:")
    print(f"  Flood probability: {patterns['flood_probability']:.2%}")
    print(f"  Storm probability: {patterns['storm_probability']:.2%}")
    print(f"  Avg severity: {patterns['avg_severity']:.1f}")
    
    # Fetch historical data
    historical = collector.fetch_historical_disasters(start_year=2020, end_year=2023)
    print(f"\nFetched {len(historical)} historical events")
    
    if historical:
        sample = historical[0]
        training_format = collector.convert_to_training_format(sample)
        print(f"\nSample converted to training format:")
        print(f"  ID: {training_format['id']}")
        print(f"  Type: {training_format['alert_type']}")
        print(f"  Severity: {training_format['severity']}")













