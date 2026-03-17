#!/usr/bin/env python
"""Update existing user with required fields."""
import sqlite3
from config import settings

db_path = settings.DATABASE_URL.replace("sqlite:///", "").replace("/", "\\")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Update the existing user with required fields
cursor.execute(
    "UPDATE users SET name=?, monthly_income=?, risk_profile=? WHERE user_id=1",
    ("Test User", 2500.0, "moderate")
)

conn.commit()
print("✅ Updated user record with monthly_income and risk_profile")
conn.close()
