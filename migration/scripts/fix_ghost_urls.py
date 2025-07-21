#!/usr/bin/env python3
"""
Fix Ghost URLs and duplicates
"""

import requests
import json
import jwt
import time

class GhostURLFixer:
    def __init__(self, ghost_url: str, admin_key: str):
        self.ghost_url = ghost_url.rstrip('/')
        self.admin_key = admin_key
        self.api_url = f"{self.ghost_url}/ghost/api/admin"
    
    def get_auth_headers(self):
        key_id, key_secret = self.admin_key.split(':')
        iat = int(time.time())
        payload = {'iat': iat, 'exp': iat + 300, 'aud': '/admin/'}
        token = jwt.encode(payload, bytes.fromhex(key_secret), algorithm='HS256', headers={'kid': key_id})
        return {
            'Authorization': f'Ghost {token}',
            'Content-Type': 'application/json'
        }
    
    def fix_test_slug(self):
        """Fix the test-new-slug back to proper slug"""
        headers = self.get_auth_headers()
        response = requests.get(f"{self.api_url}/pages/?limit=50", headers=headers)
        
        if response.status_code == 200:
            pages = response.json()['pages']
            for page in pages:
                if page['slug'] == 'test-new-slug':
                    # This should be the BCE playbook
                    print(f"🔧 Fixing test slug for: {page['title']}")
                    
                    data = {
                        'pages': [{
                            'id': page['id'],
                            'slug': 'resources-guides-bce-prevention',
                            'updated_at': page['updated_at']
                        }]
                    }
                    
                    update_response = requests.put(f"{self.api_url}/pages/{page['id']}/", headers=headers, json=data)
                    if update_response.status_code == 200:
                        print("✅ Fixed test slug")
                    else:
                        print(f"❌ Failed to fix test slug: {update_response.status_code}")
    
    def fix_duplicate_about_pages(self):
        """Consolidate duplicate About pages"""
        headers = self.get_auth_headers()
        response = requests.get(f"{self.api_url}/pages/?limit=50", headers=headers)
        
        if response.status_code == 200:
            pages = response.json()['pages']
            about_pages = []
            
            for page in pages:
                if 'about' in page['slug'] and page['slug'] != 'about':
                    about_pages.append(page)
            
            print(f"🔍 Found {len(about_pages)} duplicate About pages to clean up")
            
            for page in about_pages:
                if page['slug'] in ['about-2', 'about-3']:
                    print(f"🗑️ Deleting duplicate: {page['title']} ({page['slug']})")
                    
                    delete_response = requests.delete(f"{self.api_url}/pages/{page['id']}/", headers=headers)
                    if delete_response.status_code == 204:
                        print("✅ Deleted successfully")
                    else:
                        print(f"❌ Failed to delete: {delete_response.status_code}")
    
    def show_correct_urls(self):
        """Display the correct URLs for navigation setup"""
        print("\n📋 CORRECT URLS FOR NAVIGATION:")
        print("\nPrimary Navigation:")
        print("  Home → /")
        print("  About → /about/")
        print("  Delphi → /delphi/")
        print("  Resources → /resources-guides/")  # Main resources page
        print("  Blog → /")  # Ghost posts appear at root
        print("  Contact → /contact/")
        
        print("\nKey Page URLs:")
        print("  Services/Pricing → /services/")
        print("  Security Education → /resources-education/")
        print("  Training → /resources-training/")
        print("  FAQ → /resources-faq/")
        print("  Customer Login → /delphi-login/")
        print("  Sign Up → /delphi-signup/")
        
        print("\n🔍 Blog posts work at:")
        print("  Individual posts → /[post-slug]/")
        print("  Blog archive → / (homepage)")

def main():
    ghost_url = "http://localhost:2368"
    admin_key = "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22"
    
    fixer = GhostURLFixer(ghost_url, admin_key)
    
    print("🔧 Fixing Ghost URL issues...")
    
    # Fix the test slug
    fixer.fix_test_slug()
    
    # Clean up duplicate about pages
    fixer.fix_duplicate_about_pages()
    
    # Show correct URLs
    fixer.show_correct_urls()
    
    print("\n✅ URL fixes complete!")
    print("Now update your Ghost navigation with the correct URLs shown above.")

if __name__ == '__main__':
    main()