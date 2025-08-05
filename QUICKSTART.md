# QuickStart Guide - GeForce NOW Kiosk

Get your Raspberry Pi 5 running as a GeForce NOW kiosk in minutes!

## 🚀 One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/WonderBoyHub/ki/main/install.sh | bash
```

## 📋 Step-by-Step Installation

### 1. Download the Files
```bash
# Download all files
wget https://raw.githubusercontent.com/yourusername/ki/main/setup-geforce-now-kiosk.sh
wget https://raw.githubusercontent.com/yourusername/ki/main/config.conf
chmod +x setup-geforce-now-kiosk.sh
```

### 2. Customize Configuration (Optional)
```bash
# Edit the configuration file
nano config.conf
```

**Key settings to customize:**
- `GEFORCE_NOW_URL` - Change the target URL
- `SCREEN_WIDTH/HEIGHT` - Set specific resolution
- `CPU_GOVERNOR` - Performance vs power saving
- `SERVICES_TO_DISABLE` - Remove services you want to keep

### 3. Run the Setup
```bash
./setup-geforce-now-kiosk.sh
```

### 4. Reboot
The system will automatically reboot into kiosk mode!

## 🎮 First Boot

After reboot, your Pi will:
1. ✅ Auto-login as the `pi` user
2. ✅ Launch Chromium in full-screen kiosk mode  
3. ✅ Navigate to GeForce NOW
4. ✅ Hide all desktop elements

**What you'll see:**
- GeForce NOW login screen in full-screen
- No desktop, taskbar, or browser UI
- Optimized for gamepad/keyboard navigation

## 🔧 Management Commands

Access via SSH or terminal (`Ctrl+Alt+T`):

```bash
# Control the kiosk
./geforce-now-control.sh start    # Start kiosk
./geforce-now-control.sh stop     # Stop kiosk  
./geforce-now-control.sh restart  # Restart kiosk
./geforce-now-control.sh status   # Check status
./geforce-now-control.sh desktop  # Access desktop temporarily
./geforce-now-control.sh logs     # View logs
```

## 🎯 Quick Troubleshooting

### Browser Won't Start
```bash
./geforce-now-control.sh logs
# Look for error messages
```

### No Audio
```bash
# Test audio output
speaker-test -c2 -t wav

# List audio devices  
aplay -l
```

### Performance Issues
```bash
# Check temperature
vcgencmd measure_temp

# Monitor resources
htop
```

### Network Issues
```bash
# Test GeForce NOW connectivity
ping play.geforcenow.com

# Check bandwidth
speedtest-cli
```

## ⚡ Quick Customizations

### Change Target URL
```bash
nano ~/start-geforce-now.sh
# Edit the --app="URL" line
```

### Adjust Performance
```bash
nano ~/config.conf
# Change CPU_GOVERNOR to "performance" or "ondemand"
# Adjust GPU_MEMORY (128-256 MB)
```

### Enable SSH Access
```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

## 🆘 Emergency Recovery

### Access Desktop from Boot
1. **Power on** and quickly press `Shift` during boot
2. Select **"Recovery"** from the boot menu
3. Choose **"Desktop"** when prompted

### Reset to Default
```bash
# Disable kiosk mode
./geforce-now-control.sh disable

# Remove service completely  
sudo systemctl disable geforce-now-kiosk
sudo rm /etc/systemd/system/geforce-now-kiosk.service
```

### Complete Reinstall
```bash
# Remove everything and start over
sudo rm -f /etc/systemd/system/geforce-now-kiosk.service
sudo rm -f ~/start-geforce-now.sh ~/geforce-now-control.sh
sudo systemctl daemon-reload

# Then re-run setup script
./setup-geforce-now-kiosk.sh
```

## 📊 Performance Tips

### For Best Streaming Quality
- **Network**: Use Ethernet instead of Wi-Fi
- **Resolution**: Match your display's native resolution
- **Audio**: Use quality speakers or gaming headset
- **Controller**: Xbox or PlayStation controller recommended

### For Best Performance  
- **CPU Governor**: Set to "performance"
- **GPU Memory**: Allocate 256MB
- **Disable Services**: Remove Bluetooth, Wi-Fi if using Ethernet
- **SSD**: Ensure you're running from SSD, not SD card

## 🔗 Useful Links

- **GeForce NOW Help**: https://nvidia.com/geforce-now/support/
- **Raspberry Pi Documentation**: https://raspberrypi.org/documentation/
- **Report Issues**: https://github.com/yourusername/ki/issues

---

**Happy Gaming! 🎮**

*Need help? Check the full README.md or create an issue on GitHub.*