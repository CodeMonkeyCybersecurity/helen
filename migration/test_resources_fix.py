#!/usr/bin/env python3
"""
Test script to check and fix the resources page
"""

import requests
import json
import jwt
import time

GHOST_URL = "http://localhost:2368"
ADMIN_KEY = "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22"

def get_auth_headers():
    key_id, key_secret = ADMIN_KEY.split(':')
    iat = int(time.time())
    payload = {
        'iat': iat,
        'exp': iat + 300,
        'aud': '/admin/'
    }
    token = jwt.encode(payload, bytes.fromhex(key_secret), algorithm='HS256', headers={'kid': key_id})
    return {
        'Authorization': f'Ghost {token}',
        'Content-Type': 'application/json'
    }

# Get the resources page
headers = get_auth_headers()
response = requests.get(f"{GHOST_URL}/ghost/api/admin/pages/?filter=slug:resources", headers=headers)

if response.status_code == 200:
    pages = response.json()['pages']
    if pages:
        page = pages[0]
        print(f"Page found: {page['title']} (ID: {page['id']})")
        print(f"Slug: {page['slug']}")
        print(f"Status: {page['status']}")
        print(f"HTML content: {page.get('html', 'NO HTML')[:100]}...")
        print(f"Mobiledoc: {page.get('mobiledoc', 'NO MOBILEDOC')[:100]}...")
        
        # Try to update it with simple content
        print("\nUpdating with test content...")
        
        test_mobiledoc = {
            "version": "0.3.1",
            "atoms": [],
            "cards": [["html", {"html": "<h1>Resources</h1><p>Welcome to our resources section. Here you'll find guides, documentation, and educational materials.</p>"}]],
            "markups": [],
            "sections": [[10, 0]]
        }
        
        update_data = {
            "pages": [{
                "mobiledoc": json.dumps(test_mobiledoc),
                "updated_at": page['updated_at']
            }]
        }
        
        update_response = requests.put(
            f"{GHOST_URL}/ghost/api/admin/pages/{page['id']}/",
            headers=headers,
            json=update_data
        )
        
        if update_response.status_code == 200:
            print("✅ Page updated successfully!")
            print("Check: http://localhost:2368/resources/")
        else:
            print(f"❌ Update failed: {update_response.status_code}")
            print(update_response.text)