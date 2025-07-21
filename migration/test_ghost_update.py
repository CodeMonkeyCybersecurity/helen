#!/usr/bin/env python3
import requests
import json
import jwt
import time

# Test updating one page manually
key_id, key_secret = '687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22'.split(':')
iat = int(time.time())
payload = {'iat': iat, 'exp': iat + 300, 'aud': '/admin/'}
token = jwt.encode(payload, bytes.fromhex(key_secret), algorithm='HS256', headers={'kid': key_id})

headers = {
    'Authorization': f'Ghost {token}',
    'Content-Type': 'application/json'
}

# Get first page to test update
response = requests.get('http://localhost:2368/ghost/api/admin/pages/?limit=1', headers=headers)
if response.status_code == 200:
    page = response.json()['pages'][0]
    page_id = page['id']
    current_slug = page['slug']
    print(f'Testing with page: {page["title"]} (ID: {page_id}, slug: {current_slug})')
    
    # Try to update slug - need to include updated_at field
    data = {
        'pages': [{
            'id': page_id,
            'slug': 'test-new-slug',
            'updated_at': page['updated_at']  # Required for updates
        }]
    }
    
    update_response = requests.put(f'http://localhost:2368/ghost/api/admin/pages/{page_id}/', headers=headers, json=data)
    print(f'Update response: {update_response.status_code}')
    if update_response.status_code != 200:
        print(f'Error: {update_response.text}')
    else:
        print('✅ Update successful')
        
        # Revert back
        revert_data = {
            'pages': [{
                'id': page_id,
                'slug': current_slug,
                'updated_at': page['updated_at']
            }]
        }
        revert_response = requests.put(f'http://localhost:2368/ghost/api/admin/pages/{page_id}/', headers=headers, json=revert_data)
        print(f'Revert: {revert_response.status_code}')
else:
    print(f'Failed to get pages: {response.status_code}')