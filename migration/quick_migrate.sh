#!/bin/bash
# Quick Ghost Migration - Uses existing extracted content
# Run this if you already have extracted/ directory with content

set -e

MIGRATION_DIR="/Users/henry/Dev/helen/migration"
GHOST_URL="http://localhost:2368"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}🔄 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we have extracted content
if [ ! -f "extracted/hugo_posts.json" ] || [ ! -f "extracted/hugo_pages.json" ]; then
    print_error "No extracted content found. Run the full migration script first."
    echo "Expected files:"
    echo "  - extracted/hugo_posts.json"
    echo "  - extracted/hugo_pages.json"
    exit 1
fi

# Check Ghost connection
if ! curl -s -f "$GHOST_URL" > /dev/null; then
    print_error "Cannot connect to Ghost at $GHOST_URL"
    print_error "Make sure Ghost is running: docker compose up -d"
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

print_step "Using existing extracted content..."
echo "📊 Found:"
echo "  - $(jq length extracted/hugo_posts.json) blog posts"
echo "  - $(jq length extracted/hugo_pages.json) pages"

# Convert shortcodes (skip if already done)
mkdir -p converted

if [ ! -f "converted/ghost_posts.json" ]; then
    print_step "Converting shortcodes in posts..."
    python3 scripts/shortcode_converter.py \
        --input-file extracted/hugo_posts.json \
        --output-file converted/ghost_posts.json
fi

if [ ! -f "converted/ghost_pages.json" ]; then
    print_step "Converting shortcodes in pages..."
    python3 scripts/shortcode_converter.py \
        --input-file extracted/hugo_pages.json \
        --output-file converted/ghost_pages.json
fi

# Get Ghost Admin API key
echo ""
echo -e "${YELLOW}Ghost Admin API Key needed.${NC}"
echo "To get your API key:"
echo "1. Visit $GHOST_URL/ghost/"
echo "2. Go to Settings → Integrations"
echo "3. Click 'Add custom integration'"
echo "4. Name it 'Migration Tool'"
echo "5. Copy the Admin API Key"
echo ""
read -p "Enter Ghost Admin API Key: " GHOST_ADMIN_KEY

if [ -z "$GHOST_ADMIN_KEY" ]; then
    print_error "Admin API key is required"
    exit 1
fi

# Test connection
print_step "Testing Ghost connection..."
python3 scripts/ghost_importer.py \
    --ghost-url "$GHOST_URL" \
    --admin-key "$GHOST_ADMIN_KEY" \
    --posts-file converted/ghost_posts.json \
    --pages-file converted/ghost_pages.json \
    --static-assets ../static \
    --dry-run

echo ""
echo -e "${YELLOW}Dry run complete. Ready to import content to Ghost.${NC}"
read -p "Proceed with actual import? (y/N): " proceed

if [[ $proceed =~ ^[Yy]$ ]]; then
    print_step "Importing content to Ghost..."
    python3 scripts/ghost_importer.py \
        --ghost-url "$GHOST_URL" \
        --admin-key "$GHOST_ADMIN_KEY" \
        --posts-file converted/ghost_posts.json \
        --pages-file converted/ghost_pages.json \
        --static-assets ../static
    
    echo ""
    echo -e "${GREEN}✅ Migration complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Visit $GHOST_URL/ghost/ to review imported content"
    echo "2. Go to Settings → Design and activate your custom theme"
    echo "3. Configure site settings (Settings → General)"
    echo "4. Set up navigation (Settings → Navigation)"
    echo ""
    echo "Your Hugo site is still running and unchanged."
else
    print_warning "Import cancelled"
fi