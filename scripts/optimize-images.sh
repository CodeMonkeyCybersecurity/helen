#!/bin/bash

# Hugo-native image optimization script
# Moves large images from static/ to assets/ for Hugo processing

echo "🖼️ Optimizing images with Hugo..."

# Create assets/images directory if it doesn't exist
mkdir -p assets/images

# Move large images to assets for Hugo processing
echo "Moving large images to assets/ for Hugo processing..."

# List of large images that need optimization
LARGE_IMAGES=(
    "cover_puppy_moni_monkey.png"
    "antivirus_siem_xdr_optimized.jpg"
    "xdr_1.jpg"
    "xdr_2.jpg" 
    "xdr_3.jpg"
)

for image in "${LARGE_IMAGES[@]}"; do
    if [ -f "static/images/$image" ]; then
        echo "Moving $image to assets/images/"
        cp "static/images/$image" "assets/images/"
    fi
done

echo "✅ Images ready for Hugo processing"
echo "💡 Use {{< optimized-image src=\"images/$image\" alt=\"description\" >}} in your content"
echo "💡 Hugo will generate WebP + responsive versions automatically"

# Optional: Show size comparison
echo ""
echo "📊 Original image sizes:"
du -h static/images/cover_puppy_moni_monkey.png 2>/dev/null || echo "Hero image not found"
du -h static/images/*.jpg 2>/dev/null | head -5 || echo "No large JPGs found"

echo ""
echo "🚀 Run 'hugo server' to see optimized images in action"