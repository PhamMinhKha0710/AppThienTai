"""Feature Engineering Utilities"""
from datetime import datetime
import math


class FeatureExtractor:
    """Extract features from alert data for ML models"""
    
    @staticmethod
    def extract_features(alert_data: dict) -> dict:
        """
        Extract all features from alert data
        
        Args:
            alert_data: Dict with alert information
            
        Returns:
            Dict with all 15 features ready for model
        """
        # Severity score mapping
        severity_map = {
            'low': 1,
            'medium': 2,
            'high': 3,
            'critical': 4
        }
        
        # Alert type score mapping
        type_map = {
            'general': 1,
            'weather': 2,
            'evacuation': 3,
            'disaster': 4
        }
        
        # Time calculations
        created_at = datetime.fromisoformat(alert_data['created_at'].replace('Z', '+00:00'))
        now = datetime.now(created_at.tzinfo)
        hours_since_created = (now - created_at).total_seconds() / 3600
        
        # Distance calculation
        distance_km = 0.0
        if alert_data.get('lat') and alert_data.get('lng') and \
           alert_data.get('user_lat') and alert_data.get('user_lng'):
            distance_km = FeatureExtractor._haversine_distance(
                alert_data['lat'], alert_data['lng'],
                alert_data['user_lat'], alert_data['user_lng']
            )
        
        # Target audience match
        user_role = alert_data.get('user_role', 'victim')
        target_audience_match = 1 if user_role in ['victim', 'all'] else 0
        
        # Extract features
        features = {
            # Alert properties
            'severity_score': severity_map.get(alert_data.get('severity', 'low'), 1),
            'alert_type_score': type_map.get(alert_data.get('alert_type', 'general'), 1),
            'hours_since_created': hours_since_created,
            'distance_km': distance_km,
            'target_audience_match': target_audience_match,
            
            # Contextual features (defaults for cold start)
            'user_previous_interactions': alert_data.get('user_interactions', 0),
            'time_of_day': now.hour,
            'day_of_week': now.weekday(),
            'weather_severity': alert_data.get('weather_severity', 0),
            
            # Alert characteristics
            'content_length': len(alert_data.get('content', '')),
            'has_images': 1 if alert_data.get('has_images', False) else 0,
            'has_safety_guide': 1 if alert_data.get('has_safety_guide', False) else 0,
            
            # Social signals (defaults for cold start)
            'similar_alerts_count': alert_data.get('similar_alerts_count', 0),
            'alert_engagement_rate': alert_data.get('engagement_rate', 0.5),
            'source_reliability': alert_data.get('source_reliability', 1.0),
        }
        
        return features
    
    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        R = 6371.0  # Earth radius in kilometers
        
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        distance = R * c
        return distance
    
    @staticmethod
    def generate_explanation(features: dict, score: float) -> dict:
        """
        Generate human-readable explanation for score
        
        Args:
            features: Feature dict
            score: Predicted score
            
        Returns:
            Dict with explanation components
        """
        explanation = {
            'score': score,
            'factors': []
        }
        
        # Severity impact
        if features['severity_score'] >= 3:
            explanation['factors'].append({
                'factor': 'severity',
                'impact': 'high',
                'message': f"High severity alert (level {features['severity_score']})"
            })
        
        # Distance impact
        if features['distance_km'] < 10:
            explanation['factors'].append({
                'factor': 'distance',
                'impact': 'high',
                'message': f"Very close to your location ({features['distance_km']:.1f} km)"
            })
        elif features['distance_km'] < 30:
            explanation['factors'].append({
                'factor': 'distance',
                'impact': 'medium',
                'message': f"Nearby ({features['distance_km']:.1f} km)"
            })
        
        # Time impact
        if features['hours_since_created'] < 1:
            explanation['factors'].append({
                'factor': 'freshness',
                'impact': 'high',
                'message': "Very recent alert"
            })
        elif features['hours_since_created'] > 24:
            explanation['factors'].append({
                'factor': 'freshness',
                'impact': 'low',
                'message': "Alert is more than a day old"
            })
        
        # Audience match
        if features['target_audience_match']:
            explanation['factors'].append({
                'factor': 'relevance',
                'impact': 'high',
                'message': "Targeted for your user type"
            })
        
        return explanation


from datetime import datetime
import math


class FeatureExtractor:
    """Extract features from alert data for ML models"""
    
    @staticmethod
    def extract_features(alert_data: dict) -> dict:
        """
        Extract all features from alert data
        
        Args:
            alert_data: Dict with alert information
            
        Returns:
            Dict with all 15 features ready for model
        """
        # Severity score mapping
        severity_map = {
            'low': 1,
            'medium': 2,
            'high': 3,
            'critical': 4
        }
        
        # Alert type score mapping
        type_map = {
            'general': 1,
            'weather': 2,
            'evacuation': 3,
            'disaster': 4
        }
        
        # Time calculations
        created_at = datetime.fromisoformat(alert_data['created_at'].replace('Z', '+00:00'))
        now = datetime.now(created_at.tzinfo)
        hours_since_created = (now - created_at).total_seconds() / 3600
        
        # Distance calculation
        distance_km = 0.0
        if alert_data.get('lat') and alert_data.get('lng') and \
           alert_data.get('user_lat') and alert_data.get('user_lng'):
            distance_km = FeatureExtractor._haversine_distance(
                alert_data['lat'], alert_data['lng'],
                alert_data['user_lat'], alert_data['user_lng']
            )
        
        # Target audience match
        user_role = alert_data.get('user_role', 'victim')
        target_audience_match = 1 if user_role in ['victim', 'all'] else 0
        
        # Extract features
        features = {
            # Alert properties
            'severity_score': severity_map.get(alert_data.get('severity', 'low'), 1),
            'alert_type_score': type_map.get(alert_data.get('alert_type', 'general'), 1),
            'hours_since_created': hours_since_created,
            'distance_km': distance_km,
            'target_audience_match': target_audience_match,
            
            # Contextual features (defaults for cold start)
            'user_previous_interactions': alert_data.get('user_interactions', 0),
            'time_of_day': now.hour,
            'day_of_week': now.weekday(),
            'weather_severity': alert_data.get('weather_severity', 0),
            
            # Alert characteristics
            'content_length': len(alert_data.get('content', '')),
            'has_images': 1 if alert_data.get('has_images', False) else 0,
            'has_safety_guide': 1 if alert_data.get('has_safety_guide', False) else 0,
            
            # Social signals (defaults for cold start)
            'similar_alerts_count': alert_data.get('similar_alerts_count', 0),
            'alert_engagement_rate': alert_data.get('engagement_rate', 0.5),
            'source_reliability': alert_data.get('source_reliability', 1.0),
        }
        
        return features
    
    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        R = 6371.0  # Earth radius in kilometers
        
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        
        distance = R * c
        return distance
    
    @staticmethod
    def generate_explanation(features: dict, score: float) -> dict:
        """
        Generate human-readable explanation for score
        
        Args:
            features: Feature dict
            score: Predicted score
            
        Returns:
            Dict with explanation components
        """
        explanation = {
            'score': score,
            'factors': []
        }
        
        # Severity impact
        if features['severity_score'] >= 3:
            explanation['factors'].append({
                'factor': 'severity',
                'impact': 'high',
                'message': f"High severity alert (level {features['severity_score']})"
            })
        
        # Distance impact
        if features['distance_km'] < 10:
            explanation['factors'].append({
                'factor': 'distance',
                'impact': 'high',
                'message': f"Very close to your location ({features['distance_km']:.1f} km)"
            })
        elif features['distance_km'] < 30:
            explanation['factors'].append({
                'factor': 'distance',
                'impact': 'medium',
                'message': f"Nearby ({features['distance_km']:.1f} km)"
            })
        
        # Time impact
        if features['hours_since_created'] < 1:
            explanation['factors'].append({
                'factor': 'freshness',
                'impact': 'high',
                'message': "Very recent alert"
            })
        elif features['hours_since_created'] > 24:
            explanation['factors'].append({
                'factor': 'freshness',
                'impact': 'low',
                'message': "Alert is more than a day old"
            })
        
        # Audience match
        if features['target_audience_match']:
            explanation['factors'].append({
                'factor': 'relevance',
                'impact': 'high',
                'message': "Targeted for your user type"
            })
        
        return explanation



