#!/bin/sh

echo "Starting Hugo build process..."

# Fetch data from Directus
echo "Fetching content from Directus..."
DIRECTUS_URL="${DIRECTUS_URL:-http://directus:8055}"

# Create data directory
mkdir -p /src/data

# Fetch collections we need
collections="posts pages resources team_members services"

for collection in $collections; do
    echo "Fetching $collection..."
    curl -H "Authorization: Bearer ${DIRECTUS_TOKEN}" \
         "${DIRECTUS_URL}/items/${collection}?limit=-1" \
         -o "/src/data/${collection}.json"
done

# Build Hugo site
echo "Building Hugo site..."
cd /src
hugo --minify --destination=/public

echo "Build complete!"