"""Intelligent Notification Timing using Contextual Bandit"""
import numpy as np
from scipy.stats import beta as beta_dist
import json
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import N_TIME_SLOTS, EPSILON_EXPLORATION, MODELS_DIR


class NotificationTimingModel:
    """
    Contextual Bandit for Notification Timing Optimization
    
    Uses Thompson Sampling (Multi-Armed Bandit) to learn the best time
    to send notifications to maximize user engagement.
    
    Features:
    - Cold start: Epsilon-greedy exploration
    - Online learning: Updates from user feedback in real-time
    - Uncertainty quantification: Beta distribution confidence
    - Per-user personalization (can be extended)
    
    Time slots: 0-23 (hours of day)
    """
    
    def __init__(self, n_time_slots: int = N_TIME_SLOTS, epsilon: float = EPSILON_EXPLORATION):
        self.n_slots = n_time_slots
        self.epsilon = epsilon
        
        # Beta distribution parameters for each time slot
        # alpha = number of successful engagements (clicks, views)
        # beta = number of failed engagements (dismissals, ignores)
        # Prior: uniform (1 success, 1 failure for each slot)
        self.alpha = np.ones(n_time_slots, dtype=float)
        self.beta_param = np.ones(n_time_slots, dtype=float)
        
        # Load existing parameters if available
        self._load_parameters()
        
        print(f"[NotificationTiming] Initialized with {n_time_slots} time slots, epsilon={epsilon}")
    
    def select_time_slot(
        self,
        alert_severity: str = None,
        user_context: dict = None
    ) -> int:
        """
        Select best time slot using Thompson Sampling
        
        Thompson Sampling balances exploration (trying new times) and
        exploitation (using best known times) by sampling from Beta distributions.
        
        Args:
            alert_severity: Alert severity (critical, high, medium, low)
            user_context: Additional user context (for future extensions)
            
        Returns:
            Time slot (0-23) to send notification
        """
        # Critical alerts: send immediately (current hour)
        if alert_severity == 'critical':
            from datetime import datetime
            return datetime.now().hour
        
        # Epsilon-greedy exploration
        if np.random.random() < self.epsilon:
            # Explore: random time slot
            return int(np.random.randint(0, self.n_slots))
        
        # Thompson Sampling: sample from Beta distributions
        samples = np.array([
            np.random.beta(self.alpha[i], self.beta_param[i])
            for i in range(self.n_slots)
        ])
        
        # Exploitation: choose slot with highest sampled value
        best_slot = int(np.argmax(samples))
        
        return best_slot
    
    def update_feedback(
        self,
        time_slot: int,
        engaged: bool
    ):
        """
        Update model based on user feedback
        
        Args:
            time_slot: Time slot (0-23) when notification was sent
            engaged: True if user engaged (view, click), False if dismissed
        """
        if not (0 <= time_slot < self.n_slots):
            print(f"[NotificationTiming] Warning: Invalid time slot {time_slot}")
            return
        
        if engaged:
            # Success: increment alpha
            self.alpha[time_slot] += 1
        else:
            # Failure: increment beta
            self.beta_param[time_slot] += 1
        
        # Save updated parameters
        self._save_parameters()
    
    def get_best_times(self, top_k: int = 3) -> list:
        """
        Get top K best time slots based on current knowledge
        
        Args:
            top_k: Number of top times to return
            
        Returns:
            List of dicts with 'hour', 'success_rate', 'confidence'
        """
        # Calculate expected success rate (mean of Beta distribution)
        expected_rewards = self.alpha / (self.alpha + self.beta_param)
        
        # Get top K indices
        top_indices = np.argsort(expected_rewards)[-top_k:][::-1]
        
        results = []
        for idx in top_indices:
            results.append({
                'hour': int(idx),
                'success_rate': float(expected_rewards[idx]),
                'confidence': self._get_confidence(idx),
                'sample_size': int(self.alpha[idx] + self.beta_param[idx] - 2)  # -2 for prior
            })
        
        return results
    
    def get_all_time_stats(self) -> list:
        """Get statistics for all time slots"""
        expected_rewards = self.alpha / (self.alpha + self.beta_param)
        
        results = []
        for i in range(self.n_slots):
            results.append({
                'hour': i,
                'success_rate': float(expected_rewards[i]),
                'confidence': self._get_confidence(i),
                'alpha': float(self.alpha[i]),
                'beta': float(self.beta_param[i]),
                'sample_size': int(self.alpha[i] + self.beta_param[i] - 2)
            })
        
        return results
    
    def _get_confidence(self, slot: int) -> float:
        """
        Calculate confidence (inverse of uncertainty)
        
        Uses standard deviation of Beta distribution as uncertainty measure.
        Higher sample size = higher confidence.
        
        Returns:
            Confidence score (0-1)
        """
        a = self.alpha[slot]
        b = self.beta_param[slot]
        n = a + b
        
        # Standard deviation of Beta(a, b)
        variance = (a * b) / ((n ** 2) * (n + 1))
        std = np.sqrt(variance)
        
        # Convert to confidence (1 - normalized_std)
        # Max std for Beta is 0.5, so normalize by that
        confidence = 1.0 - (std / 0.5)
        
        return float(np.clip(confidence, 0, 1))
    
    def _save_parameters(self, path: Path = None):
        """Save model parameters to disk"""
        if path is None:
            path = MODELS_DIR / "notification_timing.json"
        
        data = {
            'alpha': self.alpha.tolist(),
            'beta': self.beta_param.tolist(),
            'n_slots': self.n_slots,
            'epsilon': self.epsilon
        }
        
        with open(path, 'w') as f:
            json.dump(data, f)
    
    def _load_parameters(self, path: Path = None) -> bool:
        """Load model parameters from disk"""
        if path is None:
            path = MODELS_DIR / "notification_timing.json"
        
        if not path.exists():
            return False
        
        try:
            with open(path, 'r') as f:
                data = json.load(f)
            
            self.alpha = np.array(data['alpha'])
            self.beta_param = np.array(data['beta'])
            self.n_slots = data['n_slots']
            self.epsilon = data['epsilon']
            
            print(f"[NotificationTiming] Loaded parameters from {path}")
            return True
        except Exception as e:
            print(f"[NotificationTiming] Error loading parameters: {e}")
            return False
    
    def reset(self):
        """Reset model to initial state (uniform prior)"""
        self.alpha = np.ones(self.n_slots, dtype=float)
        self.beta_param = np.ones(self.n_slots, dtype=float)
        self._save_parameters()
        print("[NotificationTiming] Model reset to initial state")
    
    def simulate_day_pattern(self) -> dict:
        """
        Simulate realistic day pattern for testing/demo
        
        Returns:
            Dict with 'pattern' (expected behavior) and 'recommendations'
        """
        # Typical engagement patterns:
        # Morning (6-9): moderate (0.6)
        # Work hours (9-17): low (0.3)
        # Evening (17-22): high (0.8)
        # Night (22-6): very low (0.1)
        
        patterns = {
            'morning': (6, 9, 0.6),
            'work': (9, 17, 0.3),
            'evening': (17, 22, 0.8),
            'night_early': (22, 24, 0.1),
            'night_late': (0, 6, 0.1)
        }
        
        for name, (start, end, rate) in patterns.items():
            for hour in range(start, end):
                if hour < self.n_slots:
                    # Simulate ~20 samples for each hour
                    successes = int(20 * rate)
                    failures = 20 - successes
                    
                    self.alpha[hour] += successes
                    self.beta_param[hour] += failures
        
        self._save_parameters()
        
        return {
            'pattern': 'Simulated realistic day pattern',
            'best_times': self.get_best_times(top_k=5)
        }


import numpy as np
from scipy.stats import beta as beta_dist
import json
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import N_TIME_SLOTS, EPSILON_EXPLORATION, MODELS_DIR


class NotificationTimingModel:
    """
    Contextual Bandit for Notification Timing Optimization
    
    Uses Thompson Sampling (Multi-Armed Bandit) to learn the best time
    to send notifications to maximize user engagement.
    
    Features:
    - Cold start: Epsilon-greedy exploration
    - Online learning: Updates from user feedback in real-time
    - Uncertainty quantification: Beta distribution confidence
    - Per-user personalization (can be extended)
    
    Time slots: 0-23 (hours of day)
    """
    
    def __init__(self, n_time_slots: int = N_TIME_SLOTS, epsilon: float = EPSILON_EXPLORATION):
        self.n_slots = n_time_slots
        self.epsilon = epsilon
        
        # Beta distribution parameters for each time slot
        # alpha = number of successful engagements (clicks, views)
        # beta = number of failed engagements (dismissals, ignores)
        # Prior: uniform (1 success, 1 failure for each slot)
        self.alpha = np.ones(n_time_slots, dtype=float)
        self.beta_param = np.ones(n_time_slots, dtype=float)
        
        # Load existing parameters if available
        self._load_parameters()
        
        print(f"[NotificationTiming] Initialized with {n_time_slots} time slots, epsilon={epsilon}")
    
    def select_time_slot(
        self,
        alert_severity: str = None,
        user_context: dict = None
    ) -> int:
        """
        Select best time slot using Thompson Sampling
        
        Thompson Sampling balances exploration (trying new times) and
        exploitation (using best known times) by sampling from Beta distributions.
        
        Args:
            alert_severity: Alert severity (critical, high, medium, low)
            user_context: Additional user context (for future extensions)
            
        Returns:
            Time slot (0-23) to send notification
        """
        # Critical alerts: send immediately (current hour)
        if alert_severity == 'critical':
            from datetime import datetime
            return datetime.now().hour
        
        # Epsilon-greedy exploration
        if np.random.random() < self.epsilon:
            # Explore: random time slot
            return int(np.random.randint(0, self.n_slots))
        
        # Thompson Sampling: sample from Beta distributions
        samples = np.array([
            np.random.beta(self.alpha[i], self.beta_param[i])
            for i in range(self.n_slots)
        ])
        
        # Exploitation: choose slot with highest sampled value
        best_slot = int(np.argmax(samples))
        
        return best_slot
    
    def update_feedback(
        self,
        time_slot: int,
        engaged: bool
    ):
        """
        Update model based on user feedback
        
        Args:
            time_slot: Time slot (0-23) when notification was sent
            engaged: True if user engaged (view, click), False if dismissed
        """
        if not (0 <= time_slot < self.n_slots):
            print(f"[NotificationTiming] Warning: Invalid time slot {time_slot}")
            return
        
        if engaged:
            # Success: increment alpha
            self.alpha[time_slot] += 1
        else:
            # Failure: increment beta
            self.beta_param[time_slot] += 1
        
        # Save updated parameters
        self._save_parameters()
    
    def get_best_times(self, top_k: int = 3) -> list:
        """
        Get top K best time slots based on current knowledge
        
        Args:
            top_k: Number of top times to return
            
        Returns:
            List of dicts with 'hour', 'success_rate', 'confidence'
        """
        # Calculate expected success rate (mean of Beta distribution)
        expected_rewards = self.alpha / (self.alpha + self.beta_param)
        
        # Get top K indices
        top_indices = np.argsort(expected_rewards)[-top_k:][::-1]
        
        results = []
        for idx in top_indices:
            results.append({
                'hour': int(idx),
                'success_rate': float(expected_rewards[idx]),
                'confidence': self._get_confidence(idx),
                'sample_size': int(self.alpha[idx] + self.beta_param[idx] - 2)  # -2 for prior
            })
        
        return results
    
    def get_all_time_stats(self) -> list:
        """Get statistics for all time slots"""
        expected_rewards = self.alpha / (self.alpha + self.beta_param)
        
        results = []
        for i in range(self.n_slots):
            results.append({
                'hour': i,
                'success_rate': float(expected_rewards[i]),
                'confidence': self._get_confidence(i),
                'alpha': float(self.alpha[i]),
                'beta': float(self.beta_param[i]),
                'sample_size': int(self.alpha[i] + self.beta_param[i] - 2)
            })
        
        return results
    
    def _get_confidence(self, slot: int) -> float:
        """
        Calculate confidence (inverse of uncertainty)
        
        Uses standard deviation of Beta distribution as uncertainty measure.
        Higher sample size = higher confidence.
        
        Returns:
            Confidence score (0-1)
        """
        a = self.alpha[slot]
        b = self.beta_param[slot]
        n = a + b
        
        # Standard deviation of Beta(a, b)
        variance = (a * b) / ((n ** 2) * (n + 1))
        std = np.sqrt(variance)
        
        # Convert to confidence (1 - normalized_std)
        # Max std for Beta is 0.5, so normalize by that
        confidence = 1.0 - (std / 0.5)
        
        return float(np.clip(confidence, 0, 1))
    
    def _save_parameters(self, path: Path = None):
        """Save model parameters to disk"""
        if path is None:
            path = MODELS_DIR / "notification_timing.json"
        
        data = {
            'alpha': self.alpha.tolist(),
            'beta': self.beta_param.tolist(),
            'n_slots': self.n_slots,
            'epsilon': self.epsilon
        }
        
        with open(path, 'w') as f:
            json.dump(data, f)
    
    def _load_parameters(self, path: Path = None) -> bool:
        """Load model parameters from disk"""
        if path is None:
            path = MODELS_DIR / "notification_timing.json"
        
        if not path.exists():
            return False
        
        try:
            with open(path, 'r') as f:
                data = json.load(f)
            
            self.alpha = np.array(data['alpha'])
            self.beta_param = np.array(data['beta'])
            self.n_slots = data['n_slots']
            self.epsilon = data['epsilon']
            
            print(f"[NotificationTiming] Loaded parameters from {path}")
            return True
        except Exception as e:
            print(f"[NotificationTiming] Error loading parameters: {e}")
            return False
    
    def reset(self):
        """Reset model to initial state (uniform prior)"""
        self.alpha = np.ones(self.n_slots, dtype=float)
        self.beta_param = np.ones(self.n_slots, dtype=float)
        self._save_parameters()
        print("[NotificationTiming] Model reset to initial state")
    
    def simulate_day_pattern(self) -> dict:
        """
        Simulate realistic day pattern for testing/demo
        
        Returns:
            Dict with 'pattern' (expected behavior) and 'recommendations'
        """
        # Typical engagement patterns:
        # Morning (6-9): moderate (0.6)
        # Work hours (9-17): low (0.3)
        # Evening (17-22): high (0.8)
        # Night (22-6): very low (0.1)
        
        patterns = {
            'morning': (6, 9, 0.6),
            'work': (9, 17, 0.3),
            'evening': (17, 22, 0.8),
            'night_early': (22, 24, 0.1),
            'night_late': (0, 6, 0.1)
        }
        
        for name, (start, end, rate) in patterns.items():
            for hour in range(start, end):
                if hour < self.n_slots:
                    # Simulate ~20 samples for each hour
                    successes = int(20 * rate)
                    failures = 20 - successes
                    
                    self.alpha[hour] += successes
                    self.beta_param[hour] += failures
        
        self._save_parameters()
        
        return {
            'pattern': 'Simulated realistic day pattern',
            'best_times': self.get_best_times(top_k=5)
        }



