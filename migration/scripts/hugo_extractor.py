#!/usr/bin/env python3
"""
Hugo to Ghost Content Extractor
Extracts content from Hugo markdown files and prepares it for Ghost import
"""

import os
import json
import re
import yaml
import toml
from pathlib import Path
from datetime import datetime, date
from typing import Dict, List, Any, Optional
import frontmatter
import argparse

class DateTimeEncoder(json.JSONEncoder):
    """Custom JSON encoder to handle datetime and date objects"""
    def default(self, obj):
        if isinstance(obj, (datetime, date)):
            return obj.isoformat()
        return super().default(obj)

class HugoExtractor:
    def __init__(self, hugo_content_dir: str, output_dir: str):
        self.hugo_content_dir = Path(hugo_content_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        self.posts = []
        self.pages = []
        self.assets = []
        self.shortcodes = {}
        
    def extract_all_content(self):
        """Extract all content from Hugo site"""
        print("🔍 Extracting Hugo content...")
        
        # Walk through all markdown files
        for md_file in self.hugo_content_dir.rglob("*.md"):
            try:
                content_item = self.process_markdown_file(md_file)
                if content_item:
                    # Determine if it's a post or page
                    if self.is_blog_post(md_file, content_item):
                        self.posts.append(content_item)
                        print(f"📝 Found blog post: {content_item['title']}")
                    else:
                        self.pages.append(content_item)
                        print(f"📄 Found page: {content_item['title']}")
            except Exception as e:
                print(f"⚠️  Error processing {md_file}: {e}")
                
        # Extract assets
        self.extract_assets()
        
        # Analyze shortcodes
        self.analyze_shortcodes()
        
        print(f"✅ Extracted {len(self.posts)} posts and {len(self.pages)} pages")
        
    def process_markdown_file(self, file_path: Path) -> Optional[Dict[str, Any]]:
        """Process a single markdown file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                post = frontmatter.load(f)
                
            # Get relative path for URL generation
            rel_path = file_path.relative_to(self.hugo_content_dir)
            
            content_item = {
                'title': post.metadata.get('title', file_path.stem),
                'content': post.content,
                'raw_frontmatter': post.metadata,
                'file_path': str(file_path),
                'relative_path': str(rel_path),
                'url_path': self.generate_url_path(rel_path),
                'extracted_shortcodes': self.extract_shortcodes_from_content(post.content),
                'processed_at': datetime.now().isoformat()
            }
            
            # Process common frontmatter fields
            self.process_frontmatter(content_item, post.metadata)
            
            return content_item
            
        except Exception as e:
            print(f"Error processing {file_path}: {e}")
            return None
    
    def process_frontmatter(self, content_item: Dict, frontmatter: Dict):
        """Process frontmatter into Ghost-compatible format"""
        
        # Date handling
        if 'date' in frontmatter:
            content_item['published_at'] = self.parse_date(frontmatter['date'])
        elif 'publishDate' in frontmatter:
            content_item['published_at'] = self.parse_date(frontmatter['publishDate'])
            
        # Meta description
        if 'description' in frontmatter:
            content_item['meta_description'] = frontmatter['description']
        elif 'summary' in frontmatter:
            content_item['meta_description'] = frontmatter['summary']
            
        # Tags and categories
        tags = []
        if 'tags' in frontmatter:
            if isinstance(frontmatter['tags'], list):
                tags.extend(frontmatter['tags'])
            else:
                tags.append(frontmatter['tags'])
                
        if 'categories' in frontmatter:
            if isinstance(frontmatter['categories'], list):
                tags.extend(frontmatter['categories'])
            else:
                tags.append(frontmatter['categories'])
                
        content_item['tags'] = list(set(tags))  # Remove duplicates
        
        # Author
        content_item['author'] = frontmatter.get('author', 'Admin')
        
        # Featured image
        if 'featured_image' in frontmatter:
            content_item['feature_image'] = frontmatter['featured_image']
        elif 'image' in frontmatter:
            content_item['feature_image'] = frontmatter['image']
            
        # Draft status
        content_item['status'] = 'draft' if frontmatter.get('draft', False) else 'published'
        
        # Weight/order
        content_item['sort_order'] = frontmatter.get('weight', 0)
        
        # SEO
        content_item['meta_title'] = frontmatter.get('title', content_item['title'])
        
    def parse_date(self, date_value) -> str:
        """Parse various date formats to ISO string"""
        from datetime import date
        
        if isinstance(date_value, datetime):
            return date_value.isoformat()
        elif isinstance(date_value, date):
            return datetime.combine(date_value, datetime.min.time()).isoformat()
        elif isinstance(date_value, str):
            try:
                # Try parsing common formats
                for fmt in ['%Y-%m-%d', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S%z']:
                    try:
                        dt = datetime.strptime(date_value, fmt)
                        return dt.isoformat()
                    except ValueError:
                        continue
                # If all else fails, return current time
                print(f"⚠️  Could not parse date: {date_value}, using current time")
                return datetime.now().isoformat()
            except:
                return datetime.now().isoformat()
        
        # Default to current time for any unparseable date
        return datetime.now().isoformat()
    
    def is_blog_post(self, file_path: Path, content_item: Dict) -> bool:
        """Determine if content is a blog post or static page"""
        # Check if it's in the blog directory
        if 'blog' in file_path.parts:
            return True
            
        # Check if it has a date
        if 'published_at' in content_item:
            return True
            
        # Check frontmatter type
        post_type = content_item['raw_frontmatter'].get('type', '')
        if post_type in ['post', 'blog']:
            return True
            
        return False
    
    def generate_url_path(self, rel_path: Path) -> str:
        """Generate URL path from file path"""
        parts = list(rel_path.parts)
        
        # Remove index files and file extensions
        if parts[-1] in ['_index.md', 'index.md']:
            parts = parts[:-1]
        elif parts[-1].endswith('.md'):
            parts[-1] = parts[-1][:-3]
            
        # Create URL path
        if not parts:
            return '/'
        return '/' + '/'.join(parts) + '/'
    
    def extract_shortcodes_from_content(self, content: str) -> List[Dict]:
        """Extract Hugo shortcodes from content"""
        shortcodes = []
        
        # Pattern for Hugo shortcodes: {{< shortcode params >}}
        pattern = r'\{\{\<\s*(\w+)([^>]*)\>\}\}'
        
        for match in re.finditer(pattern, content):
            shortcode_name = match.group(1)
            shortcode_params = match.group(2).strip()
            
            shortcodes.append({
                'name': shortcode_name,
                'params': shortcode_params,
                'full_match': match.group(0),
                'position': match.span()
            })
            
            # Track shortcode usage
            if shortcode_name not in self.shortcodes:
                self.shortcodes[shortcode_name] = 0
            self.shortcodes[shortcode_name] += 1
            
        return shortcodes
    
    def extract_assets(self):
        """Extract static assets that need to be migrated"""
        static_dir = self.hugo_content_dir.parent / 'static'
        
        if static_dir.exists():
            for asset_file in static_dir.rglob('*'):
                if asset_file.is_file():
                    # Skip certain file types
                    if asset_file.suffix.lower() in ['.xml', '.txt', '.json']:
                        continue
                        
                    self.assets.append({
                        'file_path': str(asset_file),
                        'relative_path': str(asset_file.relative_to(static_dir)),
                        'url_path': '/' + str(asset_file.relative_to(static_dir)),
                        'size': asset_file.stat().st_size,
                        'type': 'image' if asset_file.suffix.lower() in ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg'] else 'file'
                    })
    
    def analyze_shortcodes(self):
        """Analyze shortcode usage for conversion planning"""
        print("🔧 Shortcode usage analysis:")
        for shortcode, count in sorted(self.shortcodes.items(), key=lambda x: x[1], reverse=True):
            print(f"  {shortcode}: {count} uses")
    
    def save_extraction_results(self):
        """Save all extracted content to JSON files"""
        
        # Save posts
        posts_file = self.output_dir / 'hugo_posts.json'
        with open(posts_file, 'w', encoding='utf-8') as f:
            json.dump(self.posts, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        print(f"💾 Saved {len(self.posts)} posts to {posts_file}")
        
        # Save pages
        pages_file = self.output_dir / 'hugo_pages.json'
        with open(pages_file, 'w', encoding='utf-8') as f:
            json.dump(self.pages, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        print(f"💾 Saved {len(self.pages)} pages to {pages_file}")
        
        # Save assets
        assets_file = self.output_dir / 'hugo_assets.json'
        with open(assets_file, 'w', encoding='utf-8') as f:
            json.dump(self.assets, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        print(f"💾 Saved {len(self.assets)} assets to {assets_file}")
        
        # Save shortcode analysis
        shortcodes_file = self.output_dir / 'shortcode_analysis.json'
        with open(shortcodes_file, 'w', encoding='utf-8') as f:
            json.dump(self.shortcodes, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        print(f"💾 Saved shortcode analysis to {shortcodes_file}")
        
        # Save summary
        summary = {
            'extraction_date': datetime.now().isoformat(),
            'total_posts': len(self.posts),
            'total_pages': len(self.pages),
            'total_assets': len(self.assets),
            'shortcode_types': len(self.shortcodes),
            'total_shortcode_uses': sum(self.shortcodes.values())
        }
        
        summary_file = self.output_dir / 'extraction_summary.json'
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2, ensure_ascii=False, cls=DateTimeEncoder)
        print(f"📊 Saved extraction summary to {summary_file}")

def main():
    parser = argparse.ArgumentParser(description='Extract content from Hugo site for Ghost migration')
    parser.add_argument('--content-dir', required=True, help='Path to Hugo content directory')
    parser.add_argument('--output-dir', required=True, help='Output directory for extracted content')
    
    args = parser.parse_args()
    
    extractor = HugoExtractor(args.content_dir, args.output_dir)
    extractor.extract_all_content()
    extractor.save_extraction_results()
    
    print("✅ Hugo content extraction complete!")

if __name__ == '__main__':
    main()