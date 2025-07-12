#!/bin/bash
# Comprehensive test runner for Code Monkey Cybersecurity website

set -e # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
PASSED=0
FAILED=0
WARNINGS=0

# Function to run a test and track results
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "\n${YELLOW}Running: ${test_name}${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ ${test_name} passed${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ ${test_name} failed${NC}"
        ((FAILED++))
    fi
}

# Function to run a test that may have warnings
run_test_with_warnings() {
    local test_name=$1
    local test_command=$2
    
    echo -e "\n${YELLOW}Running: ${test_name}${NC}"
    
    set +e # Don't exit on error for this test
    eval "$test_command"
    local exit_code=$?
    set -e
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ ${test_name} passed${NC}"
        ((PASSED++))
    elif [ $exit_code -eq 1 ]; then
        echo -e "${YELLOW}⚠ ${test_name} has warnings${NC}"
        ((WARNINGS++))
    else
        echo -e "${RED}✗ ${test_name} failed${NC}"
        ((FAILED++))
    fi
}

echo "🔍 Code Monkey Cybersecurity - Comprehensive Test Suite"
echo "======================================================"

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed${NC}"
    exit 1
fi

if ! command -v hugo &> /dev/null; then
    echo -e "${RED}Hugo is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "\n${YELLOW}Installing dependencies...${NC}"
    npm ci
fi

# 1. Linting Tests
echo -e "\n${YELLOW}=== LINTING TESTS ===${NC}"

run_test "JavaScript Linting" "npm run lint:js"
run_test "CSS/SCSS Linting" "npm run lint:css"

# 2. Build Tests
echo -e "\n${YELLOW}=== BUILD TESTS ===${NC}"

run_test "Hugo Build (Production)" "hugo --minify --environment production"
run_test "Asset Pipeline" "npm run build:css && npm run build:js"

# 3. HTML Validation (requires built site)
echo -e "\n${YELLOW}=== HTML VALIDATION ===${NC}"

run_test "HTML Validation" "npm run lint:html"

# 4. Security Tests
echo -e "\n${YELLOW}=== SECURITY TESTS ===${NC}"

run_test_with_warnings "NPM Audit" "npm audit --audit-level=high"
run_test "Dependency Check" "npm run test:deps"

# 5. Link Checking
echo -e "\n${YELLOW}=== LINK CHECKING ===${NC}"

run_test_with_warnings "Markdown Links" "npx markdown-link-check ./content/**/*.md"

# 6. Accessibility Tests
echo -e "\n${YELLOW}=== ACCESSIBILITY TESTS ===${NC}"

# Start a local server for accessibility testing
echo "Starting local server for accessibility tests..."
npm run serve &
SERVER_PID=$!
sleep 5

run_test_with_warnings "Axe Accessibility" "npx axe http://localhost:8080 --config .axe.json"

# Kill the server
kill $SERVER_PID

# 7. Performance Tests (optional, takes longer)
if [ "$1" == "--full" ]; then
    echo -e "\n${YELLOW}=== PERFORMANCE TESTS ===${NC}"
    
    npm run serve &
    SERVER_PID=$!
    sleep 5
    
    run_test_with_warnings "Lighthouse Performance" "npx lighthouse http://localhost:8080 --output json --output-path ./lighthouse-report.json --only-categories=performance,accessibility,best-practices,seo"
    
    kill $SERVER_PID
fi

# 8. Go Module Tests
echo -e "\n${YELLOW}=== GO MODULE TESTS ===${NC}"

run_test "Go Module Verification" "hugo mod verify"

# Summary
echo -e "\n${YELLOW}=== TEST SUMMARY ===${NC}"
echo "======================================"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${YELLOW}Warnings: ${WARNINGS}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"
echo "======================================"

if [ $FAILED -gt 0 ]; then
    echo -e "\n${RED}❌ Test suite failed with ${FAILED} errors${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "\n${YELLOW}⚠️  Test suite completed with ${WARNINGS} warnings${NC}"
    exit 0
else
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
    exit 0
fi