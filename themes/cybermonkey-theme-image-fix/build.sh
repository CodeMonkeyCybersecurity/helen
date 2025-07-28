#!/bin/bash
# Build script for Code Monkey Cybersecurity Ghost Theme

set -e

echo "🔨 Building Ghost theme..."

# Clean previous builds
rm -f *.zip
rm -rf dist/

# Create dist directory
mkdir -p dist

# Copy theme files
cp -r assets dist/
cp -r partials dist/
cp -r locales dist/
cp *.hbs dist/
cp package.json dist/
cp routes.yaml dist/
cp README.md dist/

# Create theme package
cd dist
zip -r ../cybermonkey-ghost-theme.zip . -x "*.DS_Store" -x "__MACOSX/*"
cd ..

# Clean up
rm -rf dist/

echo "✅ Theme built successfully: cybermonkey-ghost-theme.zip"
echo "📦 File size: $(du -h cybermonkey-ghost-theme.zip | cut -f1)"