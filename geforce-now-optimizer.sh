#!/bin/bash

# GeForce Now Optimizer for Raspberry Pi 5
# This script helps optimize GeForce Now performance based on network conditions

set -e

echo "=========================================="
echo "GeForce Now Performance Optimizer"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[TIP]${NC} $1"
}

# Function to test network performance
test_network() {
    print_status "Testing network performance..."
    
    # Test ping to GeForce Now servers
    echo "Testing ping to GeForce Now servers..."
    ping -c 4 cloud.gfn.games 2>/dev/null || echo "Could not reach GeForce Now servers"
    
    # Check download speed (basic test)
    if command -v wget &> /dev/null; then
        echo "Testing download speed..."
        time wget -q --spider http://speedtest.ftp.otenet.gr/files/test100k.db
    fi
}

# Function to create optimized Chromium launcher for GeForce Now
create_optimized_launcher() {
    print_status "Creating optimized GeForce Now launcher..."
    
    cat > ~/launch-geforce-now-optimized.sh << 'EOF'
#!/bin/bash

# Optimized GeForce Now launcher for Raspberry Pi 5

# Set environment variables for better performance
export CHROMIUM_FLAGS="
--kiosk
--no-first-run
--disable-infobars
--disable-session-crashed-bubble
--disable-features=TranslateUI,VizDisplayCompositor
--disable-ipc-flooding-protection
--enable-features=VaapiVideoDecoder,VaapiVideoEncoder
--use-gl=egl
--enable-gpu-rasterization
--enable-oop-rasterization
--disable-software-rasterizer
--disable-background-timer-throttling
--disable-renderer-backgrounding
--disable-backgrounding-occluded-windows
--autoplay-policy=no-user-gesture-required
--disable-dev-shm-usage
--disable-background-networking
--disable-background-sync
--disable-client-side-phishing-detection
--disable-default-apps
--disable-extensions
--disable-hang-monitor
--disable-prompt-on-repost
--disable-sync
--disable-web-security
--no-default-browser-check
--no-pings
--aggressive-cache-discard
--memory-pressure-off
--max_old_space_size=4096
--js-flags=--max-old-space-size=4096
"

# Kill any existing Chromium processes
pkill -f chromium-browser || true
sleep 2

# Clear Chromium cache for fresh start
rm -rf ~/.cache/chromium/Default/GPUCache/
rm -rf ~/.cache/chromium/Default/CacheData/

# Set CPU governor to performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Optimize network buffers
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem="4096 131072 134217728"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728"

# Launch GeForce Now with optimized settings
chromium-browser $CHROMIUM_FLAGS "https://play.geforcenow.com/"
EOF

    chmod +x ~/launch-geforce-now-optimized.sh
    print_status "Optimized launcher created: ~/launch-geforce-now-optimized.sh"
}

# Function to create a performance monitoring script
create_performance_monitor() {
    print_status "Creating performance monitoring script..."
    
    cat > ~/monitor-gaming-performance.sh << 'EOF'
#!/bin/bash

# Performance monitoring script for gaming on Pi 5

echo "=== Raspberry Pi 5 Gaming Performance Monitor ==="
echo "Date: $(date)"
echo ""

# CPU information
echo "=== CPU Information ==="
echo "CPU Temperature: $(vcgencmd measure_temp)"
echo "CPU Frequency: $(vcgencmd measure_clock arm)"
echo "GPU Frequency: $(vcgencmd measure_clock core)"
echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo ""

# Memory usage
echo "=== Memory Usage ==="
free -h
echo ""

# Network statistics
echo "=== Network Statistics ==="
cat /proc/net/dev | grep -E "(eth0|wlan0)" | while read line; do
    echo "$line" | awk '{print "Interface: " $1 " RX Bytes: " $2 " TX Bytes: " $10}'
done
echo ""

# GPU memory
echo "=== GPU Memory ==="
echo "GPU Memory Split: $(vcgencmd get_mem gpu)"
echo ""

# Check for throttling
echo "=== Throttling Status ==="
throttle_status=$(vcgencmd get_throttled)
echo "Throttle Status: $throttle_status"
if [[ "$throttle_status" != "throttled=0x0" ]]; then
    echo "WARNING: System is being throttled!"
    echo "0x50000 = Currently throttled"
    echo "0x50005 = Currently throttled + under-voltage"
    echo "0x80008 = Soft temperature limit reached"
fi
echo ""

# Active processes related to gaming
echo "=== Gaming Processes ==="
ps aux | grep -E "(chromium|steam|geforce)" | grep -v grep
EOF

    chmod +x ~/monitor-gaming-performance.sh
    print_status "Performance monitor created: ~/monitor-gaming-performance.sh"
}

# Function to optimize system for GeForce Now
optimize_system() {
    print_status "Applying system optimizations for GeForce Now..."
    
    # Create tmpfs for better performance
    echo "Creating tmpfs for browser cache..."
    sudo mkdir -p /tmp/chromium-cache
    sudo mount -t tmpfs -o size=512M tmpfs /tmp/chromium-cache 2>/dev/null || true
    
    # Add to fstab if not already there
    if ! grep -q "chromium-cache" /etc/fstab; then
        echo "tmpfs /tmp/chromium-cache tmpfs size=512M,noatime 0 0" | sudo tee -a /etc/fstab
    fi
    
    # Optimize GPU settings
    print_status "Optimizing GPU settings..."
    if ! grep -q "gpu_mem=128" /boot/firmware/config.txt; then
        echo "gpu_mem=128" | sudo tee -a /boot/firmware/config.txt
    fi
    
    # Set up performance scaling
    print_status "Setting up performance scaling..."
    echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
    
    # Create udev rule for input lag reduction
    print_status "Creating udev rule for input lag reduction..."
    sudo tee /etc/udev/rules.d/99-input-gaming.rules > /dev/null << 'EOF'
# Reduce input lag for gaming peripherals
SUBSYSTEM=="input", ATTRS{name}=="*mouse*", RUN+="/bin/sh -c 'echo 1000 > /sys/class/input/%k/device/poll_msecs'"
SUBSYSTEM=="input", ATTRS{name}=="*gamepad*", RUN+="/bin/sh -c 'echo 1000 > /sys/class/input/%k/device/poll_msecs'"
SUBSYSTEM=="input", ATTRS{name}=="*joystick*", RUN+="/bin/sh -c 'echo 1000 > /sys/class/input/%k/device/poll_msecs'"
EOF
}

# Function to create troubleshooting guide
create_troubleshooting_guide() {
    print_status "Creating troubleshooting guide..."
    
    cat > ~/geforce-now-troubleshooting.md << 'EOF'
# GeForce Now Troubleshooting Guide for Raspberry Pi 5

## Common Issues and Solutions

### 1. Input Lag / Mouse Lag
**Symptoms:** Mouse cursor or keyboard input feels delayed
**Solutions:**
- Use a wired mouse and keyboard instead of wireless
- Try different USB ports (USB 3.0 ports preferred)
- Run: `sudo sh -c 'echo 1000 > /sys/class/input/*/poll'`
- Check if other applications are using CPU/network

### 2. Video Stuttering / Choppy Playback
**Symptoms:** Video is not smooth, frame drops
**Solutions:**
- Lower GeForce Now quality settings (720p30 instead of 1080p60)
- Use wired ethernet instead of Wi-Fi
- Close other browser tabs and applications
- Check network bandwidth: run speed test
- Ensure good ventilation to prevent thermal throttling

### 3. Audio Issues
**Symptoms:** No audio or distorted audio
**Solutions:**
- Check PulseAudio: `pulseaudio --check -v`
- Restart audio: `pulseaudio -k && pulseaudio --start`
- Set correct audio output in GeForce Now settings
- Try: `sudo alsa force-reload`

### 4. Connection Issues
**Symptoms:** Cannot connect to GeForce Now
**Solutions:**
- Check internet connection
- Try different DNS servers (8.8.8.8, 1.1.1.1)
- Disable VPN if running
- Check firewall settings
- Clear browser cache and cookies

### 5. Performance Optimization Commands

```bash
# Check system performance
~/monitor-gaming-performance.sh

# Optimize network for gaming
sudo ethtool -K eth0 gro off gso off tso off

# Set CPU to performance mode
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Clear caches
sudo sync && sudo sysctl vm.drop_caches=3

# Check for throttling
vcgencmd get_throttled
```

### 6. Emergency Commands

```bash
# Kill all gaming processes
pkill -f chromium-browser
pkill steam

# Reset network
sudo systemctl restart networking

# Check system temperature
vcgencmd measure_temp

# Free up memory
sudo sync && sudo sysctl vm.drop_caches=3
```

## GeForce Now Quality Settings Recommendations

### For stable connection (minimal lag):
- Resolution: 720p
- FPS: 30
- Bitrate: Automatic

### For best quality (good connection required):
- Resolution: 1080p
- FPS: 60
- Bitrate: Manual (adjust based on connection)

## Network Requirements
- Minimum: 15 Mbps download
- Recommended: 25+ Mbps download
- Latency: <40ms to GeForce Now servers
- Packet loss: <1%
EOF

    print_status "Troubleshooting guide created: ~/geforce-now-troubleshooting.md"
}

# Main menu
main_menu() {
    while true; do
        echo ""
        echo "=========================================="
        echo "GeForce Now Optimizer Menu"
        echo "=========================================="
        echo "1. Test Network Performance"
        echo "2. Create Optimized Launcher"
        echo "3. Create Performance Monitor"
        echo "4. Apply System Optimizations"
        echo "5. Create Troubleshooting Guide"
        echo "6. Run All Optimizations"
        echo "7. Exit"
        echo ""
        read -p "Choose an option (1-7): " choice
        
        case $choice in
            1)
                test_network
                ;;
            2)
                create_optimized_launcher
                ;;
            3)
                create_performance_monitor
                ;;
            4)
                optimize_system
                ;;
            5)
                create_troubleshooting_guide
                ;;
            6)
                print_status "Running all optimizations..."
                create_optimized_launcher
                create_performance_monitor
                optimize_system
                create_troubleshooting_guide
                test_network
                print_status "All optimizations completed!"
                ;;
            7)
                print_status "Exiting optimizer. Happy gaming!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-7."
                ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user (not root)"
    exit 1
fi

# Start main menu
main_menu