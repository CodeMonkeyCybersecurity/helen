#!/usr/bin/env python3
"""
Ghost Link Fixer
Reorganizes Ghost content structure and fixes internal links
"""

import requests
import json
import jwt
import time
import re
from typing import Dict, List, Any

class GhostLinkFixer:
    def __init__(self, ghost_url: str, admin_key: str, dry_run: bool = True):
        self.ghost_url = ghost_url.rstrip('/')
        self.admin_key = admin_key
        self.dry_run = dry_run
        self.api_url = f"{self.ghost_url}/ghost/api/admin"
        
        # URL mapping for reorganization
        self.url_mappings = {
            # Blog posts - prefix with /blog/
            'posts': 'blog',
            
            # Page reorganization
            'pages': {
                # Main website pages (keep at root)
                'home': '/',
                'about-us': '/about/',
                'code-monkey-cybersecurity': '/about/',  # Redirect to about
                'about': '/about/',  # Merge duplicates
                'contact': '/contact/',
                'services': '/services/',  # Pricing page
                'accessibility': '/accessibility/',
                
                # Delphi product pages
                'delphi': '/delphi/',
                'delphi-notify': '/delphi/notify/',
                'delphi-2': '/delphi/',  # Redirect duplicate
                'roadmap': '/delphi/roadmap/',
                'customer-login': '/delphi/login/',
                'sign-up': '/delphi/signup/',
                'technology': '/delphi/technology/',
                'technical-documentation': '/delphi/docs/',
                
                # Resources section
                'resources': '/resources/',
                'security-guides': '/resources/guides/',
                'education': '/resources/education/',
                'training': '/resources/training/',
                'phishing': '/resources/training/phishing/',
                'phishing-simulation': '/resources/training/simulation/',
                'bce-playbook': '/resources/guides/bce-prevention/',
                'case-studies': '/resources/case-studies/',
                'faq': '/resources/faq/',
                'comparisons': '/resources/comparisons/',
                
                # Legal/Governance
                'governance': '/legal/governance/',
                'policies': '/legal/',
                'privacy-policy': '/legal/privacy/',
                'terms-of-service': '/legal/terms/',
                'code-of-conduct': '/legal/conduct/',
                'responsible-disclosure': '/legal/disclosure/',
                'data-handling-policy': '/legal/data-handling/',
                'device-policy': '/legal/device-policy/',
                'security': '/legal/security/',
                'open-source-licensing': '/legal/licensing/',
                
                # Technical docs (internal)
                'api': '/docs/api/',
                'server-ossec-conf': '/docs/ossec/',
                'centralised-agent-config': '/docs/agent-config/',
                'blocking-malicious-actor': '/docs/blocking/',
                'persephone': '/docs/persephone/',
                
                # Meta pages
                'search': '/search/',
                'offline': '/offline/',
                
                # Training specific
                'gophish_1': '/resources/training/phishing/awareness/',
                'gophish_2': '/resources/training/phishing/success/',
                'phishing-training': '/resources/training/phishing/',
                
                # Remove or redirect duplicates
                'babys-firsts': None,  # Remove index page
            }
        }
        
        # Pages to delete (duplicates/unused)
        self.pages_to_delete = [
            'babys-firsts',  # Index page
            'delphi-2',      # Duplicate
        ]
    
    def get_auth_headers(self) -> Dict[str, str]:
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
    
    def get_all_content(self):
        """Fetch all posts and pages from Ghost"""
        headers = self.get_auth_headers()
        
        # Get posts
        posts_response = requests.get(f"{self.api_url}/posts/?limit=50", headers=headers)
        posts = posts_response.json()['posts'] if posts_response.status_code == 200 else []
        
        # Get pages
        pages_response = requests.get(f"{self.api_url}/pages/?limit=50", headers=headers)
        pages = pages_response.json()['pages'] if pages_response.status_code == 200 else []
        
        return posts, pages
    
    def update_page_slug(self, page_id: str, new_slug: str, page_data: dict) -> bool:
        """Update a page's slug"""
        if self.dry_run:
            print(f"[DRY RUN] Would update page {page_id} slug to: {new_slug}")
            return True
        
        headers = self.get_auth_headers()
        data = {
            'pages': [{
                'id': page_id,
                'slug': new_slug.strip('/'),
                'updated_at': page_data['updated_at']  # Required for updates
            }]
        }
        
        response = requests.put(f"{self.api_url}/pages/{page_id}/", headers=headers, json=data)
        if response.status_code != 200:
            print(f"❌ Failed to update {page_id}: {response.status_code} - {response.text}")
            return False
        return True
    
    def delete_page(self, page_id: str) -> bool:
        """Delete a page"""
        if self.dry_run:
            print(f"[DRY RUN] Would delete page {page_id}")
            return True
        
        headers = self.get_auth_headers()
        response = requests.delete(f"{self.api_url}/pages/{page_id}/", headers=headers)
        return response.status_code == 204
    
    def update_content_links(self, content: str, content_type: str = 'page') -> str:
        """Update internal links in content"""
        # Common link patterns to fix
        link_replacements = {
            r'/docs/([^/\s\)]+)/?': r'/resources/guides/\1/',
            r'/blog/([^/\s\)]+)/?': r'/blog/\1/',
            r'/delphi-notify/?': r'/delphi/notify/',
            r'/sign-up/?': r'/delphi/signup/',
            r'/about-us/?': r'/about/',
            r'/code-monkey-cybersecurity/?': r'/about/',
            r'/training/?': r'/resources/training/',
            r'/phishing/?': r'/resources/training/phishing/',
            r'/governance/?': r'/legal/governance/',
            r'/policies/?': r'/legal/',
        }
        
        updated_content = content
        for pattern, replacement in link_replacements.items():
            updated_content = re.sub(pattern, replacement, updated_content)
        
        return updated_content
    
    def reorganize_content(self):
        """Main method to reorganize all content"""
        print("🔄 Fetching current content...")
        posts, pages = self.get_all_content()
        
        print(f"📊 Found {len(posts)} posts and {len(pages)} pages")
        
        # Update page slugs and organization
        print("\n🔧 Reorganizing pages...")
        
        updates_made = 0
        deletions_made = 0
        
        for page in pages:
            current_slug = page['slug']
            page_id = page['id']
            title = page['title']
            
            # Check if page should be deleted
            if current_slug in self.pages_to_delete:
                print(f"🗑️  Deleting duplicate page: {title} ({current_slug})")
                if self.delete_page(page_id):
                    deletions_made += 1
                continue
            
            # Check if page needs new slug
            if current_slug in self.url_mappings['pages']:
                new_url = self.url_mappings['pages'][current_slug]
                if new_url:  # Not marked for deletion
                    new_slug = new_url.strip('/').replace('/', '-') if new_url != '/' else 'home'
                    
                    if new_slug != current_slug:
                        print(f"📝 Updating page: {title}")
                        print(f"   {current_slug} → {new_slug}")
                        
                        if self.update_page_slug(page_id, new_slug, page):
                            updates_made += 1
        
        print(f"\n✅ Content reorganization complete!")
        print(f"   Updated: {updates_made} pages")
        print(f"   Deleted: {deletions_made} pages")
        
        return updates_made, deletions_made
    
    def create_navigation_structure(self):
        """Create recommended navigation structure"""
        nav_structure = {
            "primary": [
                {"label": "Home", "url": "/"},
                {"label": "About", "url": "/about/"},
                {"label": "Delphi", "url": "/delphi/", "children": [
                    {"label": "Overview", "url": "/delphi/"},
                    {"label": "Features", "url": "/delphi/notify/"},
                    {"label": "Technology", "url": "/delphi/technology/"},
                    {"label": "Pricing", "url": "/services/"},
                    {"label": "Sign Up", "url": "/delphi/signup/"}
                ]},
                {"label": "Resources", "url": "/resources/", "children": [
                    {"label": "Security Guides", "url": "/resources/guides/"},
                    {"label": "Training", "url": "/resources/training/"},
                    {"label": "Case Studies", "url": "/resources/case-studies/"},
                    {"label": "FAQ", "url": "/resources/faq/"},
                    {"label": "Comparisons", "url": "/resources/comparisons/"}
                ]},
                {"label": "Blog", "url": "/blog/"},
                {"label": "Contact", "url": "/contact/"}
            ],
            "footer": [
                {"label": "Legal", "children": [
                    {"label": "Privacy Policy", "url": "/legal/privacy/"},
                    {"label": "Terms of Service", "url": "/legal/terms/"},
                    {"label": "Security Policy", "url": "/legal/security/"}
                ]},
                {"label": "Support", "children": [
                    {"label": "Documentation", "url": "/delphi/docs/"},
                    {"label": "Customer Login", "url": "/delphi/login/"},
                    {"label": "Contact Us", "url": "/contact/"}
                ]}
            ]
        }
        
        print("\n🗂️  Recommended Navigation Structure:")
        print(json.dumps(nav_structure, indent=2))
        
        return nav_structure

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Reorganize Ghost content structure')
    parser.add_argument('--ghost-url', default='http://localhost:2368', help='Ghost URL')
    parser.add_argument('--admin-key', default='687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22', help='Ghost Admin API key')
    parser.add_argument('--dry-run', action='store_true', default=True, help='Simulate changes without applying them')
    parser.add_argument('--apply', action='store_true', help='Actually apply the changes')
    
    args = parser.parse_args()
    
    if args.apply:
        args.dry_run = False
    
    print("🔧 Ghost Link Fixer")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'LIVE CHANGES'}")
    print(f"Target: {args.ghost_url}")
    print()
    
    fixer = GhostLinkFixer(args.ghost_url, args.admin_key, args.dry_run)
    
    # Reorganize content
    fixer.reorganize_content()
    
    # Show navigation recommendations
    fixer.create_navigation_structure()
    
    if args.dry_run:
        print("\n💡 To apply these changes, run with --apply flag")

if __name__ == '__main__':
    main()