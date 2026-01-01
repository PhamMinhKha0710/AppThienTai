"""Data Collection Service for Online Learning"""
import sqlite3
import json
from datetime import datetime
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import DATABASE_PATH


class DataCollector:
    """
    Collects training data from model predictions and user feedback
    
    Stores data in SQLite for:
    - Model retraining
    - Performance monitoring
    - Analytics
    """
    
    def __init__(self, db_path: Path = DATABASE_PATH):
        self.db_path = db_path
        self._init_db()
        print(f"[DataCollector] Initialized with database: {db_path}")
    
    def _init_db(self):
        """Initialize SQLite database with required tables"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Predictions table - stores model predictions for evaluation
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                features TEXT NOT NULL,
                predicted_score REAL NOT NULL,
                actual_score REAL,
                model_version TEXT DEFAULT 'v1',
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(alert_id, timestamp)
            )
        ''')
        
        # Engagement table - stores user interactions with alerts
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS engagement (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                action TEXT NOT NULL,
                time_slot INTEGER,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Duplicate checks table - stores duplicate detection results
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS duplicate_checks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                is_duplicate BOOLEAN NOT NULL,
                best_match_id TEXT,
                similarity REAL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Model performance table - tracks model metrics over time
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS model_performance (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                model_name TEXT NOT NULL,
                metric_name TEXT NOT NULL,
                metric_value REAL NOT NULL,
                sample_size INTEGER,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Create indexes for faster queries
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_predictions_alert ON predictions(alert_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_alert ON engagement(alert_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_user ON engagement(user_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_predictions_timestamp ON predictions(timestamp)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_timestamp ON engagement(timestamp)')
        
        conn.commit()
        conn.close()
        
        print("[DataCollector] Database initialized successfully")
    
    def log_prediction(
        self,
        alert_id: str,
        features: dict,
        predicted_score: float,
        model_version: str = 'v1'
    ):
        """
        Log a prediction for future evaluation
        
        Args:
            alert_id: Alert identifier
            features: Feature dict used for prediction
            predicted_score: Predicted priority score
            model_version: Model version string
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT OR IGNORE INTO predictions 
                (alert_id, features, predicted_score, model_version)
                VALUES (?, ?, ?, ?)
            ''', (
                alert_id,
                json.dumps(features),
                predicted_score,
                model_version
            ))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging prediction: {e}")
        finally:
            conn.close()
    
    def log_engagement(
        self,
        alert_id: str,
        user_id: str,
        action: str,
        time_slot: int = None
    ):
        """
        Log user engagement with an alert
        
        Args:
            alert_id: Alert identifier
            user_id: User identifier
            action: Action type ('view', 'click', 'dismiss', 'share', etc.)
            time_slot: Hour of day (0-23) when action occurred
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO engagement 
                (alert_id, user_id, action, time_slot)
                VALUES (?, ?, ?, ?)
            ''', (alert_id, user_id, action, time_slot))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging engagement: {e}")
        finally:
            conn.close()
    
    def log_duplicate_check(
        self,
        alert_id: str,
        is_duplicate: bool,
        best_match_id: str = None,
        similarity: float = None
    ):
        """
        Log duplicate detection result
        
        Args:
            alert_id: Alert being checked
            is_duplicate: Whether duplicate was found
            best_match_id: ID of best matching alert (if duplicate)
            similarity: Similarity score (if duplicate)
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO duplicate_checks 
                (alert_id, is_duplicate, best_match_id, similarity)
                VALUES (?, ?, ?, ?)
            ''', (alert_id, is_duplicate, best_match_id, similarity))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging duplicate check: {e}")
        finally:
            conn.close()
    
    def log_model_performance(
        self,
        model_name: str,
        metric_name: str,
        metric_value: float,
        sample_size: int = None
    ):
        """
        Log model performance metric
        
        Args:
            model_name: Name of model ('scorer', 'duplicate', 'timing')
            metric_name: Metric name ('mae', 'r2', 'accuracy', 'ctr', etc.)
            metric_value: Metric value
            sample_size: Number of samples used for metric
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO model_performance 
                (model_name, metric_name, metric_value, sample_size)
                VALUES (?, ?, ?, ?)
            ''', (model_name, metric_name, metric_value, sample_size))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging performance: {e}")
        finally:
            conn.close()
    
    def get_features(self, alert_id: str) -> dict:
        """Get features for an alert from predictions table"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT features FROM predictions 
            WHERE alert_id = ? 
            ORDER BY timestamp DESC 
            LIMIT 1
        ''', (alert_id,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return json.loads(result[0])
        return {}
    
    def get_training_data(self, min_samples: int = 100, days: int = 30) -> list:
        """
        Get training data for model retraining
        
        Args:
            min_samples: Minimum number of samples required
            days: Number of days to look back
            
        Returns:
            List of dicts with 'features' and 'actual_score'
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get predictions with actual scores from engagement data
        cursor.execute('''
            SELECT 
                p.features,
                CASE 
                    WHEN e.action IN ('click', 'view') THEN 80
                    WHEN e.action = 'share' THEN 100
                    WHEN e.action = 'dismiss' THEN 20
                    ELSE 50
                END as actual_score
            FROM predictions p
            JOIN engagement e ON p.alert_id = e.alert_id
            WHERE p.timestamp >= datetime('now', '-' || ? || ' days')
            AND p.actual_score IS NULL
            GROUP BY p.alert_id
        ''', (days,))
        
        results = cursor.fetchall()
        conn.close()
        
        training_data = [
            {
                'features': json.loads(row[0]),
                'actual_score': row[1]
            }
            for row in results
        ]
        
        return training_data
    
    def get_engagement_stats(self, days: int = 7) -> dict:
        """Get engagement statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT 
                action,
                COUNT(*) as count,
                COUNT(DISTINCT user_id) as unique_users,
                COUNT(DISTINCT alert_id) as unique_alerts
            FROM engagement
            WHERE timestamp >= datetime('now', '-' || ? || ' days')
            GROUP BY action
        ''', (days,))
        
        results = cursor.fetchall()
        conn.close()
        
        stats = {}
        for row in results:
            stats[row[0]] = {
                'count': row[1],
                'unique_users': row[2],
                'unique_alerts': row[3]
            }
        
        return stats
    
    def get_duplicate_stats(self, days: int = 7) -> dict:
        """Get duplicate detection statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT 
                COUNT(*) as total_checks,
                SUM(CASE WHEN is_duplicate THEN 1 ELSE 0 END) as duplicates_found,
                AVG(similarity) as avg_similarity
            FROM duplicate_checks
            WHERE timestamp >= datetime('now', '-' || ? || ' days')
        ''', (days,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            total, duplicates, avg_sim = result
            return {
                'total_checks': total or 0,
                'duplicates_found': duplicates or 0,
                'duplicate_rate': (duplicates / total * 100) if total > 0 else 0,
                'avg_similarity': avg_sim or 0
            }
        
        return {}
    
    def clear_old_data(self, days: int = 90):
        """Clear data older than specified days"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        tables = ['predictions', 'engagement', 'duplicate_checks']
        
        for table in tables:
            cursor.execute(f'''
                DELETE FROM {table}
                WHERE timestamp < datetime('now', '-' || ? || ' days')
            ''', (days,))
        
        conn.commit()
        
        # Get deleted counts
        deleted = cursor.rowcount
        conn.close()
        
        print(f"[DataCollector] Cleared {deleted} old records")
        return deleted


import sqlite3
import json
from datetime import datetime
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import DATABASE_PATH


class DataCollector:
    """
    Collects training data from model predictions and user feedback
    
    Stores data in SQLite for:
    - Model retraining
    - Performance monitoring
    - Analytics
    """
    
    def __init__(self, db_path: Path = DATABASE_PATH):
        self.db_path = db_path
        self._init_db()
        print(f"[DataCollector] Initialized with database: {db_path}")
    
    def _init_db(self):
        """Initialize SQLite database with required tables"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Predictions table - stores model predictions for evaluation
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                features TEXT NOT NULL,
                predicted_score REAL NOT NULL,
                actual_score REAL,
                model_version TEXT DEFAULT 'v1',
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE(alert_id, timestamp)
            )
        ''')
        
        # Engagement table - stores user interactions with alerts
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS engagement (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                action TEXT NOT NULL,
                time_slot INTEGER,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Duplicate checks table - stores duplicate detection results
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS duplicate_checks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                alert_id TEXT NOT NULL,
                is_duplicate BOOLEAN NOT NULL,
                best_match_id TEXT,
                similarity REAL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Model performance table - tracks model metrics over time
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS model_performance (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                model_name TEXT NOT NULL,
                metric_name TEXT NOT NULL,
                metric_value REAL NOT NULL,
                sample_size INTEGER,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Create indexes for faster queries
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_predictions_alert ON predictions(alert_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_alert ON engagement(alert_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_user ON engagement(user_id)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_predictions_timestamp ON predictions(timestamp)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_engagement_timestamp ON engagement(timestamp)')
        
        conn.commit()
        conn.close()
        
        print("[DataCollector] Database initialized successfully")
    
    def log_prediction(
        self,
        alert_id: str,
        features: dict,
        predicted_score: float,
        model_version: str = 'v1'
    ):
        """
        Log a prediction for future evaluation
        
        Args:
            alert_id: Alert identifier
            features: Feature dict used for prediction
            predicted_score: Predicted priority score
            model_version: Model version string
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT OR IGNORE INTO predictions 
                (alert_id, features, predicted_score, model_version)
                VALUES (?, ?, ?, ?)
            ''', (
                alert_id,
                json.dumps(features),
                predicted_score,
                model_version
            ))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging prediction: {e}")
        finally:
            conn.close()
    
    def log_engagement(
        self,
        alert_id: str,
        user_id: str,
        action: str,
        time_slot: int = None
    ):
        """
        Log user engagement with an alert
        
        Args:
            alert_id: Alert identifier
            user_id: User identifier
            action: Action type ('view', 'click', 'dismiss', 'share', etc.)
            time_slot: Hour of day (0-23) when action occurred
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO engagement 
                (alert_id, user_id, action, time_slot)
                VALUES (?, ?, ?, ?)
            ''', (alert_id, user_id, action, time_slot))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging engagement: {e}")
        finally:
            conn.close()
    
    def log_duplicate_check(
        self,
        alert_id: str,
        is_duplicate: bool,
        best_match_id: str = None,
        similarity: float = None
    ):
        """
        Log duplicate detection result
        
        Args:
            alert_id: Alert being checked
            is_duplicate: Whether duplicate was found
            best_match_id: ID of best matching alert (if duplicate)
            similarity: Similarity score (if duplicate)
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO duplicate_checks 
                (alert_id, is_duplicate, best_match_id, similarity)
                VALUES (?, ?, ?, ?)
            ''', (alert_id, is_duplicate, best_match_id, similarity))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging duplicate check: {e}")
        finally:
            conn.close()
    
    def log_model_performance(
        self,
        model_name: str,
        metric_name: str,
        metric_value: float,
        sample_size: int = None
    ):
        """
        Log model performance metric
        
        Args:
            model_name: Name of model ('scorer', 'duplicate', 'timing')
            metric_name: Metric name ('mae', 'r2', 'accuracy', 'ctr', etc.)
            metric_value: Metric value
            sample_size: Number of samples used for metric
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute('''
                INSERT INTO model_performance 
                (model_name, metric_name, metric_value, sample_size)
                VALUES (?, ?, ?, ?)
            ''', (model_name, metric_name, metric_value, sample_size))
            conn.commit()
        except Exception as e:
            print(f"[DataCollector] Error logging performance: {e}")
        finally:
            conn.close()
    
    def get_features(self, alert_id: str) -> dict:
        """Get features for an alert from predictions table"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT features FROM predictions 
            WHERE alert_id = ? 
            ORDER BY timestamp DESC 
            LIMIT 1
        ''', (alert_id,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return json.loads(result[0])
        return {}
    
    def get_training_data(self, min_samples: int = 100, days: int = 30) -> list:
        """
        Get training data for model retraining
        
        Args:
            min_samples: Minimum number of samples required
            days: Number of days to look back
            
        Returns:
            List of dicts with 'features' and 'actual_score'
        """
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Get predictions with actual scores from engagement data
        cursor.execute('''
            SELECT 
                p.features,
                CASE 
                    WHEN e.action IN ('click', 'view') THEN 80
                    WHEN e.action = 'share' THEN 100
                    WHEN e.action = 'dismiss' THEN 20
                    ELSE 50
                END as actual_score
            FROM predictions p
            JOIN engagement e ON p.alert_id = e.alert_id
            WHERE p.timestamp >= datetime('now', '-' || ? || ' days')
            AND p.actual_score IS NULL
            GROUP BY p.alert_id
        ''', (days,))
        
        results = cursor.fetchall()
        conn.close()
        
        training_data = [
            {
                'features': json.loads(row[0]),
                'actual_score': row[1]
            }
            for row in results
        ]
        
        return training_data
    
    def get_engagement_stats(self, days: int = 7) -> dict:
        """Get engagement statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT 
                action,
                COUNT(*) as count,
                COUNT(DISTINCT user_id) as unique_users,
                COUNT(DISTINCT alert_id) as unique_alerts
            FROM engagement
            WHERE timestamp >= datetime('now', '-' || ? || ' days')
            GROUP BY action
        ''', (days,))
        
        results = cursor.fetchall()
        conn.close()
        
        stats = {}
        for row in results:
            stats[row[0]] = {
                'count': row[1],
                'unique_users': row[2],
                'unique_alerts': row[3]
            }
        
        return stats
    
    def get_duplicate_stats(self, days: int = 7) -> dict:
        """Get duplicate detection statistics"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT 
                COUNT(*) as total_checks,
                SUM(CASE WHEN is_duplicate THEN 1 ELSE 0 END) as duplicates_found,
                AVG(similarity) as avg_similarity
            FROM duplicate_checks
            WHERE timestamp >= datetime('now', '-' || ? || ' days')
        ''', (days,))
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            total, duplicates, avg_sim = result
            return {
                'total_checks': total or 0,
                'duplicates_found': duplicates or 0,
                'duplicate_rate': (duplicates / total * 100) if total > 0 else 0,
                'avg_similarity': avg_sim or 0
            }
        
        return {}
    
    def clear_old_data(self, days: int = 90):
        """Clear data older than specified days"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        tables = ['predictions', 'engagement', 'duplicate_checks']
        
        for table in tables:
            cursor.execute(f'''
                DELETE FROM {table}
                WHERE timestamp < datetime('now', '-' || ? || ' days')
            ''', (days,))
        
        conn.commit()
        
        # Get deleted counts
        deleted = cursor.rowcount
        conn.close()
        
        print(f"[DataCollector] Cleared {deleted} old records")
        return deleted



