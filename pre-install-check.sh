#!/bin/bash

# Pre-installation Check Script for GeForce NOW Kiosk
# Run this before installing to verify your system is ready

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "   GeForce NOW Kiosk Pre-Installation Check"
    echo "=============================================="
    echo -e "${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC} $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARN${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ INFO${NC} $1"
}

check_raspberry_pi() {
    echo
    echo "=== Hardware Check ==="
    
    if grep -q "Raspberry Pi" /proc/cpuinfo; then
        local model=$(grep "Model" /proc/cpuinfo | cut -d: -f2 | xargs)
        print_pass "Running on: $model"
        
        if grep -q "Raspberry Pi 5" /proc/cpuinfo; then
            print_pass "Raspberry Pi 5 detected (optimal)"
        elif grep -q "Raspberry Pi 4" /proc/cpuinfo; then
            print_warn "Raspberry Pi 4 detected (should work but Pi 5 is recommended)"
        else
            print_warn "Older Raspberry Pi detected (may have performance issues)"
        fi
    else
        print_fail "Not running on a Raspberry Pi"
    fi
}

check_os() {
    echo
    echo "=== Operating System Check ==="
    
    if [ -f /etc/os-release ]; then
        local os_name=$(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
        print_pass "OS: $os_name"
        
        if grep -q "Raspberry Pi OS" /etc/os-release; then
            print_pass "Official Raspberry Pi OS detected"
        else
            print_warn "Non-official OS detected (may work but not tested)"
        fi
    else
        print_fail "Cannot determine OS version"
    fi
    
    # Check for desktop environment
    if pgrep -x "lxpanel" > /dev/null || pgrep -x "lxsession" > /dev/null; then
        print_pass "Desktop environment running"
    elif [ "$XDG_CURRENT_DESKTOP" ]; then
        print_pass "Desktop environment: $XDG_CURRENT_DESKTOP"
    else
        print_fail "No desktop environment detected (desktop version required)"
    fi
}

check_memory() {
    echo
    echo "=== Memory Check ==="
    
    local total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_mb=$((total_mem / 1024))
    
    print_info "Total RAM: ${total_mb}MB"
    
    if [ $total_mb -ge 4096 ]; then
        print_pass "Sufficient RAM (${total_mb}MB >= 4GB)"
    elif [ $total_mb -ge 2048 ]; then
        print_warn "Limited RAM (${total_mb}MB) - may affect performance"
    else
        print_fail "Insufficient RAM (${total_mb}MB < 2GB minimum)"
    fi
    
    # Check GPU memory split
    if command -v vcgencmd > /dev/null; then
        local gpu_mem=$(vcgencmd get_mem gpu | cut -d= -f2 | sed 's/M//')
        print_info "GPU Memory: ${gpu_mem}MB"
        
        if [ $gpu_mem -ge 128 ]; then
            print_pass "Good GPU memory allocation (${gpu_mem}MB)"
        else
            print_warn "Low GPU memory (${gpu_mem}MB) - will be increased during setup"
        fi
    fi
}

check_storage() {
    echo
    echo "=== Storage Check ==="
    
    local root_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    local root_avail=$(df -h / | awk 'NR==2 {print $4}')
    
    print_info "Root filesystem usage: ${root_usage}%"
    print_info "Available space: $root_avail"
    
    if [ $root_usage -lt 80 ]; then
        print_pass "Sufficient free space"
    else
        print_warn "Limited free space (${root_usage}% used)"
    fi
    
    # Check if running from SSD
    local root_device=$(df / | awk 'NR==2 {print $1}')
    if echo "$root_device" | grep -q "nvme\|sda"; then
        print_pass "Running from SSD/NVMe (optimal performance)"
    elif echo "$root_device" | grep -q "mmcblk"; then
        print_warn "Running from SD card (SSD recommended for better performance)"
    else
        print_info "Storage type: $root_device"
    fi
}

check_network() {
    echo
    echo "=== Network Check ==="
    
    if ping -c 1 -W 5 google.com > /dev/null 2>&1; then
        print_pass "Internet connectivity"
    else
        print_fail "No internet connection"
        return
    fi
    
    if ping -c 1 -W 5 play.geforcenow.com > /dev/null 2>&1; then
        print_pass "GeForce NOW servers reachable"
    else
        print_warn "Cannot reach GeForce NOW servers (may be temporary)"
    fi
    
    # Check connection type
    if ip route | grep -q "eth0"; then
        print_pass "Ethernet connection detected (optimal for streaming)"
    elif ip route | grep -q "wlan0"; then
        print_warn "Wi-Fi connection detected (Ethernet recommended for stability)"
    fi
    
    # Simple bandwidth test
    print_info "Testing download speed..."
    if command -v curl > /dev/null; then
        local speed=$(curl -o /dev/null -s -w '%{speed_download}' http://speedtest.tele2.net/10MB.zip 2>/dev/null || echo "0")
        local speed_mbps=$(echo "scale=1; $speed * 8 / 1000000" | bc 2>/dev/null || echo "0")
        
        if (( $(echo "$speed_mbps > 25" | bc -l 2>/dev/null || echo "0") )); then
            print_pass "Good internet speed (${speed_mbps} Mbps)"
        elif (( $(echo "$speed_mbps > 10" | bc -l 2>/dev/null || echo "0") )); then
            print_warn "Moderate internet speed (${speed_mbps} Mbps)"
        else
            print_warn "Internet speed test failed or slow connection"
        fi
    fi
}

check_audio() {
    echo
    echo "=== Audio Check ==="
    
    if [ -d /proc/asound ]; then
        print_pass "ALSA audio system present"
        
        local audio_cards=$(aplay -l 2>/dev/null | grep "^card" | wc -l)
        if [ $audio_cards -gt 0 ]; then
            print_pass "Audio devices detected ($audio_cards)"
        else
            print_warn "No audio devices found"
        fi
    else
        print_fail "No audio system detected"
    fi
    
    if command -v pulseaudio > /dev/null; then
        print_pass "PulseAudio available"
    else
        print_info "PulseAudio not installed (will be installed during setup)"
    fi
}

check_gpu() {
    echo
    echo "=== Graphics Check ==="
    
    if command -v vcgencmd > /dev/null; then
        local temp=$(vcgencmd measure_temp | cut -d= -f2 | sed 's/°C//')
        print_info "GPU temperature: ${temp}°C"
        
        if (( $(echo "$temp < 70" | bc -l 2>/dev/null || echo "1") )); then
            print_pass "GPU temperature normal"
        else
            print_warn "GPU running hot (${temp}°C) - ensure adequate cooling"
        fi
    fi
    
    # Check for hardware acceleration
    if grep -q "vc4-kms-v3d" /boot/firmware/config.txt 2>/dev/null || grep -q "vc4-kms-v3d" /boot/config.txt 2>/dev/null; then
        print_pass "Hardware acceleration enabled"
    else
        print_warn "Hardware acceleration not enabled (will be configured during setup)"
    fi
}

check_packages() {
    echo
    echo "=== Software Check ==="
    
    local packages=("curl" "wget" "git" "systemctl")
    
    for package in "${packages[@]}"; do
        if command -v $package > /dev/null; then
            print_pass "$package available"
        else
            print_warn "$package not found (will be installed if needed)"
        fi
    done
    
    # Check for Chromium
    if command -v chromium-browser > /dev/null; then
        local version=$(chromium-browser --version 2>/dev/null | cut -d' ' -f2)
        print_pass "Chromium browser available (version $version)"
    else
        print_info "Chromium browser not installed (will be installed during setup)"
    fi
}

check_permissions() {
    echo
    echo "=== Permissions Check ==="
    
    if [ "$EUID" -eq 0 ]; then
        print_fail "Running as root (should run as regular user)"
    else
        print_pass "Running as regular user ($USER)"
    fi
    
    if groups $USER | grep -q "sudo"; then
        print_pass "User has sudo privileges"
    else
        print_fail "User lacks sudo privileges (required for installation)"
    fi
    
    if [ -w "$HOME" ]; then
        print_pass "Home directory writable"
    else
        print_fail "Cannot write to home directory"
    fi
}

generate_report() {
    echo
    echo "=============================================="
    echo "                   SUMMARY"
    echo "=============================================="
    echo -e "${GREEN}Passed: $PASSED${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "${RED}Failed: $FAILED${NC}"
    echo
    
    if [ $FAILED -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            echo -e "${GREEN}🎉 EXCELLENT!${NC} Your system is fully ready for GeForce NOW kiosk setup."
            echo "You can proceed with the installation immediately."
        else
            echo -e "${YELLOW}✅ GOOD!${NC} Your system should work but has some warnings."
            echo "Review the warnings above - most can be ignored or will be fixed during setup."
        fi
        echo
        echo "Ready to install? Run:"
        echo -e "${BLUE}./setup-geforce-now-kiosk.sh${NC}"
    else
        echo -e "${RED}❌ ISSUES FOUND!${NC} Please address the failed checks before installation."
        echo
        echo "Common fixes:"
        echo "- Ensure you're running Raspberry Pi OS Desktop edition"
        echo "- Make sure you have internet connectivity"
        echo "- Run as the 'pi' user, not root"
        echo "- Ensure adequate free space and memory"
    fi
    
    echo
    echo "For help and troubleshooting:"
    echo "- Read the full README.md"
    echo "- Check the QUICKSTART.md guide"
    echo "- Report issues at: https://github.com/yourusername/ki/issues"
}

main() {
    print_header
    
    check_raspberry_pi
    check_os
    check_memory
    check_storage
    check_network
    check_audio
    check_gpu
    check_packages
    check_permissions
    
    generate_report
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "GeForce NOW Kiosk Pre-Installation Checker"
        echo ""
        echo "Usage: $0 [--help]"
        echo ""
        echo "This script checks if your Raspberry Pi is ready for"
        echo "the GeForce NOW kiosk installation."
        echo ""
        echo "It verifies:"
        echo "  - Hardware compatibility"
        echo "  - Operating system requirements"
        echo "  - Network connectivity"
        echo "  - Available resources"
        echo "  - Required permissions"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac