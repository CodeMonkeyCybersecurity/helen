#!/usr/bin/env python3
"""
Ghost Content Importer
Imports converted Hugo content into Ghost CMS via Admin API
"""

import json
import requests
import argparse
import time
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime
import jwt
import os

class GhostImporter:
    def __init__(self, ghost_url: str, admin_key: str, dry_run: bool = False):
        self.ghost_url = ghost_url.rstrip('/')
        self.admin_key = admin_key
        self.dry_run = dry_run
        
        self.api_url = f"{self.ghost_url}/ghost/api/admin"
        self.content_api_url = f"{self.ghost_url}/ghost/api/content"
        
        # Import statistics
        self.stats = {
            'posts_created': 0,
            'posts_failed': 0,
            'pages_created': 0,
            'pages_failed': 0,
            'images_uploaded': 0,
            'images_failed': 0
        }
    
    def get_auth_headers(self) -> Dict[str, str]:
        """Generate authentication headers for Ghost Admin API"""
        # Split the key to get ID and secret
        key_id, key_secret = self.admin_key.split(':')
        
        # Create JWT token
        iat = int(time.time())
        
        payload = {
            'iat': iat,
            'exp': iat + 300,  # 5 minutes
            'aud': '/admin/'
        }
        
        token = jwt.encode(payload, bytes.fromhex(key_secret), algorithm='HS256', headers={'kid': key_id})
        
        return {
            'Authorization': f'Ghost {token}',
            'Content-Type': 'application/json'
        }
    
    def upload_image(self, image_path: str, image_url: str) -> Optional[str]:
        """Upload an image to Ghost and return the new URL"""
        if self.dry_run:
            print(f"[DRY RUN] Would upload image: {image_path}")
            return image_url
        
        try:
            # Check if image exists
            if not os.path.exists(image_path):
                print(f"⚠️  Image not found: {image_path}")
                return None
            
            # Check file extension - Ghost supports: jpg, jpeg, gif, png, svg, webp
            allowed_extensions = {'.jpg', '.jpeg', '.gif', '.png', '.svg', '.webp'}
            file_ext = os.path.splitext(image_path)[1].lower()
            
            if file_ext not in allowed_extensions:
                print(f"⚠️  Unsupported image format: {image_path} ({file_ext})")
                return None
            
            # Check file size (Ghost has limits)
            file_size = os.path.getsize(image_path)
            max_size = 10 * 1024 * 1024  # 10MB
            
            if file_size > max_size:
                print(f"⚠️  Image too large: {image_path} ({file_size / 1024 / 1024:.1f}MB)")
                return None
            
            headers = self.get_auth_headers()
            del headers['Content-Type']  # Let requests set this for multipart
            
            # Determine content type
            content_types = {
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg', 
                '.png': 'image/png',
                '.gif': 'image/gif',
                '.svg': 'image/svg+xml',
                '.webp': 'image/webp'
            }
            
            with open(image_path, 'rb') as f:
                files = {
                    'file': (
                        os.path.basename(image_path),
                        f,
                        content_types.get(file_ext, 'application/octet-stream')
                    )
                }
                response = requests.post(
                    f"{self.api_url}/images/upload/",
                    headers=headers,
                    files=files
                )
            
            if response.status_code == 201:
                result = response.json()
                new_url = result['images'][0]['url']
                print(f"📤 Uploaded image: {os.path.basename(image_path)} -> {new_url}")
                self.stats['images_uploaded'] += 1
                return new_url
            else:
                print(f"❌ Failed to upload image {image_path}: {response.status_code} - {response.text}")
                self.stats['images_failed'] += 1
                return None
                
        except Exception as e:
            print(f"❌ Error uploading image {image_path}: {e}")
            self.stats['images_failed'] += 1
            return None
    
    def process_content_images(self, content: str, base_path: str) -> str:
        """Process images in content and upload them to Ghost"""
        import re
        
        # Find all image references in markdown/HTML
        img_patterns = [
            r'!\[([^\]]*)\]\(([^)]+)\)',  # Markdown: ![alt](src)
            r'<img[^>]+src=["\']([^"\']+)["\'][^>]*>',  # HTML: <img src="...">
        ]
        
        processed_content = content
        
        for pattern in img_patterns:
            for match in re.finditer(pattern, content):
                if pattern.startswith(r'!\['):
                    # Markdown image
                    alt_text = match.group(1)
                    img_src = match.group(2)
                    full_match = match.group(0)
                else:
                    # HTML image
                    img_src = match.group(1)
                    full_match = match.group(0)
                
                # Skip external images
                if img_src.startswith(('http://', 'https://')):
                    continue
                
                # Build full path to image
                # Handle double static paths like ../static/static/images/
                clean_src = img_src.lstrip('/')
                if clean_src.startswith('static/'):
                    clean_src = clean_src[7:]  # Remove static/ prefix
                
                image_path = os.path.join(base_path, clean_src)
                
                # Upload image
                new_url = self.upload_image(image_path, img_src)
                
                if new_url:
                    # Replace in content
                    if pattern.startswith(r'!\['):
                        new_img = f"![{alt_text}]({new_url})"
                    else:
                        new_img = full_match.replace(img_src, new_url)
                    
                    processed_content = processed_content.replace(full_match, new_img)
        
        return processed_content
    
    def create_post(self, post_data: Dict[str, Any]) -> bool:
        """Create a blog post in Ghost"""
        if self.dry_run:
            print(f"[DRY RUN] Would create post: {post_data.get('title')}")
            return True
        
        try:
            # Prepare Ghost post data
            ghost_post = {
                'title': post_data.get('title', 'Untitled'),
                'html': post_data.get('content', ''),
                'status': post_data.get('status', 'published'),
                'meta_title': post_data.get('meta_title'),
                'meta_description': post_data.get('meta_description'),
                'feature_image': post_data.get('feature_image'),
                'featured': post_data.get('featured', False),
                'tags': [{'name': tag} for tag in post_data.get('tags', [])],
                'authors': [{'slug': 'admin'}]  # Default to admin user
            }
            
            # Handle published_at with proper timezone
            if post_data.get('published_at'):
                published_at = post_data.get('published_at')
                # Ensure proper ISO format with timezone
                if not published_at.endswith('Z') and '+' not in published_at:
                    published_at += '+00:00'  # Add UTC timezone
                ghost_post['published_at'] = published_at
            
            # Remove None values
            ghost_post = {k: v for k, v in ghost_post.items() if v is not None}
            
            headers = self.get_auth_headers()
            response = requests.post(
                f"{self.api_url}/posts/",
                headers=headers,
                json={'posts': [ghost_post]}
            )
            
            if response.status_code == 201:
                result = response.json()
                post_id = result['posts'][0]['id']
                print(f"✅ Created post: {ghost_post['title']} (ID: {post_id})")
                self.stats['posts_created'] += 1
                return True
            else:
                print(f"❌ Failed to create post '{ghost_post['title']}': {response.status_code} - {response.text}")
                self.stats['posts_failed'] += 1
                return False
                
        except Exception as e:
            print(f"❌ Error creating post '{post_data.get('title')}': {e}")
            self.stats['posts_failed'] += 1
            return False
    
    def create_page(self, page_data: Dict[str, Any]) -> bool:
        """Create a static page in Ghost"""
        if self.dry_run:
            print(f"[DRY RUN] Would create page: {page_data.get('title')}")
            return True
        
        try:
            # Prepare Ghost page data
            ghost_page = {
                'title': page_data.get('title', 'Untitled'),
                'html': page_data.get('content', ''),
                'status': page_data.get('status', 'published'),
                'published_at': page_data.get('published_at'),
                'meta_title': page_data.get('meta_title'),
                'meta_description': page_data.get('meta_description'),
                'feature_image': page_data.get('feature_image'),
                'featured': page_data.get('featured', False),
                'tags': [{'name': tag} for tag in page_data.get('tags', [])],
                'slug': self.generate_slug(page_data.get('url_path', page_data.get('title', ''))),
                'authors': [{'slug': 'admin'}]
            }
            
            # Remove None values
            ghost_page = {k: v for k, v in ghost_page.items() if v is not None}
            
            headers = self.get_auth_headers()
            response = requests.post(
                f"{self.api_url}/pages/",
                headers=headers,
                json={'pages': [ghost_page]}
            )
            
            if response.status_code == 201:
                result = response.json()
                page_id = result['pages'][0]['id']
                print(f"✅ Created page: {ghost_page['title']} (ID: {page_id})")
                self.stats['pages_created'] += 1
                return True
            else:
                print(f"❌ Failed to create page '{ghost_page['title']}': {response.status_code} - {response.text}")
                self.stats['pages_failed'] += 1
                return False
                
        except Exception as e:
            print(f"❌ Error creating page '{page_data.get('title')}': {e}")
            self.stats['pages_failed'] += 1
            return False
    
    def generate_slug(self, title_or_path: str) -> str:
        """Generate a URL slug from title or path"""
        import re
        
        # If it looks like a path, extract the last part
        if '/' in title_or_path:
            slug = title_or_path.strip('/').split('/')[-1]
        else:
            slug = title_or_path
        
        # Convert to lowercase and replace spaces/special chars with hyphens
        slug = re.sub(r'[^\w\s-]', '', slug.lower())
        slug = re.sub(r'[-\s]+', '-', slug)
        
        return slug.strip('-')
    
    def import_posts(self, posts_file: Path, static_assets_path: str):
        """Import all blog posts"""
        print(f"📝 Importing posts from {posts_file}")
        
        with open(posts_file, 'r', encoding='utf-8') as f:
            posts = json.load(f)
        
        for post in posts:
            print(f"Processing post: {post.get('title')}")
            
            # Process images in content
            if static_assets_path:
                post['content'] = self.process_content_images(
                    post.get('content', ''), 
                    static_assets_path
                )
            
            # Create the post
            self.create_post(post)
            
            # Rate limiting
            time.sleep(0.5)
    
    def import_pages(self, pages_file: Path, static_assets_path: str):
        """Import all static pages"""
        print(f"📄 Importing pages from {pages_file}")
        
        with open(pages_file, 'r', encoding='utf-8') as f:
            pages = json.load(f)
        
        for page in pages:
            print(f"Processing page: {page.get('title')}")
            
            # Process images in content
            if static_assets_path:
                page['content'] = self.process_content_images(
                    page.get('content', ''), 
                    static_assets_path
                )
            
            # Create the page
            self.create_page(page)
            
            # Rate limiting
            time.sleep(0.5)
    
    def test_connection(self) -> bool:
        """Test connection to Ghost Admin API"""
        try:
            headers = self.get_auth_headers()
            response = requests.get(f"{self.api_url}/site/", headers=headers)
            
            if response.status_code == 200:
                site_data = response.json()
                print(f"✅ Connected to Ghost: {site_data['site']['title']}")
                return True
            else:
                print(f"❌ Failed to connect to Ghost: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Error connecting to Ghost: {e}")
            return False
    
    def print_stats(self):
        """Print import statistics"""
        print("\n📊 Import Statistics:")
        print(f"  Posts created: {self.stats['posts_created']}")
        print(f"  Posts failed: {self.stats['posts_failed']}")
        print(f"  Pages created: {self.stats['pages_created']}")
        print(f"  Pages failed: {self.stats['pages_failed']}")
        print(f"  Images uploaded: {self.stats['images_uploaded']}")
        print(f"  Images failed: {self.stats['images_failed']}")
        
        total_success = self.stats['posts_created'] + self.stats['pages_created']
        total_failed = self.stats['posts_failed'] + self.stats['pages_failed']
        
        if total_success + total_failed > 0:
            success_rate = (total_success / (total_success + total_failed)) * 100
            print(f"  Success rate: {success_rate:.1f}%")

def main():
    parser = argparse.ArgumentParser(description='Import converted content to Ghost CMS')
    parser.add_argument('--ghost-url', required=True, help='Ghost instance URL (e.g., http://localhost:2368)')
    parser.add_argument('--admin-key', required=True, help='Ghost Admin API key')
    parser.add_argument('--posts-file', help='JSON file with converted blog posts')
    parser.add_argument('--pages-file', help='JSON file with converted pages')
    parser.add_argument('--static-assets', help='Path to Hugo static assets directory')
    parser.add_argument('--dry-run', action='store_true', help='Simulate import without making changes')
    
    args = parser.parse_args()
    
    # Create importer
    importer = GhostImporter(args.ghost_url, args.admin_key, args.dry_run)
    
    # Test connection
    if not importer.test_connection():
        print("❌ Cannot connect to Ghost. Check your URL and API key.")
        return
    
    # Import posts
    if args.posts_file and Path(args.posts_file).exists():
        importer.import_posts(Path(args.posts_file), args.static_assets)
    
    # Import pages
    if args.pages_file and Path(args.pages_file).exists():
        importer.import_pages(Path(args.pages_file), args.static_assets)
    
    # Print statistics
    importer.print_stats()
    
    if importer.stats['posts_failed'] + importer.stats['pages_failed'] == 0:
        print("✅ All content imported successfully!")
    else:
        print("⚠️  Some content failed to import. Check the logs above.")

if __name__ == '__main__':
    main()