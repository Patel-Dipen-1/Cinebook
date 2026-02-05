#!/usr/bin/env python3
"""
Test script to verify seat availability functionality for comedy shows and concerts
"""

import psycopg2
from psycopg2.extras import RealDictCursor
import sys

def test_venue_capacity():
    """Test venue capacity updates"""
    try:
        # Connect to database
        conn = psycopg2.connect(
            host='localhost',
            user='postgres',
            password='your_password_here',  # Replace with your password
            database='cinebook',
            port=5432
        )
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        
        print("🎭 Testing Comedy Venue Capacity...")
        
        # Get comedy venues
        cursor.execute("""
            SELECT venue_id, name, capacity, available_capacity
            FROM venues 
            WHERE venue_type LIKE '%Comedy%'
            ORDER BY venue_id
            LIMIT 3
        """)
        comedy_venues = cursor.fetchall()
        
        print(f"Found {len(comedy_venues)} comedy venues:")
        for venue in comedy_venues:
            print(f"  - {venue['name']}: {venue['available_capacity']}/{venue['capacity']} available")
        
        print("\n🎵 Testing Concert Venue Capacity...")
        
        # Get concert venues
        cursor.execute("""
            SELECT venue_id, name, capacity, available_capacity
            FROM venues 
            WHERE venue_type LIKE '%Concert%' OR venue_type LIKE '%Music%'
            ORDER BY venue_id
            LIMIT 3
        """)
        concert_venues = cursor.fetchall()
        
        print(f"Found {len(concert_venues)} concert venues:")
        for venue in concert_venues:
            print(f"  - {venue['name']}: {venue['available_capacity']}/{venue['capacity']} available")
        
        # Test booking simulation
        if comedy_venues:
            test_venue = comedy_venues[0]
            print(f"\n📝 Simulating booking at {test_venue['name']}...")
            
            # Simulate booking 5 tickets
            tickets_to_book = 5
            cursor.execute("""
                UPDATE venues 
                SET available_capacity = available_capacity - %s
                WHERE venue_id = %s AND available_capacity >= %s
            """, (tickets_to_book, test_venue['venue_id'], tickets_to_book))
            
            if cursor.rowcount > 0:
                conn.commit()
                print(f"✅ Successfully booked {tickets_to_book} tickets!")
                
                # Check updated capacity
                cursor.execute("""
                    SELECT available_capacity FROM venues WHERE venue_id = %s
                """, (test_venue['venue_id'],))
                new_capacity = cursor.fetchone()['available_capacity']
                print(f"📊 New available capacity: {new_capacity}")
                
                # Restore original capacity
                cursor.execute("""
                    UPDATE venues 
                    SET available_capacity = available_capacity + %s
                    WHERE venue_id = %s
                """, (tickets_to_book, test_venue['venue_id']))
                conn.commit()
                print(f"🔄 Restored original capacity")
            else:
                print(f"❌ Booking failed - insufficient capacity")
        
        cursor.close()
        conn.close()
        print("\n✅ All tests completed successfully!")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False
    
    return True

if __name__ == "__main__":
    print("🧪 SmartShow Seat Availability Test")
    print("=" * 50)
    
    # Note: Update the password in the test_venue_capacity function
    print("⚠️  Please update the database password in the script before running!")
    print("📝 Edit line 15 in this file to set your PostgreSQL password")
    print()
    
    # Uncomment the line below after setting your password
    # test_venue_capacity()