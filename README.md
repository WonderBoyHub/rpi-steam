# GeForce NOW Kiosk for Raspberry Pi 5

This script transforms your Raspberry Pi 5 into a dedicated GeForce NOW gaming kiosk that boots directly into the streaming service, creating a console-like experience optimized for M2 HAT+ SSD installations.

## Features

- 🎮 **Direct Boot to GeForce NOW** - No desktop interaction needed
- 🚀 **Optimized Performance** - GPU acceleration and network optimizations for streaming
- 🔧 **Easy Management** - Control script for maintenance and troubleshooting
- 💾 **SSD Optimized** - Configured for M2 HAT+ SSD installations
- 🔊 **Audio Ready** - Low-latency audio configuration for gaming
- 🛡️ **Auto-Recovery** - Automatic restart if the browser crashes
- 📱 **Kiosk Mode** - Full-screen experience with hidden UI elements

## Prerequisites

- Raspberry Pi 5 with M2 HAT+ and SSD
- Fresh Raspberry Pi OS installation (Desktop version recommended)
- Internet connection
- Keyboard for initial setup (can be removed after setup)

## Quick Start

1. **Download and run the setup script:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/WonderBoyHub/ki/main/setup-geforce-now-kiosk.sh -o setup-geforce-now-kiosk.sh
   chmod +x setup-geforce-now-kiosk.sh
   ./setup-geforce-now-kiosk.sh
   ```

2. **Follow the prompts** - The script will guide you through the setup process

3. **Reboot** - The system will automatically reboot into GeForce NOW kiosk mode

## What the Script Does

### System Configuration
- Sets up automatic login for the `pi` user
- Installs Chromium browser and essential packages
- Configures GPU settings for optimal video streaming
- Optimizes network settings for low latency gaming

### Audio Setup
- Configures PulseAudio for low-latency gaming
- Sets up proper audio permissions and routing
- Optimizes audio buffer settings

### Kiosk Mode
- Creates a systemd service for auto-starting GeForce NOW
- Configures Chromium with gaming-optimized flags
- Disables screen blanking and power management
- Hides cursor and UI elements for immersive experience

### Performance Optimizations
- Disables unnecessary system services
- Configures GPU memory allocation
- Sets up network buffer optimizations
- Reduces system swappiness for better performance

## Control Script Usage

After installation, use the control script to manage your kiosk:

```bash
# Start the kiosk
./geforce-now-control.sh start

# Stop the kiosk
./geforce-now-control.sh stop

# Restart the kiosk
./geforce-now-control.sh restart

# Check service status
./geforce-now-control.sh status

# View live logs
./geforce-now-control.sh logs

# Access desktop temporarily
./geforce-now-control.sh desktop

# Disable auto-start
./geforce-now-control.sh disable

# Re-enable auto-start
./geforce-now-control.sh enable
```

## Accessing the Desktop

If you need to access the desktop environment:

1. **SSH Method** (recommended):
   ```bash
   ssh pi@your-raspberry-pi-ip
   ./geforce-now-control.sh desktop
   ```

2. **Keyboard Shortcut**: Press `Ctrl+Alt+T` to open a terminal, then run:
   ```bash
   ./geforce-now-control.sh desktop
   ```

## Troubleshooting

### Browser Won't Start
- Check service status: `./geforce-now-control.sh status`
- View logs: `./geforce-now-control.sh logs`
- Restart service: `./geforce-now-control.sh restart`

### Audio Issues
- Check audio devices: `aplay -l`
- Test audio: `speaker-test`
- Restart PulseAudio: `pulseaudio -k && pulseaudio --start`

### Performance Issues
- Monitor system resources: `htop`
- Check GPU status: `vcgencmd measure_temp`
- Verify SSD mount: `df -h`

### Network/Streaming Issues
- Test connection: `ping play.geforcenow.com`
- Check bandwidth: Use GeForce NOW's built-in network test
- Verify DNS: `nslookup play.geforcenow.com`

## Configuration Files

The script creates several configuration files:

- **Service**: `/etc/systemd/system/geforce-now-kiosk.service`
- **Launch Script**: `/home/pi/start-geforce-now.sh`
- **Control Script**: `/home/pi/geforce-now-control.sh`
- **Chromium Config**: `/home/pi/.config/chromium/Default/Preferences`
- **Audio Config**: `/home/pi/.pulse/daemon.conf`

## Customization

### Change Target URL
Edit `/home/pi/start-geforce-now.sh` and modify the `GEFORCE_NOW_URL` variable:
```bash
GEFORCE_NOW_URL="https://your-custom-url.com"
```

### Adjust Browser Flags
Modify the Chromium flags in `/home/pi/start-geforce-now.sh` to suit your needs.

### Display Settings
Use `raspi-config` to adjust resolution and display options:
```bash
sudo raspi-config
```

## Hardware Recommendations

### Minimum Requirements
- Raspberry Pi 5 (4GB RAM)
- MicroSD card (Class 10, 16GB+)
- Power supply (5V/3A USB-C)
- HDMI cable and display

### Recommended Setup
- Raspberry Pi 5 (8GB RAM)
- M2 HAT+ with NVMe SSD (256GB+)
- Official Raspberry Pi Power Supply
- Gigabit Ethernet or 5GHz Wi-Fi
- Gamepad (Xbox/PlayStation controller)
- Quality speakers or headphones

## GeForce NOW Setup

After the kiosk boots:

1. **Sign in** to your NVIDIA account
2. **Accept** any terms of service
3. **Configure** streaming quality in settings
4. **Test** your network connection
5. **Start gaming**!

## Security Considerations

- The system runs in kiosk mode with reduced security for performance
- Consider using a dedicated network or VLAN for the gaming device
- Regularly update the system when accessing desktop mode
- Monitor network traffic if security is a concern

## Uninstalling

To remove the kiosk setup:

1. **Disable the service**:
   ```bash
   ./geforce-now-control.sh disable
   ```

2. **Remove service file**:
   ```bash
   sudo rm /etc/systemd/system/geforce-now-kiosk.service
   sudo systemctl daemon-reload
   ```

3. **Reset auto-login**:
   ```bash
   sudo raspi-config
   # Navigate to System Options > Boot / Auto Login > Desktop
   ```

## Support and Contributing

- **Issues**: Report problems via GitHub issues
- **Contributions**: Pull requests welcome
- **Questions**: Check existing issues or create a new one

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Based on Raspberry Pi kiosk tutorials from [Pi Australia](https://raspberry.piaustralia.com.au/blogs/news/how-to-boot-chromium-into-kiosk-mode-on-a-raspberry-pi)
- Inspired by [JonathanMH's dashboard setup](https://jonathanmh.com/raspberry-pi-4-kiosk-wall-display-dashboard/)
- Community contributions and testing

---

**Happy Gaming! 🎮**