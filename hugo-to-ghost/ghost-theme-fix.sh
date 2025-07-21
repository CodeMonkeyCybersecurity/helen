#!/bin/bash
# Comprehensive Ghost Theme Fix Script

echo "🔧 Ghost Theme Fix Script"
echo "========================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Theme directory
THEME_DIR="/Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme"

echo -e "${YELLOW}Step 1: Repackaging theme with fixed assets...${NC}"
cd /Users/henry/Dev/helen/hugo-to-ghost

# Remove old package
rm -f cybermonkey-ghost-theme.zip

# Create the package
zip -r cybermonkey-ghost-theme.zip cybermonkey-ghost-theme \
  -x "*.DS_Store" \
  -x "__MACOSX" \
  -x "*.git*" \
  -x "node_modules/*"

echo -e "${GREEN}✓ Theme repackaged${NC}"

echo ""
echo -e "${YELLOW}Step 2: Ghost Configuration${NC}"
echo "Please follow these steps in order:"
echo ""
echo "1. ${YELLOW}Stop Ghost${NC} (if running locally):"
echo "   ghost stop"
echo ""
echo "2. ${YELLOW}Clear Ghost cache${NC}:"
echo "   ghost buster"
echo ""
echo "3. ${YELLOW}Start Ghost${NC}:"
echo "   ghost start"
echo ""
echo "4. ${YELLOW}Upload the theme${NC}:"
echo "   - Go to: http://localhost:2368/ghost/#/settings/theme"
echo "   - Click 'Change theme'"
echo "   - Upload: cybermonkey-ghost-theme.zip"
echo "   - Click 'Activate'"
echo ""
echo "5. ${YELLOW}Clear browser cache${NC}:"
echo "   - Hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)"
echo ""

echo -e "${GREEN}Additional Troubleshooting:${NC}"
echo ""
echo "If the theme still looks unstyled:"
echo ""
echo "A. ${YELLOW}Check Ghost logs${NC}:"
echo "   ghost log -f"
echo ""
echo "B. ${YELLOW}Verify theme is active${NC}:"
echo "   - Should show 'cybermonkey' as active theme in Ghost Admin"
echo ""
echo "C. ${YELLOW}Check browser console${NC}:"
echo "   - Open Developer Tools (F12)"
echo "   - Look for 404 errors on CSS files"
echo ""
echo "D. ${YELLOW}Alternative CSS fix${NC}:"
echo "   If CSS still won't load, try inline styles:"
echo "   - Edit: $THEME_DIR/default.hbs"
echo "   - Add <style> tag with CSS content directly in <head>"
echo ""

echo -e "${GREEN}✓ Fix script complete!${NC}"
echo ""
echo "Theme package location: ${GREEN}/Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme.zip${NC}"