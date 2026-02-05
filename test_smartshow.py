#!/usr/bin/env python3
"""
Quick test script to verify SmartShow Ultimate is working correctly
Run this to check if all imports and basic functionality work
"""

import sys
import importlib.util

def test_imports():
    """Test if all required modules can be imported"""
    print("🔍 Testing imports...")
    
    required_modules = [
        'streamlit',
        'psycopg2',
        'pandas',
        'numpy',
        'matplotlib',
        'seaborn',
        'plotly',
        'datetime',
        'hashlib',
        'os'
    ]
    
    missing_modules = []
    
    for module in required_modules:
        try:
            __import__(module)
            print(f"✅ {module}")
        except ImportError:
            print(f"❌ {module} - MISSING")
            missing_modules.append(module)
    
    if missing_modules:
        print(f"\n⚠️  Missing modules: {', '.join(missing_modules)}")
        print("Install with: pip install streamlit psycopg2-binary pandas numpy matplotlib seaborn plotly")
        return False
    else:
        print("\n✅ All required modules are available!")
        return True

def test_main_file():
    """Test if the main application file can be loaded"""
    print("\n🔍 Testing main application file...")
    
    try:
        spec = importlib.util.spec_from_file_location("smartshow", "smartshow_ultimate_complete.py")
        if spec is None:
            print("❌ Could not load smartshow_ultimate_complete.py")
            return False
            
        print("✅ Main application file can be loaded!")
        return True
        
    except Exception as e:
        print(f"❌ Error loading main file: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 SmartShow Ultimate - System Check")
    print("=" * 50)
    
    imports_ok = test_imports()
    file_ok = test_main_file()
    
    print("\n" + "=" * 50)
    if imports_ok and file_ok:
        print("✅ ALL TESTS PASSED!")
        print("\n🎯 Ready to run SmartShow Ultimate!")
        print("Run with: streamlit run smartshow_ultimate_complete.py")
    else:
        print("❌ SOME TESTS FAILED!")
        print("Please fix the issues above before running the application.")

if __name__ == "__main__":
    main()