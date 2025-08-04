#!/bin/bash

# Raspberry Pi 5 GeForce NOW Kiosk Setup Script (GeForce NOW Only)
# This script sets up a minimal kiosk mode specifically for GeForce NOW cloud gaming
# No Steam installation - pure GeForce NOW focus for maximum simplicity
# Run this script on a fresh Raspberry Pi OS Desktop installation

set -e

echo "=========================================="
echo "Raspberry Pi 5 GeForce NOW Kiosk (Pure)"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a normal user (not root)"
    exit 1
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install only required packages for GeForce NOW
print_status "Installing GeForce NOW essentials..."
sudo apt install -y \
    chromium-browser \
    xinit \
    xorg \
    openbox \
    lightdm \
    unclutter \
    xdotool \
    wmctrl \
    pulseaudio \
    pulseaudio-utils \
    alsa-utils \
    xserver-xorg-video-all \
    firmware-brcm80211 \
    zenity

# Enable GPU memory split for better graphics performance
print_status "Optimizing GPU settings for cloud gaming..."
echo "gpu_mem=128" | sudo tee -a /boot/firmware/config.txt
echo "hdmi_force_hotplug=1" | sudo tee -a /boot/firmware/config.txt
echo "hdmi_group=1" | sudo tee -a /boot/firmware/config.txt
echo "hdmi_mode=16" | sudo tee -a /boot/firmware/config.txt

# Create kiosk user if it doesn't exist
KIOSK_USER="gamer"
if ! id "$KIOSK_USER" &>/dev/null; then
    print_status "Creating kiosk user: $KIOSK_USER"
    sudo adduser --disabled-password --gecos "" $KIOSK_USER
    sudo usermod -a -G audio,video,input,dialout,plugdev,users $KIOSK_USER
fi

# Create the GeForce NOW launcher script
print_status "Creating GeForce NOW launcher..."
sudo tee /home/$KIOSK_USER/geforce-now-launcher.sh > /dev/null << 'EOF'
#!/bin/bash

# GeForce NOW Launcher Script for Raspberry Pi 5 Kiosk

# Set display
export DISPLAY=:0

# Hide cursor
unclutter -idle 1 -root &

# Function to launch GeForce Now with optimal settings
launch_geforce_now() {
    chromium-browser \
        --kiosk \
        --no-first-run \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --disable-features=TranslateUI \
        --disable-ipc-flooding-protection \
        --enable-features=VaapiVideoDecoder \
        --use-gl=egl \
        --enable-gpu-rasterization \
        --enable-oop-rasterization \
        --disable-software-rasterizer \
        --disable-background-timer-throttling \
        --disable-renderer-backgrounding \
        --disable-backgrounding-occluded-windows \
        --autoplay-policy=no-user-gesture-required \
        --disable-web-security \
        --disable-features=VizDisplayCompositor \
        "https://play.geforcenow.com/" &
}

# Welcome dialog
zenity --info \
    --title="GeForce NOW Gaming Kiosk" \
    --text="🎮 Welcome to your Raspberry Pi 5 GeForce NOW Gaming Station!\n\n✅ Optimized for cloud gaming\n⚡ Hardware acceleration enabled\n🔧 Performance optimized\n\nPress OK to launch GeForce NOW!" \
    --width=400

# Launch GeForce NOW
launch_geforce_now

# Wait for GeForce NOW to close, then show options
while pgrep chromium-browser > /dev/null; do
    sleep 5
done

# Shutdown options
shutdown_choice=$(zenity --list \
    --title="Session Complete" \
    --text="What would you like to do?" \
    --radiolist \
    --column="Select" \
    --column="Action" \
    TRUE "Restart GeForce NOW" \
    FALSE "Shutdown System" \
    FALSE "Restart System" \
    --width=350 \
    --height=250)

case $shutdown_choice in
    "Shutdown System")
        sudo shutdown -h now
        ;;
    "Restart System")
        sudo reboot
        ;;
    *)
        # Restart GeForce NOW
        exec $0
        ;;
esac
EOF

sudo chmod +x /home/$KIOSK_USER/geforce-now-launcher.sh
sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/geforce-now-launcher.sh

# Create openbox autostart for the kiosk user
print_status "Setting up auto-start configuration..."
sudo mkdir -p /home/$KIOSK_USER/.config/openbox
sudo tee /home/$KIOSK_USER/.config/openbox/autostart > /dev/null << 'EOF'
# Disable screen saver
xset s off
xset -dpms
xset s noblank

# Start PulseAudio
pulseaudio --start &

# Set CPU to performance mode
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Wait a moment for system to stabilize
sleep 3

# Launch GeForce NOW
/home/$KIOSK_USER/geforce-now-launcher.sh &
EOF

sudo chown -R $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/.config

# Configure LightDM for auto-login
print_status "Configuring auto-login..."
sudo tee /etc/lightdm/lightdm.conf > /dev/null << EOF
[Seat:*]
autologin-user=$KIOSK_USER
autologin-user-timeout=0
user-session=openbox
greeter-session=pi-greeter
EOF

# Create .xinitrc for the kiosk user
sudo tee /home/$KIOSK_USER/.xinitrc > /dev/null << 'EOF'
#!/bin/bash
exec openbox-session
EOF

sudo chmod +x /home/$KIOSK_USER/.xinitrc
sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/.xinitrc

# Configure audio for optimal gaming
print_status "Configuring audio for gaming..."
sudo tee /home/$KIOSK_USER/.asoundrc > /dev/null << 'EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF

sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/.asoundrc

# Create a GeForce Now desktop shortcut
print_status "Creating desktop shortcuts..."
sudo mkdir -p /home/$KIOSK_USER/Desktop
sudo tee /home/$KIOSK_USER/Desktop/GeForceNow.desktop > /dev/null << 'EOF'
[Desktop Entry]
Type=Application
Name=GeForce Now
Comment=Cloud Gaming Service
Exec=chromium-browser --app=https://play.geforcenow.com/
Icon=applications-games
Categories=Game;
EOF

sudo chmod +x /home/$KIOSK_USER/Desktop/GeForceNow.desktop
sudo chown -R $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/Desktop

# Enable necessary services
print_status "Enabling services..."
sudo systemctl enable lightdm

# Set up optimized swap file
print_status "Setting up optimized swap for gaming..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Optimize kernel parameters specifically for cloud gaming
print_status "Optimizing system for cloud gaming..."
sudo tee -a /etc/sysctl.conf > /dev/null << 'EOF'

# GeForce NOW cloud gaming optimizations
vm.swappiness=10
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 131072 16777216
net.ipv4.tcp_wmem=4096 131072 16777216
net.core.netdev_max_backlog=30000
net.ipv4.tcp_fastopen=3
EOF

# Create a service for gaming optimizations
print_status "Setting up performance service..."
sudo tee /etc/systemd/system/geforce-now-optimizations.service > /dev/null << 'EOF'
[Unit]
Description=GeForce NOW Gaming Optimizations
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
ExecStart=/bin/bash -c 'echo 1 > /proc/sys/net/ipv4/tcp_fastopen'
ExecStart=/bin/bash -c 'ethtool -K eth0 gro off gso off tso off 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable geforce-now-optimizations.service

# Create an emergency exit script
print_status "Creating emergency exit..."
sudo tee /usr/local/bin/exit-kiosk > /dev/null << 'EOF'
#!/bin/bash
# Emergency exit from kiosk mode
# Press Ctrl+Alt+X to activate
pkill -f "geforce-now-launcher.sh"
pkill chromium-browser
DISPLAY=:0 lxterminal &
EOF

sudo chmod +x /usr/local/bin/exit-kiosk

# Set up hotkey for emergency exit
sudo tee /home/$KIOSK_USER/.config/openbox/rc.xml > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <keyboard>
    <!-- Emergency exit hotkey -->
    <keybind key="C-A-x">
      <action name="Execute">
        <command>/usr/local/bin/exit-kiosk</command>
      </action>
    </keybind>
  </keyboard>
</openbox_config>
EOF

sudo chown -R $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/.config

print_status "=========================================="
print_status "🎮 GeForce NOW Kiosk Setup Complete!"
print_status "=========================================="
print_warning "IMPORTANT: Please reboot your Raspberry Pi to start gaming!"
print_status ""
print_status "🚀 After reboot, your Pi will:"
print_status "✅ Auto-login and launch GeForce NOW directly"
print_status "🎯 Boot straight to cloud gaming"
print_status "⚡ Run with maximum performance optimizations"
print_status ""
print_status "🎮 GeForce NOW Pro Tips:"
print_status "🌐 ESSENTIAL: Use wired Ethernet (not Wi-Fi)"
print_status "🎯 Start with 720p30 for stable performance"
print_status "🕹️  Use quality USB gamepad for best response"
print_status "📶 Recommended: 25+ Mbps internet speed"
print_status ""
print_status "🔧 Emergency access: Press Ctrl+Alt+X for terminal"
print_status ""
print_warning "⚡ For advanced optimizations, run the optimizer script after reboot:"
print_status "wget https://raw.githubusercontent.com/WonderBoyHub/rpi-steam/main/geforce-now-optimizer.sh && chmod +x geforce-now-optimizer.sh && ./geforce-now-optimizer.sh"

echo ""
read -p "🎮 Press Enter to continue, then reboot to start gaming! 🎮"