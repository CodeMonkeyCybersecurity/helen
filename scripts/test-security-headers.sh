#!/bin/bash
# Test security headers for the Hugo site

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔒 Testing Security Headers"
echo "=========================="

# Start local server
echo "Starting local server..."
npm run serve &
SERVER_PID=$!
sleep 5

# Function to check header
check_header() {
    local header_name=$1
    local expected_pattern=$2
    local url="http://localhost:8080"
    
    echo -n "Checking ${header_name}... "
    
    header_value=$(curl -s -I "$url" | grep -i "^${header_name}:" | cut -d' ' -f2- | tr -d '\r\n')
    
    if [ -z "$header_value" ]; then
        echo -e "${RED}✗ Missing${NC}"
        return 1
    elif [[ "$header_value" =~ $expected_pattern ]]; then
        echo -e "${GREEN}✓ Present${NC}"
        echo "  Value: ${header_value}"
        return 0
    else
        echo -e "${YELLOW}⚠ Unexpected value${NC}"
        echo "  Value: ${header_value}"
        echo "  Expected pattern: ${expected_pattern}"
        return 1
    fi
}

# Check critical security headers
echo -e "\n${YELLOW}Critical Headers:${NC}"
check_header "X-Content-Type-Options" "nosniff"
check_header "X-Frame-Options" "DENY|SAMEORIGIN"
check_header "Content-Security-Policy" "default-src"
check_header "Strict-Transport-Security" "max-age="

# Check recommended headers
echo -e "\n${YELLOW}Recommended Headers:${NC}"
check_header "Referrer-Policy" "no-referrer|strict-origin"
check_header "Permissions-Policy" "geolocation|camera|microphone"
check_header "X-XSS-Protection" "1.*mode=block"

# Kill server
kill $SERVER_PID

echo -e "\n${GREEN}Security header test complete${NC}"