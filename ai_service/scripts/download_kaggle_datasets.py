"""
Download Kaggle Datasets for Disaster Prediction

This script downloads high-quality, free datasets from Kaggle:
1. Flood Prediction Dataset
2. Global Landslide Catalog (NASA)
3. EM-DAT Vietnam Disasters

Requires: Kaggle API credentials
"""
import os
import sys
import zipfile
import shutil
from pathlib import Path
import subprocess

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))
from config import DATA_DIR

# Kaggle datasets to download
DATASETS = {
    'flood_prediction': {
        'dataset': 'siddharthss/flood-prediction-dataset',
        'description': 'Flood Prediction Dataset (50K rows, 21 features)',
        'output_dir': 'kaggle/flood'
    },
    'landslide_nasa': {
        'dataset': 'nasa/global-landslide-catalog',
        'description': 'NASA Global Landslide Catalog',
        'output_dir': 'kaggle/landslide'
    },
    'emdat_vietnam': {
        'dataset': 'opendevelopmentmekong/emdat',
        'description': 'EM-DAT Vietnam Disasters (1953-2023)',
        'output_dir': 'kaggle/emdat'
    },
    'sen12flood': {
        'dataset': 'franciscoescobar/satellite-images-of-water-bodies',
        'description': 'SEN12FLOOD - Satellite Flood Detection',
        'output_dir': 'kaggle/sen12flood'
    },
    'landslide4sense': {
        'dataset': 'isaatm/landslide4sense-dataset',
        'description': 'Landslide4Sense Challenge Dataset',
        'output_dir': 'kaggle/landslide4sense'
    }
}


def setup_kaggle_credentials(username: str = None, token: str = None):
    """
    Setup Kaggle API credentials
    
    Args:
        username: Kaggle username (optional if kaggle.json exists)
        token: Kaggle API token (optional if kaggle.json exists)
    """
    kaggle_dir = Path.home() / '.kaggle'
    kaggle_json = kaggle_dir / 'kaggle.json'
    
    # Check if credentials already exist
    if kaggle_json.exists():
        print(f"✅ Kaggle credentials found at {kaggle_json}")
        return True
    
    # Create .kaggle directory
    kaggle_dir.mkdir(parents=True, exist_ok=True)
    
    # If token provided, create kaggle.json
    if username and token:
        import json
        credentials = {
            "username": username,
            "key": token
        }
        
        with open(kaggle_json, 'w') as f:
            json.dump(credentials, f, indent=2)
        
        # Set proper permissions (important for security)
        if os.name != 'nt':  # Unix/Linux/Mac
            os.chmod(kaggle_json, 0o600)
        
        print(f"✅ Created Kaggle credentials at {kaggle_json}")
        return True
    else:
        print(f"❌ No Kaggle credentials found!")
        print(f"\nPlease create {kaggle_json} with:")
        print('{')
        print('  "username": "your_username",')
        print('  "key": "your_api_key"')
        print('}')
        print(f"\nOr download from: https://www.kaggle.com/settings")
        return False


def check_kaggle_cli():
    """Check if Kaggle CLI is installed"""
    try:
        result = subprocess.run(
            ['kaggle', '--version'],
            capture_output=True,
            text=True,
            timeout=10
        )
        print(f"✅ Kaggle CLI: {result.stdout.strip()}")
        return True
    except FileNotFoundError:
        print("❌ Kaggle CLI not found!")
        print("\nInstall with: pip install kaggle")
        return False
    except Exception as e:
        print(f"❌ Error checking Kaggle CLI: {e}")
        return False


def download_dataset(dataset_key: str, dataset_info: dict, force: bool = False):
    """
    Download a Kaggle dataset
    
    Args:
        dataset_key: Dataset key
        dataset_info: Dataset information
        force: Force re-download even if exists
    """
    dataset_name = dataset_info['dataset']
    description = dataset_info['description']
    output_dir = DATA_DIR / dataset_info['output_dir']
    
    print("\n" + "=" * 70)
    print(f"📦 {description}")
    print(f"   Dataset: {dataset_name}")
    print(f"   Output: {output_dir}")
    print("=" * 70)
    
    # Check if already exists
    if output_dir.exists() and not force:
        print(f"⏭️  Already exists. Use --force to re-download")
        return True
    
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Download using kaggle CLI
    try:
        cmd = [
            'kaggle', 'datasets', 'download',
            '-d', dataset_name,
            '-p', str(output_dir),
            '--unzip'
        ]
        
        print(f"\n🔄 Downloading...")
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=600  # 10 minutes timeout
        )
        
        if result.returncode == 0:
            print(f"✅ Downloaded successfully!")
            print(f"   Location: {output_dir}")
            
            # List downloaded files
            files = list(output_dir.glob('*'))
            print(f"   Files: {len(files)}")
            for f in files[:5]:  # Show first 5 files
                print(f"     - {f.name}")
            if len(files) > 5:
                print(f"     ... and {len(files) - 5} more")
            
            return True
        else:
            print(f"❌ Download failed!")
            print(f"   Error: {result.stderr}")
            return False
            
    except subprocess.TimeoutExpired:
        print(f"❌ Download timeout (>10 minutes)")
        return False
    except Exception as e:
        print(f"❌ Error downloading: {e}")
        return False


def download_all(datasets_to_download: list = None, force: bool = False):
    """
    Download all or selected datasets
    
    Args:
        datasets_to_download: List of dataset keys to download (None = all)
        force: Force re-download
    """
    if datasets_to_download is None:
        datasets_to_download = list(DATASETS.keys())
    
    print("\n" + "🌊" * 35)
    print("  KAGGLE DATASETS DOWNLOADER")
    print("🌊" * 35)
    
    results = {}
    for key in datasets_to_download:
        if key not in DATASETS:
            print(f"\n❌ Unknown dataset: {key}")
            print(f"   Available: {', '.join(DATASETS.keys())}")
            continue
        
        success = download_dataset(key, DATASETS[key], force=force)
        results[key] = success
    
    # Summary
    print("\n" + "=" * 70)
    print("📊 DOWNLOAD SUMMARY")
    print("=" * 70)
    
    successful = sum(results.values())
    total = len(results)
    
    for key, success in results.items():
        status = "✅" if success else "❌"
        print(f"{status} {key}: {DATASETS[key]['description']}")
    
    print(f"\nTotal: {successful}/{total} successful")
    print("=" * 70)
    
    return results


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Download Kaggle datasets for disaster prediction')
    parser.add_argument(
        '--datasets',
        nargs='+',
        choices=list(DATASETS.keys()) + ['all'],
        default=['all'],
        help='Datasets to download (default: all)'
    )
    parser.add_argument(
        '--force',
        action='store_true',
        help='Force re-download even if exists'
    )
    parser.add_argument(
        '--setup-kaggle',
        action='store_true',
        help='Setup Kaggle credentials manually'
    )
    parser.add_argument(
        '--token',
        type=str,
        help='Kaggle API token (optional)'
    )
    
    args = parser.parse_args()
    
    # Setup Kaggle credentials if requested
    if args.setup_kaggle:
        print("\n📋 Setting up Kaggle credentials...")
        print("Please enter your Kaggle credentials")
        print("(Get from: https://www.kaggle.com/settings -> API -> Create New Token)\n")
        
        username = input("Username: ").strip()
        if args.token:
            token = args.token
        else:
            token = input("API Token: ").strip()
        
        if not setup_kaggle_credentials(username, token):
            sys.exit(1)
    
    # Check prerequisites
    print("\n🔍 Checking prerequisites...")
    
    if not check_kaggle_cli():
        print("\n💡 Install Kaggle CLI first:")
        print("   pip install kaggle")
        sys.exit(1)
    
    if not setup_kaggle_credentials():
        sys.exit(1)
    
    # Test Kaggle API
    print("\n🧪 Testing Kaggle API...")
    try:
        result = subprocess.run(
            ['kaggle', 'datasets', 'list', '--max-size', '100'],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode == 0:
            print("✅ Kaggle API working!")
        else:
            print(f"❌ Kaggle API error: {result.stderr}")
            sys.exit(1)
    except Exception as e:
        print(f"❌ Error testing Kaggle API: {e}")
        sys.exit(1)
    
    # Download datasets
    datasets = args.datasets if 'all' not in args.datasets else None
    download_all(datasets, force=args.force)
