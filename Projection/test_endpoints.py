#!/usr/bin/env python
"""Test all main endpoints."""
import requests

endpoints = [
    ("Forecast", "http://127.0.0.1:8001/forecast/1"),
    ("Adaptive Budgets", "http://127.0.0.1:8001/forecast/1/adaptive-budgets"),
    ("Savings Opportunities", "http://127.0.0.1:8001/savings-opportunities/1"),
    ("Insights", "http://127.0.0.1:8001/insights/1"),
    ("Shock Capacity", "http://127.0.0.1:8001/shock-engine/1"),
]

print("Testing endpoints:\n")
for name, url in endpoints:
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            print(f"✅ {name}: OK")
        else:
            print(f"❌ {name}: {response.status_code}")
            if response.text:
                error = response.json() if response.headers.get('content-type') == 'application/json' else response.text
                print(f"   Error: {str(error)[:100]}")
    except Exception as e:
        print(f"❌ {name}: {str(e)[:100]}")

print("\n✅ All endpoints tested!")

