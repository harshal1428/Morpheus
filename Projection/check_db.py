#!/usr/bin/env python
"""Quick script to check database tables."""
import sqlite3
from config import settings

# Extract the file path from the database URL
db_path = settings.DATABASE_URL.replace("sqlite:///", "").replace("/", "\\")

print(f"Checking database: {db_path}")
try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]
    print(f"\nFound {len(tables)} tables:")
    for table in sorted(tables):
        print(f"  - {table}")
    
    # Check for transactions specifically
    if "transactions" in tables:
        cursor.execute("SELECT COUNT(*) FROM transactions")
        count = cursor.fetchone()[0]
        print(f"\n✅ transactions table found with {count} records")
    else:
        print("\n❌ transactions table NOT found!")
        print("\nERROR: The app requires transactions table from the main Morpheus project")
        print("Check if the Morpheus project has been properly initialized.")
    
    conn.close()
except Exception as e:
    print(f"❌ Error: {e}")
