#!/usr/bin/env python3
"""
Ghost Navigation Setup
Configures Ghost navigation menus with the new content structure
"""

import requests
import json
import jwt
import time

class GhostNavigationSetup:
    def __init__(self, ghost_url: str, admin_key: str):
        self.ghost_url = ghost_url.rstrip('/')
        self.admin_key = admin_key
        self.api_url = f"{self.ghost_url}/ghost/api/admin"
    
    def get_auth_headers(self):
        """Generate authentication headers for Ghost Admin API"""
        key_id, key_secret = self.admin_key.split(':')
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
    
    def setup_primary_navigation(self):
        """Setup the primary navigation menu"""
        navigation = [
            {"label": "Home", "url": "/"},
            {"label": "About", "url": "/about/"},
            {"label": "Delphi", "url": "/delphi/"},
            {"label": "Resources", "url": "/resources/"},
            {"label": "Blog", "url": "/"},  # Ghost blog posts appear at root
            {"label": "Contact", "url": "/contact/"}
        ]
        
        return self.update_navigation(navigation)
    
    def setup_secondary_navigation(self):
        """Setup the secondary/footer navigation"""
        secondary_nav = [
            {"label": "Privacy", "url": "/legal-privacy/"},
            {"label": "Terms", "url": "/legal-terms/"},
            {"label": "Documentation", "url": "/delphi-docs/"},
            {"label": "Customer Login", "url": "/delphi-login/"}
        ]
        
        return self.update_secondary_navigation(secondary_nav)
    
    def update_navigation(self, navigation):
        """Update Ghost primary navigation"""
        headers = self.get_auth_headers()
        
        # Get current settings
        response = requests.get(f"{self.api_url}/settings/", headers=headers)
        if response.status_code != 200:
            print(f"❌ Failed to get settings: {response.status_code}")
            return False
        
        settings = response.json()['settings']
        
        # Update navigation
        nav_settings = {
            'settings': [
                {
                    'key': 'navigation',
                    'value': json.dumps(navigation)
                }
            ]
        }
        
        response = requests.put(f"{self.api_url}/settings/", headers=headers, json=nav_settings)
        
        if response.status_code == 200:
            print("✅ Primary navigation updated successfully")
            return True
        else:
            print(f"❌ Failed to update navigation: {response.status_code} - {response.text}")
            return False
    
    def update_secondary_navigation(self, navigation):
        """Update Ghost secondary navigation"""
        headers = self.get_auth_headers()
        
        nav_settings = {
            'settings': [
                {
                    'key': 'secondary_navigation',
                    'value': json.dumps(navigation)
                }
            ]
        }
        
        response = requests.put(f"{self.api_url}/settings/", headers=headers, json=nav_settings)
        
        if response.status_code == 200:
            print("✅ Secondary navigation updated successfully")
            return True
        else:
            print(f"❌ Failed to update secondary navigation: {response.status_code} - {response.text}")
            return False

def main():
    ghost_url = "http://localhost:2368"
    admin_key = "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22"
    
    print("🗂️  Setting up Ghost navigation...")
    
    nav_setup = GhostNavigationSetup(ghost_url, admin_key)
    
    # Setup primary navigation
    nav_setup.setup_primary_navigation()
    
    # Setup secondary navigation
    nav_setup.setup_secondary_navigation()
    
    print("\n✅ Navigation setup complete!")
    print(f"Visit {ghost_url}/ghost/ to review and adjust navigation")

if __name__ == '__main__':
    main()