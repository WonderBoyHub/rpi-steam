# Raspberry Pi 5 GeForce Now Gaming Kiosk

Transform your Raspberry Pi 5 into a dedicated GeForce Now cloud gaming kiosk that boots directly to gaming.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%205-red.svg)

## ✨ Features

- **Auto-boot to GeForce Now** - Boots directly to cloud gaming
- **Optimized for Pi 5** - Hardware-accelerated Chromium with gaming flags
- **Performance tuned** - GPU, CPU, and network optimizations included
- **Kiosk mode** - Full-screen gaming experience
- **Easy troubleshooting** - Built-in diagnostic and monitoring tools
- **Emergency exit hotkey** - `Ctrl+Alt+X` for system access
- **Simple restart options** - Easy shutdown/restart after gaming sessions

## 🔧 Requirements

### Hardware
- Raspberry Pi 5 (4GB+ RAM recommended)
- MicroSD card (Class 10, A2) or USB 3.0 SSD
- **Wired Ethernet connection** (recommended for best performance)
- USB gamepad/controller
- HDMI monitor
- Official Pi 5 power supply

### Software
- Fresh **Raspberry Pi OS Desktop (64-bit)**
- GeForce Now account
- Stable internet (25+ Mbps recommended)

## 🚀 Quick Start

### 1. Prepare Your Pi
1. Flash Raspberry Pi OS Desktop (64-bit) using Raspberry Pi Imager
2. Complete initial setup wizard
3. Ensure internet connection is working

### 2. One-Command Installation
```bash
wget https://raw.githubusercontent.com/WonderBoyHub/rpi-steam/main/rpi5-gaming-kiosk-setup.sh && chmod +x rpi5-gaming-kiosk-setup.sh && ./rpi5-gaming-kiosk-setup.sh
```

### 3. Reboot and Game
```bash
sudo reboot
```
Your Pi will now boot directly to GeForce Now!

## 🎮 Usage

### Gaming
1. **Boot** - Your Pi automatically shows a welcome message
2. **Start** - Click OK to launch GeForce Now in kiosk mode
3. **Play** - Log in to your GeForce Now account and start gaming
4. **End Session** - After gaming, choose to restart, shutdown, or exit

### System Access
- **Emergency Exit**: Press `Ctrl+Alt+X` to access terminal
- **Performance Monitor**: Run `~/monitor-gaming-performance.sh`

## ⚡ Optimization (Optional)

For enhanced performance and troubleshooting tools:

```bash
wget https://raw.githubusercontent.com/WonderBoyHub/rpi-steam/main/geforce-now-optimizer.sh && chmod +x geforce-now-optimizer.sh && ./geforce-now-optimizer.sh
```

### Optimizer Features
- **Network performance testing** - Latency and speed diagnostics
- **Advanced browser optimizations** - Hardware acceleration and memory tuning
- **Real-time monitoring** - Temperature, CPU, and network stats
- **Comprehensive troubleshooting guide** - Solutions for common issues

## 🛠️ What Gets Installed

### System Setup
- Dedicated `gamer` user with auto-login
- Chromium browser with GeForce Now optimizations
- Openbox window manager for kiosk mode
- Zenity for user interface dialogs

### Performance Tweaks
- GPU memory optimization (128MB split)
- CPU performance governor
- Network buffer tuning for gaming
- Audio system optimization
- Hardware video acceleration enabled

## 🔍 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Input lag | Use wired peripherals, lower quality to 720p30 |
| Video stuttering | Check network speed, ensure wired connection |
| Audio issues | Restart PulseAudio: `pulseaudio -k && pulseaudio --start` |
| Connection problems | Try different DNS (8.8.8.8), clear browser cache |

### Performance Tips
- **Network**: Use wired Ethernet, optimize with `sudo ethtool -K eth0 gro off gso off tso off`
- **Temperature**: Monitor with `vcgencmd measure_temp`, ensure good ventilation
- **GeForce Now**: Start with 720p30, use "Balanced" quality setting

## 📋 Network Requirements

### For Optimal GeForce Now Performance
- **Minimum**: 15 Mbps download, <40ms latency
- **Recommended**: 25+ Mbps download, <20ms latency  
- **Optimal**: 50+ Mbps download, wired ethernet connection
- **Ping**: <20ms to GeForce Now servers for best experience

## 📁 File Structure

```
/home/gamer/
├── gaming-launcher.sh              # GeForce Now launcher script
├── launch-geforce-now-optimized.sh # Advanced optimizer script  
├── monitor-gaming-performance.sh   # Performance monitoring
├── geforce-now-troubleshooting.md  # Troubleshooting guide
├── optimize-network.sh             # Network optimization
└── .config/openbox/                # Kiosk window manager config
```

## 🔒 Security Notes

- Kiosk user has limited system privileges
- Auto-login enabled (suitable for dedicated gaming setups)
- Emergency exit provides administrative access
- Sudo access limited to specific gaming-related commands

## 🤝 Contributing

Issues and pull requests are welcome! This project is based on community feedback from the [Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=368439).

## 🙏 Acknowledgments

- Raspberry Pi community for testing and feedback
- GeForce Now performance optimization guides  
- Cloud gaming optimization tutorials for single-board computers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the troubleshooting guide or run the optimizer script for diagnostic tools.