#!/bin/bash

# Automatic Dependency Update Script for Hugo Project
# Code Monkey Cybersecurity - Helen Website
# This script updates all dependencies: Hugo modules, npm packages, and Git submodules

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
BACKUP_DIR="$PROJECT_DIR/.dependency-backups"
LOG_FILE="$PROJECT_DIR/dependency-update.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to create backup
create_backup() {
    print_status "Creating backup of dependency files..."
    
    mkdir -p "$BACKUP_DIR/$TIMESTAMP"
    
    # Backup key files
    if [[ -f "$PROJECT_DIR/go.mod" ]]; then
        cp "$PROJECT_DIR/go.mod" "$BACKUP_DIR/$TIMESTAMP/go.mod.bak"
    fi
    
    if [[ -f "$PROJECT_DIR/go.sum" ]]; then
        cp "$PROJECT_DIR/go.sum" "$BACKUP_DIR/$TIMESTAMP/go.sum.bak"
    fi
    
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        cp "$PROJECT_DIR/package.json" "$BACKUP_DIR/$TIMESTAMP/package.json.bak"
    fi
    
    if [[ -f "$PROJECT_DIR/package-lock.json" ]]; then
        cp "$PROJECT_DIR/package-lock.json" "$BACKUP_DIR/$TIMESTAMP/package-lock.json.bak"
    fi
    
    print_success "Backup created at $BACKUP_DIR/$TIMESTAMP"
}

# Function to restore backup
restore_backup() {
    if [[ -d "$BACKUP_DIR/$TIMESTAMP" ]]; then
        print_warning "Restoring backup from $BACKUP_DIR/$TIMESTAMP"
        
        if [[ -f "$BACKUP_DIR/$TIMESTAMP/go.mod.bak" ]]; then
            cp "$BACKUP_DIR/$TIMESTAMP/go.mod.bak" "$PROJECT_DIR/go.mod"
        fi
        
        if [[ -f "$BACKUP_DIR/$TIMESTAMP/go.sum.bak" ]]; then
            cp "$BACKUP_DIR/$TIMESTAMP/go.sum.bak" "$PROJECT_DIR/go.sum"
        fi
        
        if [[ -f "$BACKUP_DIR/$TIMESTAMP/package.json.bak" ]]; then
            cp "$BACKUP_DIR/$TIMESTAMP/package.json.bak" "$PROJECT_DIR/package.json"
        fi
        
        if [[ -f "$BACKUP_DIR/$TIMESTAMP/package-lock.json.bak" ]]; then
            cp "$BACKUP_DIR/$TIMESTAMP/package-lock.json.bak" "$PROJECT_DIR/package-lock.json"
        fi
        
        print_success "Backup restored"
    else
        print_error "No backup found to restore"
    fi
}

# Function to check if commands exist
check_dependencies() {
    print_status "Checking required tools..."
    
    local missing_tools=()
    
    if ! command -v hugo &> /dev/null; then
        missing_tools+=("hugo")
    fi
    
    if ! command -v go &> /dev/null; then
        missing_tools+=("go")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_error "Please install these tools before running the script"
        exit 1
    fi
    
    print_success "All required tools are available"
}

# Function to update Hugo modules
update_hugo_modules() {
    print_status "Updating Hugo modules..."
    
    if [[ -f "$PROJECT_DIR/go.mod" ]]; then
        cd "$PROJECT_DIR"
        
        # Check for updates
        print_status "Checking for Hugo module updates..."
        if hugo mod get -u; then
            print_success "Hugo modules updated successfully"
            
            # Clean up
            if go mod tidy; then
                print_success "go.mod cleaned up"
            else
                print_warning "go mod tidy failed, but continuing..."
            fi
        else
            print_error "Hugo module update failed"
            return 1
        fi
    else
        print_warning "No go.mod file found, skipping Hugo module updates"
    fi
}

# Function to update npm packages
update_npm_packages() {
    print_status "Updating npm packages..."
    
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        cd "$PROJECT_DIR"
        
        # Check for outdated packages
        print_status "Checking for outdated npm packages..."
        npm outdated || true  # Don't fail if packages are outdated
        
        # Update packages
        if npm update; then
            print_success "npm packages updated successfully"
            
            # Optional: Update to latest versions (uncomment if desired)
            # print_status "Updating to latest package versions..."
            # npm install -g npm-check-updates
            # ncu -u
            # npm install
            
        else
            print_error "npm update failed"
            return 1
        fi
    else
        print_warning "No package.json file found, skipping npm updates"
    fi
}

# Function to update Git submodules
update_git_submodules() {
    print_status "Updating Git submodules..."
    
    if [[ -f "$PROJECT_DIR/.gitmodules" ]]; then
        cd "$PROJECT_DIR"
        
        if git submodule update --init --recursive --remote; then
            print_success "Git submodules updated successfully"
        else
            print_error "Git submodule update failed"
            return 1
        fi
    else
        print_warning "No .gitmodules file found, skipping submodule updates"
    fi
}

# Function to test build
test_build() {
    print_status "Testing build after updates..."
    
    cd "$PROJECT_DIR"
    
    # Test npm build
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        print_status "Testing npm build..."
        if npm run build-css; then
            print_success "npm build test passed"
        else
            print_error "npm build test failed"
            return 1
        fi
    fi
    
    # Test Hugo build
    print_status "Testing Hugo build..."
    if hugo --minify; then
        print_success "Hugo build test passed"
    else
        print_error "Hugo build test failed"
        return 1
    fi
}

# Function to show update summary
show_summary() {
    print_status "Update Summary:"
    echo "=================" | tee -a "$LOG_FILE"
    
    # Hugo version
    if command -v hugo &> /dev/null; then
        echo "Hugo Version: $(hugo version)" | tee -a "$LOG_FILE"
    fi
    
    # Go version
    if command -v go &> /dev/null; then
        echo "Go Version: $(go version)" | tee -a "$LOG_FILE"
    fi
    
    # Node/npm version
    if command -v node &> /dev/null; then
        echo "Node Version: $(node --version)" | tee -a "$LOG_FILE"
    fi
    
    if command -v npm &> /dev/null; then
        echo "npm Version: $(npm --version)" | tee -a "$LOG_FILE"
    fi
    
    # Show current Hugo module versions
    if [[ -f "$PROJECT_DIR/go.mod" ]]; then
        echo "" | tee -a "$LOG_FILE"
        echo "Current Hugo Modules:" | tee -a "$LOG_FILE"
        cd "$PROJECT_DIR" && go list -m all | tee -a "$LOG_FILE"
    fi
    
    # Show current npm packages
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        echo "" | tee -a "$LOG_FILE"
        echo "Current npm Packages:" | tee -a "$LOG_FILE"
        cd "$PROJECT_DIR" && npm list --depth=0 | tee -a "$LOG_FILE"
    fi
    
    echo "=================" | tee -a "$LOG_FILE"
}

# Function to clean up old backups
cleanup_old_backups() {
    print_status "Cleaning up old backups (keeping last 5)..."
    
    if [[ -d "$BACKUP_DIR" ]]; then
        cd "$BACKUP_DIR"
        # Keep only the 5 most recent backups
        ls -t | tail -n +6 | xargs -r rm -rf
        print_success "Old backups cleaned up"
    fi
}

# Trap to handle errors
trap 'print_error "Script failed! Attempting to restore backup..."; restore_backup; exit 1' ERR

# Main execution
main() {
    # Start logging
    echo "=== Dependency Update Script Started at $(date) ===" | tee "$LOG_FILE"
    
    # Check if we're in the right directory
    if [[ ! -f "$PROJECT_DIR/config.toml" ]]; then
        print_error "This doesn't appear to be a Hugo project directory"
        print_error "Please run this script from the project root"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create backup
    create_backup
    
    # Update components
    update_hugo_modules
    update_npm_packages
    update_git_submodules
    
    # Test build
    test_build
    
    # Show summary
    show_summary
    
    # Cleanup
    cleanup_old_backups
    
    print_success "All dependencies updated successfully!"
    print_status "Backup available at: $BACKUP_DIR/$TIMESTAMP"
    print_status "Log file: $LOG_FILE"
    
    echo "=== Dependency Update Script Completed at $(date) ===" | tee -a "$LOG_FILE"
}

# Usage information
usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --no-backup    Skip backup creation"
    echo "  --no-test      Skip build testing"
    echo "  --restore      Restore from latest backup"
    echo ""
    echo "This script updates:"
    echo "  - Hugo modules (go.mod)"
    echo "  - npm packages (package.json)"
    echo "  - Git submodules"
    echo ""
    echo "Example:"
    echo "  $0                    # Update all dependencies"
    echo "  $0 --no-backup       # Update without backup"
    echo "  $0 --restore          # Restore latest backup"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --no-backup)
            SKIP_BACKUP=1
            shift
            ;;
        --no-test)
            SKIP_TEST=1
            shift
            ;;
        --restore)
            # Find latest backup
            if [[ -d "$BACKUP_DIR" ]]; then
                LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -n1)
                if [[ -n "$LATEST_BACKUP" ]]; then
                    TIMESTAMP="$LATEST_BACKUP"
                    restore_backup
                    exit 0
                else
                    print_error "No backups found"
                    exit 1
                fi
            else
                print_error "No backup directory found"
                exit 1
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Run main function
main

# If we get here, everything succeeded
exit 0