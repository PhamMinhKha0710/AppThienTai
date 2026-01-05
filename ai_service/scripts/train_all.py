"""
Training Script for AI Service
Train all models from scratch with synthetic/simulated data.
"""
import sys
import time
from pathlib import Path
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))


def train_alert_scorer(n_samples: int = 1000, verbose: bool = True) -> dict:
    """
    Train Alert Scoring Model from scratch
    
    Uses synthetic data generated from rule-based formulas.
    
    Args:
        n_samples: Number of synthetic samples to generate
        verbose: Print progress messages
        
    Returns:
        Dict with training results
    """
    from models.alert_scorer import AlertScoringModel
    from config import MODELS_DIR
    
    if verbose:
        print("\n" + "=" * 60)
        print("Training Alert Scoring Model (Random Forest)")
        print("=" * 60)
    
    start_time = time.time()
    
    # Delete existing model to force retraining
    model_path = MODELS_DIR / "alert_scorer.pkl"
    if model_path.exists():
        model_path.unlink()
        if verbose:
            print(f"  Removed existing model: {model_path.name}")
    
    # Create new model with cold start (will bootstrap from rules)
    if verbose:
        print(f"  Generating {n_samples} synthetic training samples...")
    
    model = AlertScoringModel(cold_start=True)
    
    elapsed = time.time() - start_time
    
    # Get feature importance
    importance = model.get_feature_importance()
    top_features = sorted(importance.items(), key=lambda x: x[1], reverse=True)[:5]
    
    if verbose:
        print(f"\n  Training completed in {elapsed:.2f} seconds")
        print(f"  Model saved to: {model_path}")
        print(f"\n  Top 5 Feature Importance:")
        for name, imp in top_features:
            print(f"    - {name}: {imp:.4f}")
    
    # Test prediction
    test_features = {
        'severity_score': 3,  # high
        'alert_type_score': 2,  # weather
        'hours_since_created': 2,
        'distance_km': 10,
        'target_audience_match': 1,
        'user_previous_interactions': 3,
        'time_of_day': 14,
        'day_of_week': 2,
        'weather_severity': 2,
        'content_length': 200,
        'has_images': 1,
        'has_safety_guide': 1,
        'similar_alerts_count': 2,
        'alert_engagement_rate': 0.7,
        'source_reliability': 0.9,
    }
    
    score, confidence = model.predict_with_confidence(test_features)
    
    if verbose:
        print(f"\n  Test Prediction:")
        print(f"    - Score: {score:.2f}")
        print(f"    - Confidence: {confidence:.2f}")
    
    return {
        'model': 'AlertScoringModel',
        'status': 'success',
        'training_time': elapsed,
        'samples': n_samples,
        'test_score': score,
        'test_confidence': confidence,
        'top_features': dict(top_features)
    }


def initialize_duplicate_detector(verbose: bool = True) -> dict:
    """
    Initialize Semantic Duplicate Detector
    
    Downloads pre-trained Sentence Transformer model (no training needed).
    
    Args:
        verbose: Print progress messages
        
    Returns:
        Dict with initialization results
    """
    if verbose:
        print("\n" + "=" * 60)
        print("Initializing Semantic Duplicate Detector")
        print("=" * 60)
    
    start_time = time.time()
    
    try:
        from models.duplicate_detector import SemanticDuplicateDetector
        
        if verbose:
            print("  Loading pre-trained Sentence Transformer model...")
            print("  (This may take a few minutes on first run)")
        
        detector = SemanticDuplicateDetector()
        
        elapsed = time.time() - start_time
        
        # Test similarity
        test1 = "Mưa lớn gây ngập lụt tại quận 1"
        test2 = "Ngập lụt do mưa lớn ở khu vực quận 1"
        test3 = "Động đất mạnh 5.5 độ richter"
        
        sim_same = detector.calculate_similarity(test1, test2)
        sim_diff = detector.calculate_similarity(test1, test3)
        
        if verbose:
            print(f"\n  Model loaded in {elapsed:.2f} seconds")
            print(f"\n  Test Similarity:")
            print(f"    - Similar texts: {sim_same:.4f} (should be high)")
            print(f"    - Different texts: {sim_diff:.4f} (should be low)")
        
        return {
            'model': 'SemanticDuplicateDetector',
            'status': 'success',
            'loading_time': elapsed,
            'test_similar': sim_same,
            'test_different': sim_diff
        }
        
    except ImportError as e:
        if verbose:
            print(f"  Warning: Could not load Sentence Transformers: {e}")
            print("  Using lightweight Jaccard similarity fallback")
        
        from models.duplicate_detector import DuplicateDetectorLite
        detector = DuplicateDetectorLite()
        
        elapsed = time.time() - start_time
        
        return {
            'model': 'DuplicateDetectorLite',
            'status': 'fallback',
            'loading_time': elapsed
        }


def train_notification_timing(simulate_pattern: bool = True, verbose: bool = True) -> dict:
    """
    Initialize Notification Timing Model
    
    Optionally simulates realistic engagement patterns.
    
    Args:
        simulate_pattern: Whether to simulate realistic day patterns
        verbose: Print progress messages
        
    Returns:
        Dict with training results
    """
    from models.notification_timing import NotificationTimingModel
    from config import MODELS_DIR
    
    if verbose:
        print("\n" + "=" * 60)
        print("Training Notification Timing Model (Thompson Sampling)")
        print("=" * 60)
    
    start_time = time.time()
    
    # Delete existing parameters to reset
    params_path = MODELS_DIR / "notification_timing.json"
    if params_path.exists():
        params_path.unlink()
        if verbose:
            print(f"  Removed existing parameters: {params_path.name}")
    
    # Create new model
    if verbose:
        print("  Initializing with uniform prior...")
    
    model = NotificationTimingModel()
    
    # Optionally simulate realistic patterns
    if simulate_pattern:
        if verbose:
            print("  Simulating realistic day patterns...")
        result = model.simulate_day_pattern()
        best_times = result['best_times']
    else:
        model.reset()
        best_times = model.get_best_times(top_k=5)
    
    elapsed = time.time() - start_time
    
    if verbose:
        print(f"\n  Initialization completed in {elapsed:.2f} seconds")
        print(f"  Parameters saved to: {params_path}")
        print(f"\n  Best notification times:")
        for t in best_times:
            print(f"    - {t['hour']:02d}:00 - Success rate: {t['success_rate']:.2f}, Confidence: {t['confidence']:.2f}")
    
    # Test selection
    selected_slot = model.select_time_slot(alert_severity='high')
    
    if verbose:
        print(f"\n  Test Selection (high severity): {selected_slot:02d}:00")
    
    return {
        'model': 'NotificationTimingModel',
        'status': 'success',
        'training_time': elapsed,
        'simulated_pattern': simulate_pattern,
        'best_times': best_times,
        'test_selection': selected_slot
    }


def train_all(
    n_samples: int = 1000,
    simulate_timing: bool = True,
    verbose: bool = True
) -> dict:
    """
    Train all AI models from scratch
    
    Args:
        n_samples: Number of synthetic samples for Alert Scorer
        simulate_timing: Whether to simulate patterns for Notification Timing
        verbose: Print progress messages
        
    Returns:
        Dict with all training results
    """
    results = {
        'timestamp': datetime.now().isoformat(),
        'models': {}
    }
    
    print("\n" + "=" * 60)
    print("  AI SERVICE - TRAINING ALL MODELS FROM SCRATCH")
    print("=" * 60)
    print(f"\nStarted at: {results['timestamp']}")
    
    total_start = time.time()
    
    # Train Alert Scorer
    try:
        results['models']['alert_scorer'] = train_alert_scorer(n_samples, verbose)
    except Exception as e:
        results['models']['alert_scorer'] = {'status': 'error', 'error': str(e)}
        print(f"\nError training Alert Scorer: {e}")
    
    # Initialize Duplicate Detector
    try:
        results['models']['duplicate_detector'] = initialize_duplicate_detector(verbose)
    except Exception as e:
        results['models']['duplicate_detector'] = {'status': 'error', 'error': str(e)}
        print(f"\nError initializing Duplicate Detector: {e}")
    
    # Train Notification Timing
    try:
        results['models']['notification_timing'] = train_notification_timing(simulate_timing, verbose)
    except Exception as e:
        results['models']['notification_timing'] = {'status': 'error', 'error': str(e)}
        print(f"\nError training Notification Timing: {e}")
    
    total_elapsed = time.time() - total_start
    results['total_time'] = total_elapsed
    
    # Summary
    print("\n" + "=" * 60)
    print("  TRAINING SUMMARY")
    print("=" * 60)
    
    success_count = sum(1 for m in results['models'].values() if m.get('status') == 'success')
    total_count = len(results['models'])
    
    print(f"\n  Models trained: {success_count}/{total_count}")
    print(f"  Total time: {total_elapsed:.2f} seconds")
    
    for name, result in results['models'].items():
        status = result.get('status', 'unknown')
        status_icon = "[OK]" if status == 'success' else "[FAIL]" if status == 'error' else "[~]"
        print(f"  {status_icon} {name}: {status}")
    
    print("\n" + "=" * 60)
    print("  Training complete! Models are ready to use.")
    print("=" * 60 + "\n")
    
    return results


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Train AI Service models")
    parser.add_argument("--samples", type=int, default=1000, help="Number of synthetic samples")
    parser.add_argument("--no-simulate", action="store_true", help="Don't simulate timing patterns")
    parser.add_argument("-q", "--quiet", action="store_true", help="Quiet mode")
    parser.add_argument("--scorer-only", action="store_true", help="Only train Alert Scorer")
    parser.add_argument("--timing-only", action="store_true", help="Only train Notification Timing")
    parser.add_argument("--detector-only", action="store_true", help="Only initialize Duplicate Detector")
    
    args = parser.parse_args()
    verbose = not args.quiet
    
    if args.scorer_only:
        train_alert_scorer(args.samples, verbose)
    elif args.timing_only:
        train_notification_timing(not args.no_simulate, verbose)
    elif args.detector_only:
        initialize_duplicate_detector(verbose)
    else:
        train_all(args.samples, not args.no_simulate, verbose)

