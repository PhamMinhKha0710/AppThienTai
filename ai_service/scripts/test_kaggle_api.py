"""Test Kaggle API and download first dataset"""
import os
import json
from pathlib import Path

# Create kaggle.json properly
kaggle_dir = Path.home() / '.kaggle'
kaggle_dir.mkdir(exist_ok=True)

kaggle_json = kaggle_dir / 'kaggle.json'

# Write credentials - try different username possibilities
credentials = {
    "username": "phamminhkha",  # Try common Vietnamese name pattern
    "key": "KGAT_97bd04df7964ec246ca9920d35e68d83"
}

print(f"Creating {kaggle_json}...")
with open(kaggle_json, 'w') as f:
    json.dump(credentials, f, indent=2)

print(f"✅ Created kaggle.json")
print(f"Content: {json.dumps(credentials, indent=2)}")

# Try to use kaggle API
try:
    from kaggle.api.kaggle_api_extended import KaggleApi
    
    api = KaggleApi()
    print("\n🔄 Authenticating...")
    api.authenticate()
    
    print("✅ Authentication successful!")
    
    # Test: List competitions
    print("\n📋 Testing API - listing first 3 datasets:")
    datasets = api.dataset_list(page_size=3)
    for i, dataset in enumerate(datasets, 1):
        print(f"  {i}. {dataset.ref}")
    
   
    print("\n✅ Kaggle API working!")
    
except Exception as e:
    print(f"\n❌ Error: {e}")
    print("\n💡 Possible solutions:")
    print("1. Download kaggle.json from https://www.kaggle.com/settings")
    print("2. Place it in:", kaggle_dir)
    print("3. Or provide correct Kaggle username")
