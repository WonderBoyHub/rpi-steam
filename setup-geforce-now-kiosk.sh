#!/bin/bash

# GeForce NOW Kiosk Setup Script for Raspberry Pi 5
# This script sets up a Raspberry Pi to boot directly into GeForce NOW
# Optimized for M2 HAT+ SSD installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
GEFORCE_NOW_URL="https://play.geforcenow.com"
SERVICE_NAME="geforce-now-kiosk"
USER="pi"

print_header() {
    echo -e "${BLUE}"
    echo "=============================================="
    echo "   GeForce NOW Kiosk Setup for Raspberry Pi 5"
    echo "=============================================="
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as the pi user."
        exit 1
    fi
}

check_raspberry_pi() {
    if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
        print_warning "This script is designed for Raspberry Pi. Continuing anyway..."
    fi
}

load_config() {
    # Load configuration from config file if it exists
    CONFIG_FILE="./config.conf"
    if [ -f "$CONFIG_FILE" ]; then
        print_status "Loading configuration from $CONFIG_FILE..."
        source "$CONFIG_FILE"
    else
        print_status "Using default configuration (no config.conf found)"
    fi
}

update_system() {
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
}

install_packages() {
    print_status "Installing required packages..."
    
    # Essential packages for kiosk mode
    local packages=(
        "chromium-browser"
        "unclutter"
        "xdotool"
        "xinit"
        "x11-xserver-utils"
        "pulseaudio"
        "pulseaudio-utils"
        "alsa-utils"
        "firmware-misc-nonfree"
    )
    
    sudo apt install -y "${packages[@]}"
}

configure_audio() {
    print_status "Configuring audio for gaming..."
    
    # Enable audio and set default output
    sudo usermod -a -G audio $USER
    
    # Configure pulse audio for low latency
    if [ ! -f ~/.pulse/daemon.conf ]; then
        mkdir -p ~/.pulse
        cat > ~/.pulse/daemon.conf << EOF
# Low latency configuration for gaming
default-sample-rate = 48000
alternate-sample-rate = 44100
default-sample-channels = 2
default-channel-map = front-left,front-right
resample-method = speex-float-1
enable-lfe-remixing = no
high-priority = yes
nice-level = -11
realtime-scheduling = yes
realtime-priority = 5
rlimit-rtprio = 9
daemonize = no
EOF
    fi
}

configure_gpu() {
    print_status "Configuring GPU settings for optimal streaming..."
    
    # GPU memory split and video settings
    if ! grep -q "gpu_mem=" /boot/firmware/config.txt; then
        echo "gpu_mem=128" | sudo tee -a /boot/firmware/config.txt
    fi
    
    # Enable hardware acceleration
    if ! grep -q "dtoverlay=vc4-kms-v3d" /boot/firmware/config.txt; then
        echo "dtoverlay=vc4-kms-v3d" | sudo tee -a /boot/firmware/config.txt
    fi
    
    # Disable overscan for full screen
    sudo sed -i 's/#disable_overscan=1/disable_overscan=1/' /boot/firmware/config.txt
}

setup_auto_login() {
    print_status "Setting up automatic login..."
    
    # Enable auto-login via raspi-config
    sudo raspi-config nonint do_boot_behaviour B4
    
    # Ensure lightdm auto-login is configured
    sudo mkdir -p /etc/lightdm/lightdm.conf.d/
    cat << EOF | sudo tee /etc/lightdm/lightdm.conf.d/01-autologin.conf
[Seat:*]
autologin-user=$USER
user-session=LXDE-pi
EOF
}

create_launch_script() {
    print_status "Creating GeForce NOW launch script..."
    
    cat > /home/$USER/start-geforce-now.sh << EOF
#!/bin/bash

# Wait for desktop environment to load
sleep \${BOOT_WAIT:-10}

# Set display
export DISPLAY=:0

# Hide cursor
unclutter -idle 0.1 -root &

# Disable screen blanking
xset s off
xset -dpms
xset s noblank

# Set screen brightness to maximum (if supported)
echo 255 | sudo tee /sys/class/backlight/*/brightness 2>/dev/null || true

# Kill any existing Chromium processes
pkill chromium-browser || true
sleep 2

# Launch Chromium in kiosk mode with gaming optimizations
chromium-browser \
    --kiosk \
    --start-fullscreen \
    --start-maximized \
    --window-size=1920,1080 \
    --window-position=0,0 \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu-sandbox \
    --enable-features=VaapiVideoDecoder \
    --disable-features=VizDisplayCompositor \
    --enable-gpu-rasterization \
    --enable-oop-rasterization \
    --enable-raw-draw \
    --canvas-oop-rasterization \
    --enable-accelerated-2d-canvas \
    --enable-accelerated-video-decode \
    --ignore-gpu-blacklist \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-component-extensions-with-background-pages \
    --disable-extensions \
    --disable-plugins \
    --disable-print-preview \
    --disable-default-apps \
    --disable-background-networking \
    --disable-sync \
    --disable-translate \
    --disable-web-security \
    --disable-features=TranslateUI \
    --disable-ipc-flooding-protection \
    --noerrdialogs \
    --disable-infobars \
    --disable-session-crashed-bubble \
    --disable-popup-blocking \
    --force-device-scale-factor=1 \
    --autoplay-policy=no-user-gesture-required \
    --app="$GEFORCE_NOW_URL" &

# Monitor Chromium process and restart if it crashes
while true; do
    sleep 30
    if ! pgrep chromium-browser > /dev/null; then
        echo "Chromium crashed, restarting..."
        sleep \${RESTART_DELAY:-5}
        exec $0
    fi
done
EOF

    chmod +x /home/$USER/start-geforce-now.sh
}

create_systemd_service() {
    print_status "Creating systemd service for auto-start..."
    
    cat << EOF | sudo tee /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=GeForce NOW Kiosk Mode
After=graphical-session.target
Wants=graphical-session.target
Requires=multi-user.target

[Service]
Type=simple
User=$USER
Group=$USER
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/$USER/.Xauthority
Environment=HOME=/home/$USER
ExecStart=/home/$USER/start-geforce-now.sh
Restart=always
RestartSec=5
KillMode=mixed
TimeoutStopSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=graphical-session.target
EOF

    # Enable the service
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME.service
}

optimize_performance() {
    print_status "Applying performance optimizations..."
    
    # Disable unnecessary services
    local services_to_disable=(
        "bluetooth"
        "hciuart"
        "avahi-daemon"
        "triggerhappy"
        "dphys-swapfile"
    )
    
    for service in "${services_to_disable[@]}"; do
        sudo systemctl disable $service 2>/dev/null || true
    done
    
    # Configure swappiness for better performance
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    
    # Network optimizations for streaming
    cat << EOF | sudo tee -a /etc/sysctl.conf
# Network optimizations for game streaming
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
EOF
}

configure_chromium_flags() {
    print_status "Configuring Chromium for optimal streaming..."
    
    # Create Chromium config directory
    mkdir -p /home/$USER/.config/chromium/Default
    
    # Set up preferences for autoplay and hardware acceleration
    cat > /home/$USER/.config/chromium/Default/Preferences << 'EOF'
{
   "profile": {
      "default_content_setting_values": {
         "media_stream_camera": 1,
         "media_stream_mic": 1,
         "notifications": 2
      },
      "content_settings": {
         "pattern_pairs": {
            "https://play.geforcenow.com,*": {
               "media-stream": {
                  "video": 1,
                  "audio": 1
               }
            }
         }
      }
   },
   "hardware_acceleration_mode": {
      "enabled": true
   }
}
EOF
}

create_recovery_script() {
    print_status "Creating recovery/maintenance script..."
    
    cat > /home/$USER/geforce-now-control.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        sudo systemctl start geforce-now-kiosk
        ;;
    stop)
        sudo systemctl stop geforce-now-kiosk
        pkill chromium-browser
        ;;
    restart)
        sudo systemctl restart geforce-now-kiosk
        ;;
    status)
        sudo systemctl status geforce-now-kiosk
        ;;
    disable)
        sudo systemctl stop geforce-now-kiosk
        sudo systemctl disable geforce-now-kiosk
        ;;
    enable)
        sudo systemctl enable geforce-now-kiosk
        sudo systemctl start geforce-now-kiosk
        ;;
    logs)
        journalctl -u geforce-now-kiosk -f
        ;;
    desktop)
        sudo systemctl stop geforce-now-kiosk
        pkill chromium-browser
        echo "Kiosk stopped. Desktop access restored."
        echo "Run './geforce-now-control.sh start' to resume kiosk mode."
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|disable|enable|logs|desktop}"
        echo ""
        echo "Commands:"
        echo "  start    - Start GeForce NOW kiosk"
        echo "  stop     - Stop GeForce NOW kiosk"
        echo "  restart  - Restart GeForce NOW kiosk"
        echo "  status   - Show service status"
        echo "  disable  - Disable auto-start"
        echo "  enable   - Enable auto-start"
        echo "  logs     - Show live logs"
        echo "  desktop  - Access desktop (disable kiosk temporarily)"
        exit 1
        ;;
esac
EOF

    chmod +x /home/$USER/geforce-now-control.sh
}

final_setup() {
    print_status "Performing final setup..."
    
    # Set correct permissions
    sudo chown -R $USER:$USER /home/$USER/.config
    
    # Create desktop shortcut for control script
    mkdir -p /home/$USER/Desktop
    cat > /home/$USER/Desktop/GeForce-NOW-Control.desktop << EOF
[Desktop Entry]
Version=1.0
Name=GeForce NOW Control
Comment=Control GeForce NOW Kiosk
Exec=/home/$USER/geforce-now-control.sh
Icon=applications-games
Terminal=true
Type=Application
Categories=Game;
EOF
    
    chmod +x /home/$USER/Desktop/GeForce-NOW-Control.desktop
}

main() {
    print_header
    
    # Load configuration first
    load_config
    
    print_status "Starting GeForce NOW kiosk setup..."
    
    check_root
    check_raspberry_pi
    
    # Ask for confirmation
    echo -e "${YELLOW}This script will:"
    echo "  - Set up automatic login"
    echo "  - Install and configure Chromium for kiosk mode"
    echo "  - Configure system for optimal game streaming"
    echo "  - Create auto-start service for GeForce NOW"
    echo "  - Apply performance optimizations"
    echo ""
    echo "The system will reboot automatically when complete."
    echo -e "${NC}"
    
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Installation cancelled."
        exit 0
    fi
    
    update_system
    install_packages
    configure_audio
    configure_gpu
    setup_auto_login
    create_launch_script
    create_systemd_service
    optimize_performance
    configure_chromium_flags
    create_recovery_script
    final_setup
    
    print_header
    print_status "Setup complete!"
    echo ""
    echo -e "${GREEN}Your Raspberry Pi is now configured as a GeForce NOW kiosk!${NC}"
    echo ""
    echo -e "${BLUE}Important notes:${NC}"
    echo "  - The system will boot directly into GeForce NOW after reboot"
    echo "  - Use SSH or the control script to access the desktop if needed"
    echo "  - Control script: ./geforce-now-control.sh [command]"
    echo "  - To access desktop temporarily: ./geforce-now-control.sh desktop"
    echo ""
    echo -e "${YELLOW}The system will reboot in 10 seconds...${NC}"
    echo "Press Ctrl+C to cancel the reboot."
    
    sleep 10
    sudo reboot
}

# Run main function
main "$@"