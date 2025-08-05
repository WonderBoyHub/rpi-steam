#!/bin/bash

# Quick installer for GeForce NOW Kiosk setup
# This script downloads and runs the main setup script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_URL="https://raw.githubusercontent.com/yourusername/ki/main/setup-geforce-now-kiosk.sh"
SCRIPT_NAME="setup-geforce-now-kiosk.sh"

print_header() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "   GeForce NOW Kiosk Quick Installer"
    echo "=============================================="
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    # Check if running on Raspberry Pi
    if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
        echo -e "${YELLOW}[WARNING]${NC} This doesn't appear to be a Raspberry Pi"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # Check for internet connection
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "No internet connection detected. Please connect to the internet and try again."
        exit 1
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        print_status "Installing curl..."
        sudo apt update && sudo apt install -y curl
    fi
}

download_and_run() {
    print_status "Downloading setup script..."
    
    # Download the script
    if curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_NAME"; then
        print_status "Download successful!"
    else
        print_error "Failed to download setup script. Please check your internet connection."
        exit 1
    fi
    
    # Make executable
    chmod +x "$SCRIPT_NAME"
    
    print_status "Starting GeForce NOW kiosk setup..."
    echo
    
    # Run the main setup script
    ./"$SCRIPT_NAME"
}

main() {
    print_header
    
    print_status "Preparing to install GeForce NOW kiosk on your Raspberry Pi..."
    echo
    
    check_requirements
    download_and_run
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "GeForce NOW Kiosk Quick Installer"
        echo ""
        echo "Usage: $0 [--help]"
        echo ""
        echo "This script downloads and runs the GeForce NOW kiosk setup"
        echo "for Raspberry Pi 5. No additional arguments are required."
        echo ""
        echo "The setup will:"
        echo "  - Configure your Pi to boot directly into GeForce NOW"
        echo "  - Optimize system performance for game streaming"
        echo "  - Create management tools for the kiosk"
        echo ""
        echo "For more information, visit:"
        echo "https://github.com/yourusername/ki"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac