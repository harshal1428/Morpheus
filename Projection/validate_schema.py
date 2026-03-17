#!/usr/bin/env python
"""Validate database schema has all required columns."""
import sqlite3
from config import settings

db_path = settings.DATABASE_URL.replace("sqlite:///", "").replace("/", "\\")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Define required columns for each table
required_columns = {
    "users": ["user_id", "username", "name", "email", "monthly_income", "risk_profile"],
    "transactions": ["txn_id", "user_id", "amount", "txn_type", "category", "txn_timestamp", "balance_after_txn"],
    "accounts": ["account_id", "user_id", "account_name", "account_type", "current_balance"],
    "goals": ["goal_id", "user_id", "goal_name", "target_amount", "current_amount", "deadline", "priority", "status"],
}

print("Database Schema Validation\n" + "="*50)

for table, req_cols in required_columns.items():
    cursor.execute(f"PRAGMA table_info({table})")
    columns = {row[1] for row in cursor.fetchall()}
    
    missing = [c for c in req_cols if c not in columns]
    
    if missing:
        print(f"\n❌ {table}: Missing columns: {missing}")
    else:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"✅ {table}: All required columns present ({count} records)")

conn.close()
print("\n✅ Schema validation complete!")
