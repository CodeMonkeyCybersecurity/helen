#!/bin/bash
# Deployment script for Ghost theme

set -e

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: ./deploy.sh [staging|production]"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
    echo "Error: Environment must be 'staging' or 'production'"
    exit 1
fi

echo "🚀 Deploying to $ENVIRONMENT"

# Build theme
echo "🔨 Building theme..."
./build.sh

# Get Git commit hash for versioning
VERSION=$(git rev-parse --short HEAD)
echo "📌 Version: $VERSION"

# Upload to S3 (example - adjust for your storage)
if command -v aws &> /dev/null; then
    echo "📤 Uploading to S3..."
    BUCKET="cybermonkey-artifacts"
    aws s3 cp cybermonkey-ghost-theme.zip "s3://$BUCKET/ghost-themes/$VERSION/cybermonkey-ghost-theme.zip"
    THEME_URL="https://$BUCKET.s3.amazonaws.com/ghost-themes/$VERSION/cybermonkey-ghost-theme.zip"
else
    echo "⚠️  AWS CLI not found. Please upload theme manually."
    echo "Enter theme URL: "
    read THEME_URL
fi

# Deploy with Nomad
if command -v nomad &> /dev/null; then
    echo "🔧 Deploying with Nomad..."
    
    # Set Nomad environment
    if [ "$ENVIRONMENT" == "staging" ]; then
        export NOMAD_ADDR=${NOMAD_ADDR_STAGING}
        export NOMAD_TOKEN=${NOMAD_TOKEN_STAGING}
        GHOST_CONTAINER="ghost-staging"
    else
        export NOMAD_ADDR=${NOMAD_ADDR_PROD}
        export NOMAD_TOKEN=${NOMAD_TOKEN_PROD}
        GHOST_CONTAINER="ghost-production"
    fi
    
    # Dispatch Nomad job
    nomad job dispatch ghost-theme-update \
        -meta environment="$ENVIRONMENT" \
        -meta theme_url="$THEME_URL" \
        -meta ghost_container="$GHOST_CONTAINER"
    
    echo "✅ Deployment initiated. Check Nomad UI for status."
else
    echo "⚠️  Nomad CLI not found."
    echo "Manual deployment required:"
    echo "1. Download theme from: $THEME_URL"
    echo "2. Upload via Ghost Admin UI"
fi

# Tag the release
if [ "$ENVIRONMENT" == "production" ]; then
    echo "🏷️  Creating release tag..."
    TAG="v$(date +%Y%m%d)-$VERSION"
    git tag -a "$TAG" -m "Production release $TAG"
    echo "📌 Tagged as: $TAG"
    echo "Don't forget to push tags: git push origin $TAG"
fi

echo "🎉 Deployment complete!"