#!/bin/bash

# Raspberry Pi 5 Gaming Kiosk Setup Script
# This script sets up a kiosk mode that boots directly to Steam Big Picture with GeForce Now integration
# Run this script on a fresh Raspberry Pi OS Desktop installation

set -e

echo "=========================================="
echo "Raspberry Pi 5 Gaming Kiosk Setup"
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

# Install required packages
print_status "Installing required packages..."
sudo apt install -y \
    chromium-browser \
    steam \
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
    firmware-brcm80211

# Enable GPU memory split for better graphics performance
print_status "Optimizing GPU settings..."
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

# Create the gaming launcher script
print_status "Creating gaming launcher script..."
sudo tee /home/$KIOSK_USER/gaming-launcher.sh > /dev/null << 'EOF'
#!/bin/bash

# Gaming Launcher Script for Raspberry Pi 5 Kiosk

# Set display
export DISPLAY=:0

# Hide cursor
unclutter -idle 1 -root &

# Function to launch GeForce Now
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
        "https://play.geforcenow.com/" &
}

# Function to launch Steam Big Picture
launch_steam() {
    steam -tenfoot -nobigpicture &
    sleep 5
    steam -shutdown &
    sleep 2
    steam -tenfoot &
}

# Create a simple menu using zenity
while true; do
    choice=$(zenity --list \
        --title="Gaming Kiosk" \
        --text="Choose your gaming platform:" \
        --radiolist \
        --column="Select" \
        --column="Platform" \
        --column="Description" \
        TRUE "GeForce Now" "Stream games from the cloud" \
        FALSE "Steam Big Picture" "Local Steam games" \
        FALSE "Exit" "Close the kiosk" \
        --width=500 \
        --height=300)

    case $choice in
        "GeForce Now")
            launch_geforce_now
            ;;
        "Steam Big Picture")
            launch_steam
            ;;
        "Exit"|"")
            break
            ;;
    esac
    
    # Wait for user to close the application before showing menu again
    sleep 5
done

# Shutdown or restart options
shutdown_choice=$(zenity --list \
    --title="System Options" \
    --text="What would you like to do?" \
    --radiolist \
    --column="Select" \
    --column="Action" \
    TRUE "Restart Kiosk" \
    FALSE "Shutdown System" \
    FALSE "Restart System" \
    --width=300 \
    --height=200)

case $shutdown_choice in
    "Shutdown System")
        sudo shutdown -h now
        ;;
    "Restart System")
        sudo reboot
        ;;
    *)
        # Restart the launcher
        exec $0
        ;;
esac
EOF

sudo chmod +x /home/$KIOSK_USER/gaming-launcher.sh
sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/gaming-launcher.sh

# Create openbox autostart for the kiosk user
print_status "Setting up Openbox autostart..."
sudo mkdir -p /home/$KIOSK_USER/.config/openbox
sudo tee /home/$KIOSK_USER/.config/openbox/autostart > /dev/null << 'EOF'
# Disable screen saver
xset s off
xset -dpms
xset s noblank

# Start PulseAudio
pulseaudio --start &

# Wait a moment for system to stabilize
sleep 3

# Launch the gaming launcher
/home/$KIOSK_USER/gaming-launcher.sh &
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

# Configure audio
print_status "Configuring audio..."
sudo tee /home/$KIOSK_USER/.asoundrc > /dev/null << 'EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF

sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/.asoundrc

# Create a GeForce Now desktop shortcut (alternative access)
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

# Set up swap file for better performance
print_status "Setting up swap file..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Optimize kernel parameters for gaming
print_status "Optimizing kernel parameters..."
sudo tee -a /etc/sysctl.conf > /dev/null << 'EOF'

# Gaming optimizations
vm.swappiness=10
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 65536 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
EOF

# Create a service to optimize CPU governor
print_status "Setting up performance optimizations..."
sudo tee /etc/systemd/system/gaming-performance.service > /dev/null << 'EOF'
[Unit]
Description=Gaming Performance Optimizations
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
ExecStart=/bin/bash -c 'echo 1 > /proc/sys/net/ipv4/tcp_fastopen'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable gaming-performance.service

# Create an emergency exit script
print_status "Creating emergency exit script..."
sudo tee /usr/local/bin/exit-kiosk > /dev/null << 'EOF'
#!/bin/bash
# Emergency exit from kiosk mode
# Press Ctrl+Alt+X to activate
pkill -f "gaming-launcher.sh"
pkill chromium-browser
pkill steam
DISPLAY=:0 lxterminal &
EOF

sudo chmod +x /usr/local/bin/exit-kiosk

# Set up hotkey for emergency exit
sudo tee -a /home/$KIOSK_USER/.config/openbox/rc.xml > /dev/null << 'EOF'
<!-- Emergency exit hotkey -->
<keybind key="C-A-x">
  <action name="Execute">
    <command>/usr/local/bin/exit-kiosk</command>
  </action>
</keybind>
EOF

print_status "Creating post-reboot optimization script..."
sudo tee /home/$KIOSK_USER/optimize-network.sh > /dev/null << 'EOF'
#!/bin/bash
# Network optimizations for gaming
sudo ethtool -K eth0 gro off 2>/dev/null || true
sudo ethtool -K eth0 gso off 2>/dev/null || true
sudo ethtool -K eth0 tso off 2>/dev/null || true
EOF

sudo chmod +x /home/$KIOSK_USER/optimize-network.sh
sudo chown $KIOSK_USER:$KIOSK_USER /home/$KIOSK_USER/optimize-network.sh

# Add to crontab for the kiosk user
(sudo -u $KIOSK_USER crontab -l 2>/dev/null; echo "@reboot /home/$KIOSK_USER/optimize-network.sh") | sudo -u $KIOSK_USER crontab -

print_status "=========================================="
print_status "Setup completed successfully!"
print_status "=========================================="
print_warning "IMPORTANT: Please reboot your Raspberry Pi to apply all changes."
print_status ""
print_status "After reboot, your Pi will:"
print_status "1. Auto-login as user '$KIOSK_USER'"
print_status "2. Show a menu to choose between GeForce Now and Steam"
print_status "3. Boot directly into gaming mode"
print_status ""
print_status "Emergency exit: Press Ctrl+Alt+X to access terminal"
print_status ""
print_status "GeForce Now tips:"
print_status "- Use wired internet connection for best performance"
print_status "- Use a good quality USB gamepad"
print_status "- Check your GeForce Now account settings for optimal streaming quality"
print_status ""
print_warning "If you experience lag with GeForce Now, try:"
print_warning "1. Lowering the stream quality in GeForce Now settings"
print_warning "2. Using a wired connection instead of Wi-Fi"
print_warning "3. Closing other network-intensive applications"

echo ""
read -p "Press Enter to continue, then reboot your system..."