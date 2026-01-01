"""Metrics Calculation Utilities"""
import numpy as np
from typing import List, Dict


class MetricsCalculator:
    """Calculate various metrics for model evaluation"""
    
    @staticmethod
    def calculate_confidence(model, features: dict) -> float:
        """
        Calculate confidence score for a prediction
        
        For Random Forest, use std of tree predictions as uncertainty measure.
        Confidence = 1 - (normalized_std)
        
        Args:
            model: Trained RandomForestRegressor
            features: Feature dict
            
        Returns:
            Confidence score (0-1)
        """
        try:
            from models.alert_scorer import AlertScoringModel
            
            if not isinstance(model, AlertScoringModel):
                return 0.5  # Default for unknown models
            
            # Get predictions from all trees
            X = model._features_to_array(features)
            X_scaled = model.scaler.transform(X.reshape(1, -1))
            
            tree_predictions = np.array([
                tree.predict(X_scaled)[0]
                for tree in model.model.estimators_
            ])
            
            # Calculate normalized standard deviation
            std = np.std(tree_predictions)
            normalized_std = std / 100.0  # Normalize by max score
            
            # Confidence = 1 - uncertainty
            confidence = 1.0 - normalized_std
            
            return float(np.clip(confidence, 0, 1))
        
        except Exception as e:
            print(f"[Metrics] Error calculating confidence: {e}")
            return 0.5
    
    @staticmethod
    def calculate_engagement_rate(actions: List[str]) -> float:
        """
        Calculate engagement rate from list of actions
        
        Args:
            actions: List of action strings ('view', 'click', 'dismiss', etc.)
            
        Returns:
            Engagement rate (0-1)
        """
        if not actions:
            return 0.5  # Default
        
        engaged_actions = {'view', 'click', 'share'}
        engaged_count = sum(1 for action in actions if action in engaged_actions)
        
        return engaged_count / len(actions)
    
    @staticmethod
    def calculate_click_through_rate(impressions: int, clicks: int) -> float:
        """Calculate CTR"""
        if impressions == 0:
            return 0.0
        return clicks / impressions
    
    @staticmethod
    def calculate_performance_metrics(y_true: np.ndarray, y_pred: np.ndarray) -> Dict:
        """
        Calculate comprehensive performance metrics
        
        Args:
            y_true: True values
            y_pred: Predicted values
            
        Returns:
            Dict with various metrics
        """
        from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
        
        mae = mean_absolute_error(y_true, y_pred)
        mse = mean_squared_error(y_true, y_pred)
        rmse = np.sqrt(mse)
        r2 = r2_score(y_true, y_pred)
        
        # Mean Absolute Percentage Error
        mask = y_true != 0
        mape = np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100
        
        return {
            'mae': float(mae),
            'mse': float(mse),
            'rmse': float(rmse),
            'r2_score': float(r2),
            'mape': float(mape)
        }


import numpy as np
from typing import List, Dict


class MetricsCalculator:
    """Calculate various metrics for model evaluation"""
    
    @staticmethod
    def calculate_confidence(model, features: dict) -> float:
        """
        Calculate confidence score for a prediction
        
        For Random Forest, use std of tree predictions as uncertainty measure.
        Confidence = 1 - (normalized_std)
        
        Args:
            model: Trained RandomForestRegressor
            features: Feature dict
            
        Returns:
            Confidence score (0-1)
        """
        try:
            from models.alert_scorer import AlertScoringModel
            
            if not isinstance(model, AlertScoringModel):
                return 0.5  # Default for unknown models
            
            # Get predictions from all trees
            X = model._features_to_array(features)
            X_scaled = model.scaler.transform(X.reshape(1, -1))
            
            tree_predictions = np.array([
                tree.predict(X_scaled)[0]
                for tree in model.model.estimators_
            ])
            
            # Calculate normalized standard deviation
            std = np.std(tree_predictions)
            normalized_std = std / 100.0  # Normalize by max score
            
            # Confidence = 1 - uncertainty
            confidence = 1.0 - normalized_std
            
            return float(np.clip(confidence, 0, 1))
        
        except Exception as e:
            print(f"[Metrics] Error calculating confidence: {e}")
            return 0.5
    
    @staticmethod
    def calculate_engagement_rate(actions: List[str]) -> float:
        """
        Calculate engagement rate from list of actions
        
        Args:
            actions: List of action strings ('view', 'click', 'dismiss', etc.)
            
        Returns:
            Engagement rate (0-1)
        """
        if not actions:
            return 0.5  # Default
        
        engaged_actions = {'view', 'click', 'share'}
        engaged_count = sum(1 for action in actions if action in engaged_actions)
        
        return engaged_count / len(actions)
    
    @staticmethod
    def calculate_click_through_rate(impressions: int, clicks: int) -> float:
        """Calculate CTR"""
        if impressions == 0:
            return 0.0
        return clicks / impressions
    
    @staticmethod
    def calculate_performance_metrics(y_true: np.ndarray, y_pred: np.ndarray) -> Dict:
        """
        Calculate comprehensive performance metrics
        
        Args:
            y_true: True values
            y_pred: Predicted values
            
        Returns:
            Dict with various metrics
        """
        from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
        
        mae = mean_absolute_error(y_true, y_pred)
        mse = mean_squared_error(y_true, y_pred)
        rmse = np.sqrt(mse)
        r2 = r2_score(y_true, y_pred)
        
        # Mean Absolute Percentage Error
        mask = y_true != 0
        mape = np.mean(np.abs((y_true[mask] - y_pred[mask]) / y_true[mask])) * 100
        
        return {
            'mae': float(mae),
            'mse': float(mse),
            'rmse': float(rmse),
            'r2_score': float(r2),
            'mape': float(mape)
        }



