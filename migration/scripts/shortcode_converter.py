#!/usr/bin/env python3
"""
Hugo Shortcode to Ghost HTML Converter
Converts Hugo shortcodes to Ghost-compatible HTML/markdown
"""

import re
import json
import argparse
from pathlib import Path
from typing import Dict, List, Any
from dataclasses import dataclass

@dataclass
class ShortcodeMatch:
    name: str
    params: str
    content: str
    full_match: str
    start_pos: int
    end_pos: int

class ShortcodeConverter:
    def __init__(self):
        self.conversion_stats = {}
        
    def convert_content(self, content: str) -> str:
        """Convert all shortcodes in content to Ghost-compatible HTML"""
        converted_content = content
        
        # Find all shortcodes (both self-closing and paired)
        shortcodes = self.find_all_shortcodes(content)
        
        # Convert in reverse order to maintain positions
        for shortcode in reversed(shortcodes):
            converted_html = self.convert_shortcode(shortcode)
            converted_content = (
                converted_content[:shortcode.start_pos] + 
                converted_html + 
                converted_content[shortcode.end_pos:]
            )
            
            # Track conversion stats
            if shortcode.name not in self.conversion_stats:
                self.conversion_stats[shortcode.name] = 0
            self.conversion_stats[shortcode.name] += 1
            
        return converted_content
    
    def find_all_shortcodes(self, content: str) -> List[ShortcodeMatch]:
        """Find all Hugo shortcodes in content"""
        shortcodes = []
        
        # Pattern for paired shortcodes: {{< shortcode >}}content{{< /shortcode >}}
        paired_pattern = r'\{\{\<\s*(\w+)([^>]*)\>\}\}(.*?)\{\{\<\s*/\1\s*\>\}\}'
        for match in re.finditer(paired_pattern, content, re.DOTALL):
            shortcodes.append(ShortcodeMatch(
                name=match.group(1),
                params=match.group(2).strip(),
                content=match.group(3),
                full_match=match.group(0),
                start_pos=match.start(),
                end_pos=match.end()
            ))
        
        # Pattern for self-closing shortcodes: {{< shortcode params >}}
        # Only match if not already part of a paired shortcode
        self_closing_pattern = r'\{\{\<\s*(\w+)([^>]*)\>\}\}'
        for match in re.finditer(self_closing_pattern, content):
            # Check if this match is not part of a paired shortcode
            is_part_of_paired = any(
                sc.start_pos <= match.start() < sc.end_pos 
                for sc in shortcodes
            )
            
            if not is_part_of_paired:
                shortcodes.append(ShortcodeMatch(
                    name=match.group(1),
                    params=match.group(2).strip(),
                    content="",
                    full_match=match.group(0),
                    start_pos=match.start(),
                    end_pos=match.end()
                ))
        
        # Sort by position
        return sorted(shortcodes, key=lambda x: x.start_pos)
    
    def convert_shortcode(self, shortcode: ShortcodeMatch) -> str:
        """Convert a single shortcode to HTML"""
        converter_method = getattr(self, f'convert_{shortcode.name}', self.convert_unknown)
        return converter_method(shortcode)
    
    def parse_shortcode_params(self, params_str: str) -> Dict[str, str]:
        """Parse shortcode parameters"""
        params = {}
        
        # Handle quoted parameters: param="value"
        quoted_pattern = r'(\w+)="([^"]*)"'
        for match in re.finditer(quoted_pattern, params_str):
            params[match.group(1)] = match.group(2)
        
        # Handle unquoted parameters: param=value
        unquoted_pattern = r'(\w+)=([^\s"]+)'
        for match in re.finditer(unquoted_pattern, params_str):
            if match.group(1) not in params:  # Don't override quoted params
                params[match.group(1)] = match.group(2)
        
        # Handle boolean flags: just the parameter name
        bool_pattern = r'\b(\w+)\b(?!=)'
        for match in re.finditer(bool_pattern, params_str):
            param_name = match.group(1)
            if param_name not in params:
                params[param_name] = "true"
        
        return params
    
    # Shortcode conversion methods
    
    def convert_card_unified(self, shortcode: ShortcodeMatch) -> str:
        """Convert card-unified shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        card_type = params.get('type', 'default')
        title = params.get('title', '')
        description = params.get('description', '')
        link = params.get('link', '#')
        color = params.get('color', 'gray')
        
        # Map card types to Ghost card classes
        type_classes = {
            'feature': 'feature-card',
            'service': 'service-card',
            'resource': 'resource-card',
            'default': 'content-card'
        }
        
        card_class = type_classes.get(card_type, 'content-card')
        
        return f'''
<div class="card {card_class} card-{color}">
    <div class="card-content">
        <h3 class="card-title">{title}</h3>
        <p class="card-description">{description}</p>
        {shortcode.content}
        <a href="{link}" class="card-link">Learn More →</a>
    </div>
</div>
'''
    
    def convert_card(self, shortcode: ShortcodeMatch) -> str:
        """Convert legacy card shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        title = params.get('title', '')
        link = params.get('link', '#')
        
        return f'''
<div class="card content-card">
    <div class="card-content">
        <h3 class="card-title">{title}</h3>
        {shortcode.content}
        <a href="{link}" class="card-link">Read More →</a>
    </div>
</div>
'''
    
    def convert_btn(self, shortcode: ShortcodeMatch) -> str:
        """Convert button shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        href = params.get('href', params.get('link', '#'))
        text = params.get('text', shortcode.content or 'Button')
        style = params.get('style', 'primary')
        
        return f'<a href="{href}" class="btn btn-{style}">{text}</a>'
    
    def convert_cta(self, shortcode: ShortcodeMatch) -> str:
        """Convert call-to-action shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        title = params.get('title', '')
        description = params.get('description', '')
        button_text = params.get('button_text', 'Get Started')
        button_link = params.get('button_link', '#')
        
        return f'''
<div class="cta-section">
    <h2 class="cta-title">{title}</h2>
    <p class="cta-description">{description}</p>
    {shortcode.content}
    <div class="cta-actions">
        <a href="{button_link}" class="btn btn-primary">{button_text}</a>
    </div>
</div>
'''
    
    def convert_columns(self, shortcode: ShortcodeMatch) -> str:
        """Convert columns shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        count = params.get('count', '2')
        gap = params.get('gap', '2rem')
        
        return f'''
<div class="columns columns-{count}" style="gap: {gap};">
    {shortcode.content}
</div>
'''
    
    def convert_grid(self, shortcode: ShortcodeMatch) -> str:
        """Convert grid shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        columns = params.get('columns', '3')
        gap = params.get('gap', '2rem')
        
        return f'''
<div class="grid grid-columns-{columns}" style="gap: {gap};">
    {shortcode.content}
</div>
'''
    
    def convert_tabs(self, shortcode: ShortcodeMatch) -> str:
        """Convert tabs shortcode to HTML"""
        return f'''
<div class="tabs-container">
    {shortcode.content}
</div>
<script>
// Simple tab functionality
document.querySelectorAll('.tab-button').forEach(button => {{
    button.addEventListener('click', () => {{
        // Tab switching logic
        const tabId = button.dataset.tab;
        // Hide all tab content
        document.querySelectorAll('.tab-content').forEach(content => {{
            content.style.display = 'none';
        }});
        // Show selected tab
        document.getElementById(tabId).style.display = 'block';
    }});
}});
</script>
'''
    
    def convert_tab(self, shortcode: ShortcodeMatch) -> str:
        """Convert individual tab shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        title = params.get('title', 'Tab')
        id = params.get('id', title.lower().replace(' ', '-'))
        
        return f'''
<div class="tab">
    <button class="tab-button" data-tab="{id}">{title}</button>
    <div id="{id}" class="tab-content">
        {shortcode.content}
    </div>
</div>
'''
    
    def convert_details(self, shortcode: ShortcodeMatch) -> str:
        """Convert details/collapsible shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        summary = params.get('summary', 'Details')
        open_attr = 'open' if params.get('open') == 'true' else ''
        
        return f'''
<details {open_attr}>
    <summary>{summary}</summary>
    <div class="details-content">
        {shortcode.content}
    </div>
</details>
'''
    
    def convert_hint(self, shortcode: ShortcodeMatch) -> str:
        """Convert hint/callout shortcode to Ghost callout"""
        params = self.parse_shortcode_params(shortcode.params)
        
        type = params.get('type', 'info')
        title = params.get('title', '')
        
        # Map hint types to emoji/styling
        type_mapping = {
            'info': '💡',
            'warning': '⚠️',
            'danger': '🚨',
            'success': '✅',
            'tip': '💡'
        }
        
        icon = type_mapping.get(type, '💡')
        
        return f'''
<div class="callout callout-{type}">
    <div class="callout-header">
        <span class="callout-icon">{icon}</span>
        {f'<span class="callout-title">{title}</span>' if title else ''}
    </div>
    <div class="callout-content">
        {shortcode.content}
    </div>
</div>
'''
    
    def convert_recent_posts(self, shortcode: ShortcodeMatch) -> str:
        """Convert recent posts shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        limit = params.get('limit', '3')
        
        # In Ghost, this would be handled by theme templates
        # For now, convert to a placeholder
        return f'''
<div class="recent-posts" data-limit="{limit}">
    <!-- Recent posts will be populated by Ghost theme -->
    <h3>Latest Posts</h3>
    <p><em>Recent posts will appear here automatically.</em></p>
</div>
'''
    
    def convert_current_date(self, shortcode: ShortcodeMatch) -> str:
        """Convert current date shortcode"""
        from datetime import datetime
        
        params = self.parse_shortcode_params(shortcode.params)
        format = params.get('format', '%Y-%m-%d')
        
        try:
            current_date = datetime.now().strftime(format)
        except:
            current_date = datetime.now().strftime('%Y-%m-%d')
            
        return f'<span class="current-date">{current_date}</span>'
    
    def convert_image(self, shortcode: ShortcodeMatch) -> str:
        """Convert image shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        src = params.get('src', '')
        alt = params.get('alt', '')
        caption = params.get('caption', '')
        width = params.get('width', '')
        height = params.get('height', '')
        
        style_parts = []
        if width:
            style_parts.append(f'width: {width}')
        if height:
            style_parts.append(f'height: {height}')
        
        style = f' style="{"; ".join(style_parts)}"' if style_parts else ''
        
        img_html = f'<img src="{src}" alt="{alt}"{style}>'
        
        if caption:
            return f'''
<figure class="image-figure">
    {img_html}
    <figcaption>{caption}</figcaption>
</figure>
'''
        
        return img_html
    
    def convert_section(self, shortcode: ShortcodeMatch) -> str:
        """Convert section shortcode"""
        params = self.parse_shortcode_params(shortcode.params)
        
        class_name = params.get('class', 'content-section')
        id = params.get('id', '')
        
        id_attr = f' id="{id}"' if id else ''
        
        return f'''
<section class="{class_name}"{id_attr}>
    {shortcode.content}
</section>
'''
    
    def convert_unknown(self, shortcode: ShortcodeMatch) -> str:
        """Handle unknown shortcodes"""
        print(f"⚠️  Unknown shortcode: {shortcode.name}")
        
        # Return as HTML comment for manual review
        return f'''
<!-- 
UNKNOWN SHORTCODE: {shortcode.name}
PARAMS: {shortcode.params}
CONTENT: {shortcode.content}
ORIGINAL: {shortcode.full_match}
-->
<div class="shortcode-placeholder" data-shortcode="{shortcode.name}">
    <p><strong>Manual conversion needed:</strong> {shortcode.name} shortcode</p>
    {shortcode.content}
</div>
'''

def convert_file_content(content_file: Path, output_file: Path):
    """Convert shortcodes in a content file"""
    
    with open(content_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    converter = ShortcodeConverter()
    
    for item in data:
        if 'content' in item:
            print(f"Converting shortcodes in: {item.get('title', 'Unknown')}")
            item['content'] = converter.convert_content(item['content'])
            item['shortcode_conversion_stats'] = converter.conversion_stats.copy()
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"📝 Converted content saved to: {output_file}")
    print("📊 Shortcode conversion stats:")
    for shortcode, count in converter.conversion_stats.items():
        print(f"  {shortcode}: {count} conversions")

def main():
    parser = argparse.ArgumentParser(description='Convert Hugo shortcodes to Ghost HTML')
    parser.add_argument('--input-file', required=True, help='Input JSON file with extracted Hugo content')
    parser.add_argument('--output-file', required=True, help='Output JSON file with converted content')
    
    args = parser.parse_args()
    
    convert_file_content(Path(args.input_file), Path(args.output_file))
    print("✅ Shortcode conversion complete!")

if __name__ == '__main__':
    main()