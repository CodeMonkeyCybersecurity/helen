#!/bin/bash
# Script to properly package the Ghost theme

cd /Users/henry/Dev/helen/hugo-to-ghost/cybermonkey-ghost-theme

# Ensure all required files exist
echo "Checking theme structure..."

# Create gscan config file (required by Ghost)
cat > .ghost.json << EOF
{
  "engines": {
    "ghost-api": "v5"
  }
}
EOF

# Copy fonts from Hugo site if they don't exist
if [ ! -d "assets/fonts/Atkinson_Hyperlegible" ]; then
  echo "Copying fonts from Hugo site..."
  mkdir -p assets/fonts
  cp -r ../../static/fonts/Atkinson_Hyperlegible assets/fonts/
  cp -r ../../static/fonts/Inter assets/fonts/
  cp -r ../../static/fonts/Noto_Sans_Mono assets/fonts/
fi

# Copy favicon if needed
if [ ! -f "assets/images/favicon.png" ]; then
  echo "Copying favicon..."
  mkdir -p assets/images
  cp ../../static/favicon.png assets/images/
fi

# Update font paths in CSS
echo "Updating font paths in CSS..."
sed -i.bak 's|url('\''\/fonts\/|url('\''..\/fonts\/|g' assets/css/main.css
rm assets/css/main.css.bak

# Create the theme package
echo "Creating theme package..."
cd ..
rm -f cybermonkey-ghost-theme.zip
zip -r cybermonkey-ghost-theme.zip cybermonkey-ghost-theme \
  -x "*.DS_Store" \
  -x "__MACOSX" \
  -x "*.git*" \
  -x "node_modules/*"

echo "Theme packaged successfully!"
echo "Theme file: cybermonkey-ghost-theme.zip"
echo ""
echo "Next steps:"
echo "1. Go to Ghost Admin → Settings → Theme"
echo "2. Upload cybermonkey-ghost-theme.zip"
echo "3. Activate the theme"
echo "4. Configure navigation in Settings → Navigation"