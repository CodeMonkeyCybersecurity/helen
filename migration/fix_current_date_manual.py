#!/usr/bin/env python3
"""
Manual fix for current-date shortcodes in Ghost pages
Run this after verifying the pages have content in Ghost Admin
"""

import json
import requests
import jwt
import time

# Ghost configuration
GHOST_URL = "http://localhost:2368"
ADMIN_KEY = "687e137adb65b00001a55bbe:0d346b24dfa16f8dfe3b8a80acbd7475eeb205bd2957595fe5698b13a81048a5"

def get_auth_headers():
    """Generate authentication headers for Ghost Admin API"""
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

def main():
    headers = get_auth_headers()
    
    # Pages to update with their Ghost IDs
    pages_to_fix = [
        {
            'id': '687e13f2db65b00001a55d4c',
            'name': 'Security Guides & Checklists',
            'field': 'Last updated',
            'original_line': '**Last updated:** {{< current-date >}}'
        },
        {
            'id': '687e13f0db65b00001a55d38', 
            'name': 'Frequently Asked Questions',
            'field': 'Last updated',
            'original_line': '*Last updated: {{< current-date >}}'
        },
        {
            'id': '687e13f0db65b00001a55d33',
            'name': 'Security Solution Comparisons', 
            'field': 'accurate as of',
            'original_line': 'accurate as of {{< current-date >}}'
        }
    ]
    
    print("📝 Current Date Shortcode Fix Instructions")
    print("=" * 50)
    print("\nThe following pages need manual updates in Ghost Admin:\n")
    
    for page in pages_to_fix:
        print(f"📄 {page['name']}")
        print(f"   Ghost Admin URL: {GHOST_URL}/ghost/#/editor/page/{page['id']}")
        print(f"   Find: {page['original_line']}")
        print(f"   Replace with: {page['original_line'].replace('{{< current-date >}}', '21 July 2025')}")
        print()
    
    print("\n✅ How to fix:")
    print("1. Open each page in Ghost Admin using the URLs above")
    print("2. Use Ctrl+F (or Cmd+F on Mac) to find the text")
    print("3. Replace {{< current-date >}} with: 21 July 2025")
    print("4. Save the page")
    print("\n💡 Tip: The shortcode might appear as '{{< current-date >}}' or just 'current-date'")
    print("   depending on how Ghost rendered it. Search for both if needed.")

if __name__ == "__main__":
    main()