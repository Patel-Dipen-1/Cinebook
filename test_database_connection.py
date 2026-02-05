#!/usr/bin/env python3
"""
Quick Database Connection Test for SmartShow Ultimate
Run this to verify your PostgreSQL setup before running the main app
"""

import psycopg2
from psycopg2.extras import RealDictCursor
import sys

def test_connection():
    """Test PostgreSQL connection and database setup"""
    print("🔧 SmartShow Ultimate - Database Connection Test")
    print("=" * 50)
    
    # Get password from user
    password = input("Enter PostgreSQL password for 'postgres' user: ")
    
    try:
        print("\n1. Testing PostgreSQL server connection...")
        # Test server connection
        server_conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password=password,
            port=5432
        )
        server_conn.autocommit = True
        server_cursor = server_conn.cursor()
        print("✅ PostgreSQL server connection successful!")
        
        # Check if cinebook database exists
        print("\n2. Checking for 'cinebook' database...")
        server_cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = 'cinebook'")
        db_exists = server_cursor.fetchone()
        
        if db_exists:
            print("✅ Database 'cinebook' exists!")
        else:
            print("⚠️  Database 'cinebook' does not exist - will be created by main app")
        
        server_cursor.close()
        server_conn.close()
        
        # If database exists, test connection to it
        if db_exists:
            print("\n3. Testing connection to 'cinebook' database...")
            db_conn = psycopg2.connect(
                host='localhost',
                user='postgres',
                password=password,
                database='cinebook',
                port=5432
            )
            cursor = db_conn.cursor(cursor_factory=RealDictCursor)
            
            # Check tables
            cursor.execute("""
                SELECT table_name FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """)
            tables = cursor.fetchall()
            
            if tables:
                print(f"✅ Found {len(tables)} tables in database:")
                for table in tables:
                    print(f"   - {table['table_name']}")
                
                # Check sample data
                try:
                    cursor.execute("SELECT COUNT(*) as count FROM movies")
                    movie_count = cursor.fetchone()['count']
                    
                    cursor.execute("SELECT COUNT(*) as count FROM comedy_shows")
                    comedy_count = cursor.fetchone()['count']
                    
                    cursor.execute("SELECT COUNT(*) as count FROM concerts")
                    concert_count = cursor.fetchone()['count']
                    
                    cursor.execute("SELECT COUNT(*) as count FROM theatres")
                    theatre_count = cursor.fetchone()['count']
                    
                    cursor.execute("SELECT COUNT(*) as count FROM venues")
                    venue_count = cursor.fetchone()['count']
                    
                    print(f"\n📊 Data Summary:")
                    print(f"   - Movies: {movie_count}")
                    print(f"   - Comedy Shows: {comedy_count}")
                    print(f"   - Concerts: {concert_count}")
                    print(f"   - Theatres: {theatre_count}")
                    print(f"   - Venues: {venue_count}")
                    
                    if movie_count == 40 and comedy_count == 15 and concert_count == 15:
                        print("✅ Enhanced data (15 comedy + 15 concerts) is properly loaded!")
                    else:
                        print("⚠️  Data might be incomplete - consider using 'Reset & Create Fresh DB'")
                        
                except Exception as e:
                    print(f"⚠️  Could not check data: {e}")
            else:
                print("⚠️  No tables found - database needs to be initialized")
            
            cursor.close()
            db_conn.close()
        
        print("\n🎉 Database test completed successfully!")
        print("\n🚀 You can now run the main application:")
        print("   streamlit run smartshow_ultimate_ENHANCED_15_SHOWS.py")
        
    except psycopg2.OperationalError as e:
        print(f"❌ Connection failed: {e}")
        print("\n🔧 Troubleshooting tips:")
        print("1. Make sure PostgreSQL is running")
        print("2. Check if password is correct")
        print("3. Verify PostgreSQL is installed and configured")
        print("4. Try connecting with pgAdmin or psql first")
        return False
        
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False
    
    return True

def check_python_packages():
    """Check if required Python packages are installed"""
    print("\n📦 Checking Python packages...")
    
    required_packages = [
        'streamlit',
        'psycopg2',
        'pandas', 
        'plotly',
        'numpy'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            if package == 'psycopg2':
                import psycopg2
            elif package == 'streamlit':
                import streamlit
            elif package == 'pandas':
                import pandas
            elif package == 'plotly':
                import plotly
            elif package == 'numpy':
                import numpy
            print(f"✅ {package}")
        except ImportError:
            print(f"❌ {package} - NOT INSTALLED")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\n⚠️  Missing packages: {', '.join(missing_packages)}")
        print("Install them with: pip install -r requirements.txt")
        return False
    else:
        print("✅ All required packages are installed!")
        return True

if __name__ == "__main__":
    print("🎬 SmartShow Ultimate - System Check")
    print("=" * 50)
    
    # Check Python packages first
    packages_ok = check_python_packages()
    
    if packages_ok:
        # Test database connection
        db_ok = test_connection()
        
        if db_ok:
            print("\n🎉 ALL CHECKS PASSED!")
            print("Your system is ready to run SmartShow Ultimate!")
        else:
            print("\n❌ Database connection failed!")
            sys.exit(1)
    else:
        print("\n❌ Missing Python packages!")
        sys.exit(1)