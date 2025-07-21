#!/usr/bin/env python3
"""
Fix pages with null content in Ghost by updating them with correct content
"""

import requests
import json
import jwt
import time

# Ghost configuration
GHOST_URL = "http://localhost:2368"
ADMIN_KEY = "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22"

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

def get_pages_with_null_content():
    """Get all pages that have null HTML content"""
    headers = get_auth_headers()
    url = f"{GHOST_URL}/ghost/api/admin/pages/?limit=100"
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        pages = response.json()['pages']
        null_pages = [p for p in pages if not p.get('html') or p['html'] == 'undefined']
        return null_pages
    return []

def load_converted_content():
    """Load the converted content from JSON file"""
    with open('converted/ghost_pages.json', 'r') as f:
        return json.load(f)

def find_content_for_page(pages_data, title, slug):
    """Find matching content from converted data"""
    # Try to match by title first
    for page in pages_data:
        if page.get('title') == title:
            return page.get('content', '')
    
    # Try to match by slug
    for page in pages_data:
        page_slug = page.get('slug') or page.get('url_path', '').strip('/').replace('/', '-')
        if page_slug == slug:
            return page.get('content', '')
    
    return None

def update_page_content(page_id, content, updated_at):
    """Update a Ghost page with new content"""
    headers = get_auth_headers()
    url = f"{GHOST_URL}/ghost/api/admin/pages/{page_id}/"
    
    # Create mobiledoc format for the content
    mobiledoc = {
        "version": "0.3.1",
        "atoms": [],
        "cards": [["markdown", {"markdown": content}]],
        "markups": [],
        "sections": [[10, 0]]
    }
    
    data = {
        "pages": [{
            "mobiledoc": json.dumps(mobiledoc),
            "updated_at": updated_at
        }]
    }
    
    response = requests.put(url, headers=headers, json=data)
    return response.status_code == 200

def main():
    print("🔍 Finding pages with null content...")
    null_pages = get_pages_with_null_content()
    print(f"Found {len(null_pages)} pages with missing content")
    
    print("\n📄 Loading converted content...")
    converted_pages = load_converted_content()
    print(f"Loaded {len(converted_pages)} pages from conversion")
    
    print("\n🔧 Fixing pages...")
    fixed = 0
    failed = 0
    
    for page in null_pages:
        title = page['title']
        slug = page['slug']
        page_id = page['id']
        updated_at = page['updated_at']
        
        print(f"\n📝 Processing: {title} (/{slug}/)")
        
        # Find content
        content = find_content_for_page(converted_pages, title, slug)
        
        if content:
            print(f"   ✅ Found content ({len(content)} characters)")
            if update_page_content(page_id, content, updated_at):
                print(f"   ✅ Updated successfully")
                fixed += 1
            else:
                print(f"   ❌ Failed to update")
                failed += 1
        else:
            print(f"   ⚠️  No matching content found")
            failed += 1
    
    print(f"\n📊 Summary:")
    print(f"   Fixed: {fixed} pages")
    print(f"   Failed: {failed} pages")
    print(f"\n✅ Done! Refresh your Ghost site to see the changes.")

if __name__ == '__main__':
    main()