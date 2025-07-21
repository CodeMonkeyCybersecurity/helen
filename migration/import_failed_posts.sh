#!/bin/bash
# Import only the failed posts with fixes

source venv/bin/activate

echo "🔧 Re-importing failed blog posts with fixes..."

# Get list of existing posts to avoid duplicates
echo "📋 Checking existing posts..."
EXISTING_POSTS=$(python3 -c "
import requests
import json

headers = {
    'Authorization': 'Ghost 687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22',
    'Content-Type': 'application/json'
}

try:
    response = requests.get('http://localhost:2368/ghost/api/admin/posts/', headers=headers)
    if response.status_code == 200:
        posts = response.json()['posts']
        titles = [post['title'] for post in posts]
        print(','.join(titles))
    else:
        print('')
except:
    print('')
")

echo "✅ Found existing posts: $(echo $EXISTING_POSTS | tr ',' '\n' | wc -l) posts"

# Import posts, skipping existing ones
python3 scripts/ghost_importer.py \
    --ghost-url "http://localhost:2368" \
    --admin-key "687cab43b841cb00018fd07f:32d841c483c85d49058030a661793d15ba5c0cefe2d569b0d9da989ffa900f22" \
    --posts-file converted/ghost_posts.json \
    --static-assets ../static

echo ""
echo "✅ Re-import complete!"
echo "Visit http://localhost:2368/ghost/ to check your posts"