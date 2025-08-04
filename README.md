# Raspberry Pi 5 GeForce NOW Kiosk

Transform your Raspberry Pi 5 into a dedicated GeForce NOW cloud gaming kiosk that boots directly to streaming AAA games.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%205-red.svg)

## ✨ Features

- **Auto-boot gaming environment** - Boots directly to GeForce NOW
- **GeForce NOW cloud gaming** - Stream AAA games via optimized Chromium browser
- **Performance optimized** - GPU, CPU, and network optimizations for cloud gaming
- **Hardware acceleration** - VaapiVideoDecoder enabled for smooth streaming
- **Easy troubleshooting** - Built-in diagnostic and monitoring tools
- **Emergency exit hotkey** - `Ctrl+Alt+X` for system access

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
wget https://raw.githubusercontent.com/WonderBoyHub/rpi-steam/main/rpi5-geforce-now-setup.sh && chmod +x rpi5-geforce-now-setup.sh && ./rpi5-geforce-now-setup.sh
```

### 3. Reboot and Game
```bash
sudo reboot
```
Your Pi will now boot directly to gaming!

## 🎮 Usage

### Gaming
1. **Boot** - Your Pi automatically launches GeForce NOW
2. **Login** - Sign in to your GeForce NOW account
3. **Play** - Select and start gaming from your library

### System Access
- **Emergency Exit**: Press `Ctrl+Alt+X` to access terminal
- **Restart Gaming**: When you close GeForce NOW, you'll get options to restart or shutdown

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
- Chromium browser with GeForce NOW optimizations
- Openbox window manager for kiosk mode
- Direct boot to GeForce NOW (no menus)

### Performance Optimizations
- GPU memory optimization for cloud gaming
- CPU performance governor set to performance mode
- Network buffer tuning for reduced streaming latency
- Audio system optimization for gaming
- Swap file configuration for stable performance
- Hardware acceleration enabled for video decoding

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

## 📋 System Requirements

### For GeForce NOW Streaming
- **Minimum**: 15 Mbps download, <40ms latency
- **Recommended**: 25+ Mbps download, <20ms latency
- **Optimal**: 50+ Mbps download, wired Ethernet connection
- **Network**: Wired connection strongly recommended over Wi-Fi

## 📁 File Structure

```
/home/gamer/
├── geforce-now-launcher.sh         # Main GeForce NOW launcher
├── Desktop/GeForceNow.desktop       # Desktop shortcut
└── .config/openbox/                # Kiosk window manager config
```

After running the optimizer script, you'll also have:
```
/home/gamer/
├── launch-geforce-now-optimized.sh # Advanced optimized launcher
├── monitor-gaming-performance.sh   # Performance monitoring
└── geforce-now-troubleshooting.md  # Troubleshooting guide
```

## 🔒 Security Notes

- Kiosk user has limited system privileges
- Auto-login enabled (suitable for dedicated gaming setups)
- Emergency exit provides administrative access
- Sudo access limited to specific gaming-related commands

## 🤝 Contributing

Issues and pull requests are welcome! This project is based on community feedback from the [Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=368439).

## 🙏 Acknowledgments

- Raspberry Pi community for testing and feedback from the [forums](https://forums.raspberrypi.com/viewtopic.php?t=368439)
- GeForce NOW performance optimization guides
- Cloud gaming optimization tutorials for single-board computers

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Need help?** Check the troubleshooting guide or run the optimizer script for diagnostic tools.