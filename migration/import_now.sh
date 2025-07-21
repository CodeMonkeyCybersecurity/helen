#!/bin/bash
# Direct import to Ghost - skip the prompts

source venv/bin/activate

echo "🚀 Importing content to Ghost..."

python3 scripts/ghost_importer.py \
    --ghost-url "http://localhost:2368" \
    --admin-key "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22" \
    --posts-file converted/ghost_posts.json \
    --pages-file converted/ghost_pages.json \
    --static-assets ../static

echo ""
echo "✅ Migration complete!"
echo ""
echo "Next steps:"
echo "1. Visit http://localhost:2368/ghost/ to review imported content"
echo "2. Go to Settings → Design and activate your custom theme"
echo "3. Configure site settings (Settings → General)"
echo "4. Set up navigation (Settings → Navigation)"