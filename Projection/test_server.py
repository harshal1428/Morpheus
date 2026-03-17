#!/usr/bin/env python
"""Test the projection engine server."""
import requests
import time
import sys

print("Testing Projection Engine Server...")
print("=" * 60)

# Wait for server to be ready
print("Waiting for server to start...")
for i in range(10):
    try:
        response = requests.get('http://127.0.0.1:8001/health', timeout=2)
        if response.status_code == 200:
            print("✅ Server is responding!")
            break
    except:
        if i < 9:
            time.sleep(1)

# Test endpoints
tests = [
    ("Health Check", "GET", "/health"),
    ("API Docs", "GET", "/docs"),
    ("Dashboard UI", "GET", "/ui"),
    ("Forecast for User 1", "GET", "/forecast/1"),
    ("Adaptive Budgets", "GET", "/forecast/1/adaptive-budgets"),
    ("Savings Opportunities", "GET", "/savings-opportunities/1"),
    ("Insights", "GET", "/insights/1", 15),  # Longer timeout for LLM
    ("Shock Capacity", "GET", "/shock-engine/1", 15),  # Longer timeout
    ("Shock Goal Impact", "GET", "/shock-engine/1/goal-impact", 15),
]

print("\nTesting Endpoints:")
print("-" * 60)

for item in tests:
    name = item[0]
    method = item[1]
    endpoint = item[2]
    timeout = item[3] if len(item) > 3 else 10
    
    try:
        url = f"http://127.0.0.1:8001{endpoint}"
        response = requests.get(url, timeout=timeout)
        
        if response.status_code == 200:
            print(f"✅ {name:30} [{response.status_code}]")
        else:
            print(f"⚠️  {name:30} [{response.status_code}] - {response.json().get('detail', 'Unknown error')[:50]}")
    except requests.exceptions.Timeout:
        print(f"⏱️  {name:30} [TIMEOUT after {timeout}s]")
    except requests.exceptions.ConnectionError:
        print(f"❌ {name:30} [NO CONNECTION]")
    except Exception as e:
        print(f"❌ {name:30} [ERROR: {str(e)[:40]}]")

print("\n" + "=" * 60)
print("Test Complete!")
