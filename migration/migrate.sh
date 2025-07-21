#!/bin/bash
# Hugo to Ghost Migration Script
# Comprehensive migration from Hugo to Ghost CMS

set -e

# Configuration
HUGO_CONTENT_DIR="/Users/henry/Dev/helen/content"
HUGO_STATIC_DIR="/Users/henry/Dev/helen/static"
MIGRATION_DIR="/Users/henry/Dev/helen/migration"
SCRIPTS_DIR="$MIGRATION_DIR/scripts"
EXTRACTED_DIR="$MIGRATION_DIR/extracted"
CONVERTED_DIR="$MIGRATION_DIR/converted"
ASSETS_DIR="$MIGRATION_DIR/assets"

GHOST_URL="http://localhost:2368"
GHOST_ADMIN_KEY=""  # Will be prompted if not set

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE} Hugo to Ghost Migration${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_step() {
    echo -e "${GREEN}🔄 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_dependencies() {
    print_step "Checking dependencies..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    # Set up virtual environment if it doesn't exist
    if [ ! -d "$MIGRATION_DIR/venv" ]; then
        print_step "Creating Python virtual environment..."
        python3 -m venv "$MIGRATION_DIR/venv"
    fi
    
    # Activate virtual environment
    source "$MIGRATION_DIR/venv/bin/activate"
    
    # Check pip modules in venv
    if ! python3 -c "import frontmatter, requests, jwt" 2>/dev/null; then
        print_warning "Installing Python dependencies in virtual environment..."
        pip install -r "$SCRIPTS_DIR/requirements.txt"
    fi
    
    # Check Ghost connection
    if ! curl -s -f "$GHOST_URL" > /dev/null; then
        print_error "Cannot connect to Ghost at $GHOST_URL"
        print_error "Make sure Ghost is running: docker compose up -d"
        exit 1
    fi
    
    print_success "Dependencies check complete"
}

get_ghost_admin_key() {
    if [ -z "$GHOST_ADMIN_KEY" ]; then
        echo -e "${YELLOW}Ghost Admin API Key needed.${NC}"
        echo "To get your API key:"
        echo "1. Go to $GHOST_URL/ghost/"
        echo "2. Navigate to Settings → Integrations"
        echo "3. Create a new Custom Integration"
        echo "4. Copy the Admin API Key"
        echo ""
        read -p "Enter Ghost Admin API Key: " GHOST_ADMIN_KEY
        
        if [ -z "$GHOST_ADMIN_KEY" ]; then
            print_error "Admin API key is required"
            exit 1
        fi
    fi
}

setup_directories() {
    print_step "Setting up directories..."
    
    mkdir -p "$EXTRACTED_DIR"
    mkdir -p "$CONVERTED_DIR" 
    mkdir -p "$ASSETS_DIR"
    
    print_success "Directories created"
}

extract_hugo_content() {
    print_step "Extracting Hugo content..."
    
    source "$MIGRATION_DIR/venv/bin/activate"
    python3 "$SCRIPTS_DIR/hugo_extractor.py" \
        --content-dir "$HUGO_CONTENT_DIR" \
        --output-dir "$EXTRACTED_DIR"
    
    print_success "Hugo content extracted"
}

copy_assets() {
    print_step "Copying static assets..."
    
    if [ -d "$HUGO_STATIC_DIR" ]; then
        cp -r "$HUGO_STATIC_DIR"/* "$ASSETS_DIR/" 2>/dev/null || true
        print_success "Assets copied to $ASSETS_DIR"
    else
        print_warning "Hugo static directory not found: $HUGO_STATIC_DIR"
    fi
}

convert_shortcodes() {
    print_step "Converting Hugo shortcodes..."
    
    source "$MIGRATION_DIR/venv/bin/activate"
    
    # Convert posts
    if [ -f "$EXTRACTED_DIR/hugo_posts.json" ]; then
        python3 "$SCRIPTS_DIR/shortcode_converter.py" \
            --input-file "$EXTRACTED_DIR/hugo_posts.json" \
            --output-file "$CONVERTED_DIR/ghost_posts.json"
    fi
    
    # Convert pages
    if [ -f "$EXTRACTED_DIR/hugo_pages.json" ]; then
        python3 "$SCRIPTS_DIR/shortcode_converter.py" \
            --input-file "$EXTRACTED_DIR/hugo_pages.json" \
            --output-file "$CONVERTED_DIR/ghost_pages.json"
    fi
    
    print_success "Shortcode conversion complete"
}

import_to_ghost() {
    print_step "Importing content to Ghost..."
    
    source "$MIGRATION_DIR/venv/bin/activate"
    
    # Test mode first
    print_step "Running dry-run test..."
    python3 "$SCRIPTS_DIR/ghost_importer.py" \
        --ghost-url "$GHOST_URL" \
        --admin-key "$GHOST_ADMIN_KEY" \
        --posts-file "$CONVERTED_DIR/ghost_posts.json" \
        --pages-file "$CONVERTED_DIR/ghost_pages.json" \
        --static-assets "$ASSETS_DIR" \
        --dry-run
    
    echo ""
    read -p "Dry run complete. Proceed with actual import? (y/N): " proceed
    
    if [[ $proceed =~ ^[Yy]$ ]]; then
        print_step "Importing to Ghost (for real)..."
        python3 "$SCRIPTS_DIR/ghost_importer.py" \
            --ghost-url "$GHOST_URL" \
            --admin-key "$GHOST_ADMIN_KEY" \
            --posts-file "$CONVERTED_DIR/ghost_posts.json" \
            --pages-file "$CONVERTED_DIR/ghost_pages.json" \
            --static-assets "$ASSETS_DIR"
        
        print_success "Content imported to Ghost"
    else
        print_warning "Import cancelled"
    fi
}

generate_report() {
    print_step "Generating migration report..."
    
    REPORT_FILE="$MIGRATION_DIR/migration_report.md"
    
    cat > "$REPORT_FILE" << EOF
# Hugo to Ghost Migration Report

**Migration Date:** $(date)
**Hugo Content Directory:** $HUGO_CONTENT_DIR
**Ghost URL:** $GHOST_URL

## Content Summary

EOF

    if [ -f "$EXTRACTED_DIR/extraction_summary.json" ]; then
        echo "### Extracted Content" >> "$REPORT_FILE"
        source "$MIGRATION_DIR/venv/bin/activate"
        python3 -c "
import json
with open('$EXTRACTED_DIR/extraction_summary.json', 'r') as f:
    data = json.load(f)
    print(f\"- **Posts:** {data.get('total_posts', 0)}\")
    print(f\"- **Pages:** {data.get('total_pages', 0)}\") 
    print(f\"- **Assets:** {data.get('total_assets', 0)}\")
    print(f\"- **Shortcode Types:** {data.get('shortcode_types', 0)}\")
    print(f\"- **Total Shortcode Uses:** {data.get('total_shortcode_uses', 0)}\")
" >> "$REPORT_FILE"
    fi

    cat >> "$REPORT_FILE" << EOF

## Next Steps

1. **Review imported content** at $GHOST_URL/ghost/
2. **Activate the custom theme** in Ghost Admin → Settings → Design
3. **Configure site settings** (title, description, navigation)
4. **Set up redirects** for changed URLs
5. **Test all functionality** before going live

## URLs to Check

- Ghost Admin: $GHOST_URL/ghost/
- Ghost Site: $GHOST_URL/
- Content API: $GHOST_URL/ghost/api/content/

## Files Generated

- Extracted Content: \`$EXTRACTED_DIR/\`
- Converted Content: \`$CONVERTED_DIR/\`
- Static Assets: \`$ASSETS_DIR/\`
- Migration Scripts: \`$SCRIPTS_DIR/\`

EOF

    print_success "Migration report saved to $REPORT_FILE"
}

cleanup() {
    print_step "Cleaning up temporary files..."
    
    # Keep extracted and converted files, just clean up any temp files
    find "$MIGRATION_DIR" -name "*.tmp" -delete 2>/dev/null || true
    
    print_success "Cleanup complete"
}

show_next_steps() {
    echo ""
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo "1. Visit $GHOST_URL/ghost/ to access Ghost Admin"
    echo "2. Go to Settings → Design and activate your custom theme"
    echo "3. Configure site settings (Settings → General)"
    echo "4. Set up navigation (Settings → Navigation)"
    echo "5. Review and test imported content"
    echo "6. Set up redirects for SEO (if URLs changed)"
    echo ""
    echo -e "${GREEN}🎉 Migration complete!${NC}"
}

# Main execution
main() {
    print_header
    
    # Parse command line arguments
    DRY_RUN=false
    SKIP_EXTRACTION=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-extraction)
                SKIP_EXTRACTION=true
                shift
                ;;
            --ghost-key)
                GHOST_ADMIN_KEY="$2"
                shift 2
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --dry-run          Run extraction and conversion only"
                echo "  --skip-extraction  Skip extraction, use existing files"
                echo "  --ghost-key KEY    Ghost Admin API key"
                echo "  --help             Show this help"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute migration steps
    check_dependencies
    setup_directories
    
    if [ "$SKIP_EXTRACTION" = false ]; then
        extract_hugo_content
        copy_assets
        convert_shortcodes
    else
        print_warning "Skipping extraction, using existing files"
    fi
    
    if [ "$DRY_RUN" = false ]; then
        get_ghost_admin_key
        import_to_ghost
    else
        print_warning "Dry run mode - no import to Ghost"
    fi
    
    generate_report
    cleanup
    show_next_steps
}

# Run main function
main "$@"