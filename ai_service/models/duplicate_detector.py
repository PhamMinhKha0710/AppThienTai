"""Semantic Duplicate Detection using Sentence Transformers"""
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import SENTENCE_TRANSFORMER_MODEL, DUPLICATE_SIMILARITY_THRESHOLD, CACHE_DIR


class SemanticDuplicateDetector:
    """
    Semantic-based duplicate detection using pre-trained Sentence Transformers
    
    Uses multilingual BERT model to understand semantic meaning of alerts,
    providing much better duplicate detection than simple text matching.
    
    Features:
    - Zero-shot: Works immediately without training
    - Multilingual: Supports Vietnamese and English
    - Semantic: Understands meaning, not just words
    - Fast: ~50ms per comparison with caching
    """
    
    def __init__(self, threshold: float = None):
        print(f"[DuplicateDetector] Loading model: {SENTENCE_TRANSFORMER_MODEL}...")
        
        # Pre-trained multilingual model
        self.model = SentenceTransformer(
            SENTENCE_TRANSFORMER_MODEL,
            cache_folder=str(CACHE_DIR)
        )
        
        self.threshold = threshold or DUPLICATE_SIMILARITY_THRESHOLD
        
        # Embedding cache for performance
        self._embedding_cache = {}
        
        print(f"[DuplicateDetector] Model loaded. Threshold: {self.threshold}")
    
    def get_embedding(self, text: str) -> np.ndarray:
        """
        Convert text to semantic embedding vector
        
        Args:
            text: Input text (alert content)
            
        Returns:
            384-dimensional embedding vector
        """
        # Check cache first
        if text in self._embedding_cache:
            return self._embedding_cache[text]
        
        # Generate embedding
        embedding = self.model.encode(text, convert_to_numpy=True)
        
        # Cache it
        self._embedding_cache[text] = embedding
        
        # Limit cache size to 1000 entries
        if len(self._embedding_cache) > 1000:
            # Remove oldest entry
            self._embedding_cache.pop(next(iter(self._embedding_cache)))
        
        return embedding
    
    def calculate_similarity(self, text1: str, text2: str) -> float:
        """
        Calculate semantic similarity between two texts
        
        Args:
            text1: First text
            text2: Second text
            
        Returns:
            Cosine similarity (0-1, where 1 is identical)
        """
        emb1 = self.get_embedding(text1)
        emb2 = self.get_embedding(text2)
        
        similarity = cosine_similarity(
            emb1.reshape(1, -1),
            emb2.reshape(1, -1)
        )[0][0]
        
        return float(similarity)
    
    def is_duplicate(self, alert1: dict, alert2: dict) -> bool:
        """
        Check if two alerts are semantically similar (duplicates)
        
        Args:
            alert1: First alert dict with keys: content, alert_type, severity, province
            alert2: Second alert dict
            
        Returns:
            True if alerts are duplicates
        """
        # Fast rule-based pre-filter
        if not self._basic_match(alert1, alert2):
            return False
        
        # Semantic similarity check
        similarity = self.calculate_similarity(
            alert1['content'],
            alert2['content']
        )
        
        return similarity >= self.threshold
    
    def _basic_match(self, alert1: dict, alert2: dict) -> bool:
        """
        Fast rule-based pre-filter
        
        Only check semantic similarity if basic criteria match:
        - Same alert type
        - Same severity
        - Same province
        """
        return (
            alert1.get('alert_type') == alert2.get('alert_type') and
            alert1.get('severity') == alert2.get('severity') and
            alert1.get('province') == alert2.get('province')
        )
    
    def find_duplicates(
        self,
        new_alert: dict,
        existing_alerts: list,
        return_all: bool = False
    ) -> list:
        """
        Find all duplicate alerts for a new alert
        
        Args:
            new_alert: New alert to check
            existing_alerts: List of existing alerts
            return_all: If True, return all matches above threshold.
                       If False, return only the best match.
        
        Returns:
            List of dicts with 'alert' and 'similarity' keys,
            sorted by similarity (highest first)
        """
        duplicates = []
        
        # Get embedding once for new alert
        new_emb = self.get_embedding(new_alert['content'])
        
        for alert in existing_alerts:
            # Skip if basic criteria don't match
            if not self._basic_match(new_alert, alert):
                continue
            
            # Calculate semantic similarity
            alert_emb = self.get_embedding(alert['content'])
            similarity = cosine_similarity(
                new_emb.reshape(1, -1),
                alert_emb.reshape(1, -1)
            )[0][0]
            
            # Add if above threshold
            if similarity >= self.threshold:
                duplicates.append({
                    'alert': alert,
                    'similarity': float(similarity)
                })
        
        # Sort by similarity (highest first)
        duplicates.sort(key=lambda x: x['similarity'], reverse=True)
        
        # Return all or just best match
        if return_all:
            return duplicates
        else:
            return duplicates[:1] if duplicates else []
    
    def batch_find_duplicates(
        self,
        new_alerts: list,
        existing_alerts: list
    ) -> dict:
        """
        Find duplicates for multiple new alerts at once (batch processing)
        
        Args:
            new_alerts: List of new alerts to check
            existing_alerts: List of existing alerts
            
        Returns:
            Dict mapping alert IDs to their duplicate lists
        """
        results = {}
        
        for new_alert in new_alerts:
            alert_id = new_alert.get('id', 'unknown')
            duplicates = self.find_duplicates(new_alert, existing_alerts, return_all=True)
            results[alert_id] = duplicates
        
        return results
    
    def clear_cache(self):
        """Clear embedding cache"""
        self._embedding_cache.clear()
        print("[DuplicateDetector] Cache cleared")
    
    def get_cache_stats(self) -> dict:
        """Get cache statistics"""
        return {
            'cache_size': len(self._embedding_cache),
            'cache_limit': 1000
        }


class DuplicateDetectorLite:
    """
    Lightweight duplicate detector without ML
    
    Falls back to simple text similarity if Sentence Transformers unavailable.
    Uses Jaccard similarity like the Dart implementation.
    """
    
    def __init__(self, threshold: float = 0.80):
        self.threshold = threshold
        print("[DuplicateDetector] Using LITE version (Jaccard similarity)")
    
    def _tokenize(self, text: str) -> set:
        """Tokenize text into words"""
        import re
        words = re.sub(r'[^\w\s]', '', text.lower()).split()
        return set(w for w in words if len(w) > 2)
    
    def calculate_similarity(self, text1: str, text2: str) -> float:
        """Calculate Jaccard similarity"""
        words1 = self._tokenize(text1)
        words2 = self._tokenize(text2)
        
        if not words1 and not words2:
            return 1.0
        if not words1 or not words2:
            return 0.0
        
        intersection = len(words1 & words2)
        union = len(words1 | words2)
        
        return intersection / union if union > 0 else 0.0
    
    def is_duplicate(self, alert1: dict, alert2: dict) -> bool:
        """Check if alerts are duplicates using Jaccard"""
        similarity = self.calculate_similarity(
            alert1['content'],
            alert2['content']
        )
        return similarity >= self.threshold
    
    def find_duplicates(self, new_alert: dict, existing_alerts: list) -> list:
        """Find duplicates using Jaccard similarity"""
        duplicates = []
        
        for alert in existing_alerts:
            similarity = self.calculate_similarity(
                new_alert['content'],
                alert['content']
            )
            
            if similarity >= self.threshold:
                duplicates.append({
                    'alert': alert,
                    'similarity': float(similarity)
                })
        
        duplicates.sort(key=lambda x: x['similarity'], reverse=True)
        return duplicates


import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from pathlib import Path
import sys

sys.path.append(str(Path(__file__).parent.parent))
from config import SENTENCE_TRANSFORMER_MODEL, DUPLICATE_SIMILARITY_THRESHOLD, CACHE_DIR


class SemanticDuplicateDetector:
    """
    Semantic-based duplicate detection using pre-trained Sentence Transformers
    
    Uses multilingual BERT model to understand semantic meaning of alerts,
    providing much better duplicate detection than simple text matching.
    
    Features:
    - Zero-shot: Works immediately without training
    - Multilingual: Supports Vietnamese and English
    - Semantic: Understands meaning, not just words
    - Fast: ~50ms per comparison with caching
    """
    
    def __init__(self, threshold: float = None):
        print(f"[DuplicateDetector] Loading model: {SENTENCE_TRANSFORMER_MODEL}...")
        
        # Pre-trained multilingual model
        self.model = SentenceTransformer(
            SENTENCE_TRANSFORMER_MODEL,
            cache_folder=str(CACHE_DIR)
        )
        
        self.threshold = threshold or DUPLICATE_SIMILARITY_THRESHOLD
        
        # Embedding cache for performance
        self._embedding_cache = {}
        
        print(f"[DuplicateDetector] Model loaded. Threshold: {self.threshold}")
    
    def get_embedding(self, text: str) -> np.ndarray:
        """
        Convert text to semantic embedding vector
        
        Args:
            text: Input text (alert content)
            
        Returns:
            384-dimensional embedding vector
        """
        # Check cache first
        if text in self._embedding_cache:
            return self._embedding_cache[text]
        
        # Generate embedding
        embedding = self.model.encode(text, convert_to_numpy=True)
        
        # Cache it
        self._embedding_cache[text] = embedding
        
        # Limit cache size to 1000 entries
        if len(self._embedding_cache) > 1000:
            # Remove oldest entry
            self._embedding_cache.pop(next(iter(self._embedding_cache)))
        
        return embedding
    
    def calculate_similarity(self, text1: str, text2: str) -> float:
        """
        Calculate semantic similarity between two texts
        
        Args:
            text1: First text
            text2: Second text
            
        Returns:
            Cosine similarity (0-1, where 1 is identical)
        """
        emb1 = self.get_embedding(text1)
        emb2 = self.get_embedding(text2)
        
        similarity = cosine_similarity(
            emb1.reshape(1, -1),
            emb2.reshape(1, -1)
        )[0][0]
        
        return float(similarity)
    
    def is_duplicate(self, alert1: dict, alert2: dict) -> bool:
        """
        Check if two alerts are semantically similar (duplicates)
        
        Args:
            alert1: First alert dict with keys: content, alert_type, severity, province
            alert2: Second alert dict
            
        Returns:
            True if alerts are duplicates
        """
        # Fast rule-based pre-filter
        if not self._basic_match(alert1, alert2):
            return False
        
        # Semantic similarity check
        similarity = self.calculate_similarity(
            alert1['content'],
            alert2['content']
        )
        
        return similarity >= self.threshold
    
    def _basic_match(self, alert1: dict, alert2: dict) -> bool:
        """
        Fast rule-based pre-filter
        
        Only check semantic similarity if basic criteria match:
        - Same alert type
        - Same severity
        - Same province
        """
        return (
            alert1.get('alert_type') == alert2.get('alert_type') and
            alert1.get('severity') == alert2.get('severity') and
            alert1.get('province') == alert2.get('province')
        )
    
    def find_duplicates(
        self,
        new_alert: dict,
        existing_alerts: list,
        return_all: bool = False
    ) -> list:
        """
        Find all duplicate alerts for a new alert
        
        Args:
            new_alert: New alert to check
            existing_alerts: List of existing alerts
            return_all: If True, return all matches above threshold.
                       If False, return only the best match.
        
        Returns:
            List of dicts with 'alert' and 'similarity' keys,
            sorted by similarity (highest first)
        """
        duplicates = []
        
        # Get embedding once for new alert
        new_emb = self.get_embedding(new_alert['content'])
        
        for alert in existing_alerts:
            # Skip if basic criteria don't match
            if not self._basic_match(new_alert, alert):
                continue
            
            # Calculate semantic similarity
            alert_emb = self.get_embedding(alert['content'])
            similarity = cosine_similarity(
                new_emb.reshape(1, -1),
                alert_emb.reshape(1, -1)
            )[0][0]
            
            # Add if above threshold
            if similarity >= self.threshold:
                duplicates.append({
                    'alert': alert,
                    'similarity': float(similarity)
                })
        
        # Sort by similarity (highest first)
        duplicates.sort(key=lambda x: x['similarity'], reverse=True)
        
        # Return all or just best match
        if return_all:
            return duplicates
        else:
            return duplicates[:1] if duplicates else []
    
    def batch_find_duplicates(
        self,
        new_alerts: list,
        existing_alerts: list
    ) -> dict:
        """
        Find duplicates for multiple new alerts at once (batch processing)
        
        Args:
            new_alerts: List of new alerts to check
            existing_alerts: List of existing alerts
            
        Returns:
            Dict mapping alert IDs to their duplicate lists
        """
        results = {}
        
        for new_alert in new_alerts:
            alert_id = new_alert.get('id', 'unknown')
            duplicates = self.find_duplicates(new_alert, existing_alerts, return_all=True)
            results[alert_id] = duplicates
        
        return results
    
    def clear_cache(self):
        """Clear embedding cache"""
        self._embedding_cache.clear()
        print("[DuplicateDetector] Cache cleared")
    
    def get_cache_stats(self) -> dict:
        """Get cache statistics"""
        return {
            'cache_size': len(self._embedding_cache),
            'cache_limit': 1000
        }


class DuplicateDetectorLite:
    """
    Lightweight duplicate detector without ML
    
    Falls back to simple text similarity if Sentence Transformers unavailable.
    Uses Jaccard similarity like the Dart implementation.
    """
    
    def __init__(self, threshold: float = 0.80):
        self.threshold = threshold
        print("[DuplicateDetector] Using LITE version (Jaccard similarity)")
    
    def _tokenize(self, text: str) -> set:
        """Tokenize text into words"""
        import re
        words = re.sub(r'[^\w\s]', '', text.lower()).split()
        return set(w for w in words if len(w) > 2)
    
    def calculate_similarity(self, text1: str, text2: str) -> float:
        """Calculate Jaccard similarity"""
        words1 = self._tokenize(text1)
        words2 = self._tokenize(text2)
        
        if not words1 and not words2:
            return 1.0
        if not words1 or not words2:
            return 0.0
        
        intersection = len(words1 & words2)
        union = len(words1 | words2)
        
        return intersection / union if union > 0 else 0.0
    
    def is_duplicate(self, alert1: dict, alert2: dict) -> bool:
        """Check if alerts are duplicates using Jaccard"""
        similarity = self.calculate_similarity(
            alert1['content'],
            alert2['content']
        )
        return similarity >= self.threshold
    
    def find_duplicates(self, new_alert: dict, existing_alerts: list) -> list:
        """Find duplicates using Jaccard similarity"""
        duplicates = []
        
        for alert in existing_alerts:
            similarity = self.calculate_similarity(
                new_alert['content'],
                alert['content']
            )
            
            if similarity >= self.threshold:
                duplicates.append({
                    'alert': alert,
                    'similarity': float(similarity)
                })
        
        duplicates.sort(key=lambda x: x['similarity'], reverse=True)
        return duplicates



