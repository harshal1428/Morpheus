#!/usr/bin/env python
"""
Safe database initialization script.
Creates core tables (users, transactions, accounts, goals) if they don't exist.
Adds sample data for testing if tables are empty.
"""

import sqlite3
from datetime import datetime, timedelta
from config import settings
from pathlib import Path

def init_core_tables():
    """Initialize core tables needed by the projection engine."""
    db_path = settings.DATABASE_URL.replace("sqlite:///", "").replace("/", "\\")
    
    print(f"Initializing core tables in: {db_path}")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # ── Create users table ──
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                user_id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                name TEXT,
                email TEXT UNIQUE,
                monthly_income REAL DEFAULT 2500.0,
                risk_profile TEXT DEFAULT 'moderate',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Add missing columns if they don't exist
        cursor.execute("PRAGMA table_info(users)")
        columns = {row[1] for row in cursor.fetchall()}
        
        if "name" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN name TEXT")
            print("  + Added 'name' column to users")
        if "monthly_income" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN monthly_income REAL DEFAULT 2500.0")
            print("  + Added 'monthly_income' column to users")
        if "risk_profile" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN risk_profile TEXT DEFAULT 'moderate'")
            print("  + Added 'risk_profile' column to users")
        
        print("✅ users table ready")
        
        # ── Create accounts table ──
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS accounts (
                account_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                account_name TEXT NOT NULL,
                account_type TEXT,
                current_balance REAL DEFAULT 0.0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        """)
        print("✅ accounts table ready")
        
        # ── Create transactions table ──
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS transactions (
                txn_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                account_id INTEGER,
                amount REAL NOT NULL,
                txn_type TEXT NOT NULL,
                category TEXT,
                description TEXT,
                txn_timestamp TIMESTAMP NOT NULL,
                is_recurring INTEGER DEFAULT 0,
                balance_after_txn REAL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id),
                FOREIGN KEY (account_id) REFERENCES accounts(account_id)
            )
        """)
        print("✅ transactions table ready")
        
        # ── Create goals table ──
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS goals (
                goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                goal_name TEXT NOT NULL,
                target_amount REAL NOT NULL,
                current_amount REAL DEFAULT 0.0,
                deadline DATE,
                category TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id)
            )
        """)
        print("✅ goals table ready")
        
        conn.commit()
        
        # ── Check if we need sample data ──
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        
        if user_count == 0:
            print("\n📝 Adding sample test data...")
            init_sample_data(cursor)
            conn.commit()
            print("✅ Sample data added")
        else:
            print(f"\n✓ Database already has {user_count} user(s)")
        
        conn.close()
        print("\n✅ Database initialization complete!")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()
        conn.close()
        raise


def init_sample_data(cursor):
    """Add sample data for testing."""
    
    # Create test user with all required fields
    cursor.execute(
        "INSERT INTO users (username, name, email, monthly_income, risk_profile) VALUES (?, ?, ?, ?, ?)",
        ("testuser", "Test User", "test@example.com", 2500.0, "moderate")
    )
    user_id = cursor.lastrowid
    
    # Create test account
    cursor.execute(
        "INSERT INTO accounts (user_id, account_name, account_type, current_balance) VALUES (?, ?, ?, ?)",
        (user_id, "Checking Account", "checking", 5000.0)
    )
    account_id = cursor.lastrowid
    
    # Add transactions for the past 6 months
    now = datetime.now()
    base_balance = 5000.0
    
    # Sample categories and amounts
    debits = [
        ("Groceries", 150),
        ("Gas", 50),
        ("Utilities", 100),
        ("Entertainment", 75),
        ("Dining", 45),
        ("Shopping", 120),
        ("Insurance", 200),
    ]
    
    credits = [
        ("Salary", 2500),
        ("Bonus", 500),
    ]
    
    # Add 6 months of transactions
    for days_back in range(180, 0, -5):
        txn_date = now - timedelta(days=days_back)
        
        # Approximately 2 debits per week
        for category, amount in debits[::3]:
            base_balance -= amount
            cursor.execute(
                """INSERT INTO transactions 
                   (user_id, account_id, amount, txn_type, category, txn_timestamp, balance_after_txn)
                   VALUES (?, ?, ?, ?, ?, ?, ?)""",
                (user_id, account_id, amount, "debit", category, txn_date, base_balance)
            )
        
        # Monthly salary
        if days_back % 30 == 0:
            base_balance += 2500
            cursor.execute(
                """INSERT INTO transactions 
                   (user_id, account_id, amount, txn_type, category, txn_timestamp, balance_after_txn, is_recurring)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                (user_id, account_id, 2500, "credit", "Salary", txn_date, base_balance, 1)
            )
    
    # Create test goals
    cursor.execute(
        "INSERT INTO goals (user_id, goal_name, target_amount, current_amount, deadline, category) VALUES (?, ?, ?, ?, ?, ?)",
        (user_id, "Emergency Fund", 10000, 5000, "2026-12-31", "savings")
    )
    cursor.execute(
        "INSERT INTO goals (user_id, goal_name, target_amount, current_amount, deadline, category) VALUES (?, ?, ?, ?, ?, ?)",
        (user_id, "Vacation Fund", 3000, 500, "2026-06-30", "travel")
    )
    
    print(f"  - Created user: {user_id}")
    print(f"  - Created account: {account_id}")
    print(f"  - Added ~6 months of transaction history")


if __name__ == "__main__":
    init_core_tables()
