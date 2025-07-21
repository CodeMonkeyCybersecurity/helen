#!/bin/bash

echo "Packaging Code Monkey Cybersecurity Ghost Theme..."

cd cybermonkey-ghost-theme

# Create zip file excluding unwanted files
zip -r ../cybermonkey-ghost-theme.zip . \
  -x "*.DS_Store" \
  -x "__MACOSX" \
  -x "*.git*" \
  -x "node_modules/*" \
  -x "*.log"

cd ..

echo "✓ Theme packaged successfully as cybermonkey-ghost-theme.zip"
echo ""
echo "To install:"
echo "1. Log into your Ghost admin panel"
echo "2. Go to Settings → Theme"
echo "3. Click 'Upload theme' and select cybermonkey-ghost-theme.zip"
echo "4. Activate the theme"
echo ""
echo "Don't forget to:"
echo "- Upload your font files (Atkinson Hyperlegible) to assets/fonts/"
echo "- Configure navigation in Ghost admin"
echo "- Set up the Content API key for search functionality"