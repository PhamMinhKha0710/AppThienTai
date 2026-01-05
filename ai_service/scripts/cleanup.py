"""
Cleanup Script for AI Service
Removes all trained models, databases, and caches to start fresh.
"""
import os
import shutil
from pathlib import Path


def get_ai_service_dir() -> Path:
    """Get the ai_service directory path"""
    return Path(__file__).parent.parent


def cleanup_models(verbose: bool = True) -> int:
    """
    Remove all trained model files
    
    Returns:
        Number of files deleted
    """
    ai_dir = get_ai_service_dir()
    models_dir = ai_dir / "data" / "models"
    
    deleted = 0
    
    if models_dir.exists():
        # Remove .pkl files (scikit-learn models)
        for pkl_file in models_dir.glob("*.pkl"):
            if verbose:
                print(f"  Deleting: {pkl_file.name}")
            pkl_file.unlink()
            deleted += 1
        
        # Remove .json files (timing model parameters)
        for json_file in models_dir.glob("*.json"):
            if verbose:
                print(f"  Deleting: {json_file.name}")
            json_file.unlink()
            deleted += 1
        
        # Remove .joblib files
        for joblib_file in models_dir.glob("*.joblib"):
            if verbose:
                print(f"  Deleting: {joblib_file.name}")
            joblib_file.unlink()
            deleted += 1
    
    return deleted


def cleanup_database(verbose: bool = True) -> int:
    """
    Remove feedback database
    
    Returns:
        Number of files deleted
    """
    ai_dir = get_ai_service_dir()
    training_dir = ai_dir / "data" / "training"
    
    deleted = 0
    
    if training_dir.exists():
        # Remove SQLite database
        db_file = training_dir / "feedback.db"
        if db_file.exists():
            if verbose:
                print(f"  Deleting: {db_file.name}")
            db_file.unlink()
            deleted += 1
        
        # Remove any .db files
        for db in training_dir.glob("*.db"):
            if verbose:
                print(f"  Deleting: {db.name}")
            db.unlink()
            deleted += 1
        
        # Remove .db-journal files (SQLite journals)
        for journal in training_dir.glob("*.db-journal"):
            if verbose:
                print(f"  Deleting: {journal.name}")
            journal.unlink()
            deleted += 1
    
    return deleted


def cleanup_cache(verbose: bool = True) -> int:
    """
    Remove Sentence Transformers cache
    
    Returns:
        Number of items deleted
    """
    ai_dir = get_ai_service_dir()
    cache_dir = ai_dir / "data" / "cache"
    
    deleted = 0
    
    if cache_dir.exists():
        # Remove all contents in cache directory
        for item in cache_dir.iterdir():
            if item.is_dir():
                if verbose:
                    print(f"  Deleting directory: {item.name}/")
                shutil.rmtree(item)
            else:
                if verbose:
                    print(f"  Deleting: {item.name}")
                item.unlink()
            deleted += 1
    
    return deleted


def cleanup_all(verbose: bool = True) -> dict:
    """
    Clean up all data: models, database, and cache
    
    Returns:
        Dict with counts of deleted items
    """
    results = {
        'models': 0,
        'database': 0,
        'cache': 0
    }
    
    print("=" * 60)
    print("AI Service Cleanup - Starting...")
    print("=" * 60)
    
    # Cleanup models
    print("\n[1/3] Cleaning up trained models...")
    results['models'] = cleanup_models(verbose)
    if results['models'] == 0:
        print("  (no models found)")
    
    # Cleanup database
    print("\n[2/3] Cleaning up database...")
    results['database'] = cleanup_database(verbose)
    if results['database'] == 0:
        print("  (no database found)")
    
    # Cleanup cache
    print("\n[3/3] Cleaning up cache...")
    results['cache'] = cleanup_cache(verbose)
    if results['cache'] == 0:
        print("  (no cache found)")
    
    # Summary
    total = sum(results.values())
    print("\n" + "=" * 60)
    print(f"Cleanup complete! Deleted {total} items:")
    print(f"  - Models: {results['models']}")
    print(f"  - Database: {results['database']}")
    print(f"  - Cache: {results['cache']}")
    print("=" * 60)
    
    return results


def ensure_directories():
    """Ensure data directories exist after cleanup"""
    ai_dir = get_ai_service_dir()
    
    directories = [
        ai_dir / "data" / "models",
        ai_dir / "data" / "training",
        ai_dir / "data" / "cache"
    ]
    
    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)
    
    print("\nData directories verified/created.")


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Cleanup AI Service data")
    parser.add_argument("--models-only", action="store_true", help="Only clean up models")
    parser.add_argument("--db-only", action="store_true", help="Only clean up database")
    parser.add_argument("--cache-only", action="store_true", help="Only clean up cache")
    parser.add_argument("-q", "--quiet", action="store_true", help="Quiet mode (less output)")
    parser.add_argument("-y", "--yes", action="store_true", help="Skip confirmation prompt")
    
    args = parser.parse_args()
    verbose = not args.quiet
    
    # Determine what to clean
    if args.models_only:
        print("Cleaning up models only...")
        cleanup_models(verbose)
    elif args.db_only:
        print("Cleaning up database only...")
        cleanup_database(verbose)
    elif args.cache_only:
        print("Cleaning up cache only...")
        cleanup_cache(verbose)
    else:
        # Clean everything
        if not args.yes:
            print("This will delete all trained models, databases, and caches.")
            response = input("Are you sure? (y/N): ").strip().lower()
            if response != 'y':
                print("Cancelled.")
                exit(0)
        
        cleanup_all(verbose)
    
    # Ensure directories exist
    ensure_directories()













