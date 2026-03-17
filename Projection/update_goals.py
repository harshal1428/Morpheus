#!/usr/bin/env python
"""Add missing columns to goals table."""
import sqlite3
from config import settings

db_path = settings.DATABASE_URL.replace("sqlite:///", "").replace("/", "\\")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

try:
    # Check what columns exist
    cursor.execute("PRAGMA table_info(goals)")
    columns = {row[1] for row in cursor.fetchall()}
    
    if "priority" not in columns:
        cursor.execute("ALTER TABLE goals ADD COLUMN priority INTEGER DEFAULT 1")
        print("✅ Added 'priority' column to goals")
    
    if "status" not in columns:
        cursor.execute("ALTER TABLE goals ADD COLUMN status TEXT DEFAULT 'active'")
        print("✅ Added 'status' column to goals")
    
    # Update existing goals with default values
    cursor.execute("UPDATE goals SET priority = 1 WHERE priority IS NULL")
    cursor.execute("UPDATE goals SET status = 'active' WHERE status IS NULL")
    
    conn.commit()
    print("✅ Goals table updated")
    
except Exception as e:
    print(f"❌ Error: {e}")
    conn.rollback()

conn.close()
