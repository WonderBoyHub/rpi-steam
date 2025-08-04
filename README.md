# Raspberry Pi 5 Gaming Kiosk Setup

Transform your Raspberry Pi 5 into a dedicated gaming kiosk that boots directly to Steam Big Picture mode with GeForce Now cloud gaming integration.

## Overview 

This setup creates a kiosk environment that:
- Auto-boots to a gaming menu
- Provides easy access to GeForce Now cloud gaming
- Includes Steam Big Picture mode for local games
- Optimizes system performance for gaming
- Includes troubleshooting tools and guides

Based on community reports from the [Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=368439), GeForce Now works well on Pi 5 via Chromium browser, though performance may vary based on network conditions.

## Prerequisites

### Hardware Requirements
- Raspberry Pi 5 (4GB or 8GB RAM recommended)
- MicroSD card (Class 10, A2 rated) or USB 3.0 SSD
- Wired Ethernet connection (recommended for best streaming performance)
- USB gamepad/controller
- HDMI monitor
- Good power supply (official Pi 5 power supply recommended)

### Software Requirements
- Fresh installation of **Raspberry Pi OS Desktop (64-bit)**
- Active GeForce Now account
- Stable internet connection (25+ Mbps recommended)

## Quick Setup

### 1. Prepare Your Raspberry Pi

1. Flash Raspberry Pi OS Desktop (64-bit) to your SD card using Raspberry Pi Imager
2. Enable SSH if you want remote access during setup
3. Boot your Pi and complete the initial setup wizard
4. Ensure you have a working internet connection

### 2. Download and Run Setup Script

```bash
# Download the setup script
wget https://raw.githubusercontent.com/yourusername/rpi5-gaming-kiosk/main/rpi5-gaming-kiosk-setup.sh

# Make it executable
chmod +x rpi5-gaming-kiosk-setup.sh

# Run the setup script
./rpi5-gaming-kiosk-setup.sh
```

### 3. Reboot Your System

After the script completes successfully, reboot your Pi:

```bash
sudo reboot
```

## What the Setup Does

### System Configuration
- Creates a dedicated `gamer` user for the kiosk
- Configures auto-login and kiosk mode
- Installs Chromium browser optimized for GeForce Now
- Installs Steam for local gaming
- Sets up performance optimizations
- Creates emergency exit hotkeys (Ctrl+Alt+X)

### Performance Optimizations
- GPU memory split optimization
- CPU governor set to performance mode
- Network buffer optimizations
- Swap file configuration
- Audio system optimization

### Gaming Launcher
- Boot-time menu to choose between GeForce Now and Steam
- Optimized Chromium flags for cloud gaming
- Hardware acceleration enabled
- Screen saver and power management disabled

## Post-Setup Optimization

After the initial setup, run the GeForce Now optimizer for additional tweaks and troubleshooting tools:

```bash
# Download the optimizer script
wget https://raw.githubusercontent.com/yourusername/rpi5-gaming-kiosk/main/geforce-now-optimizer.sh

# Make it executable
chmod +x geforce-now-optimizer.sh

# Run the optimizer
./geforce-now-optimizer.sh
```

### What the Optimizer Does

The `geforce-now-optimizer.sh` script provides a comprehensive toolkit for optimizing and troubleshooting GeForce Now performance on your Raspberry Pi 5. Based on real user feedback from the [Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=368439), it addresses common issues like input lag that users have reported.

#### Interactive Menu Options:

**1. Network Performance Testing**
- Tests ping latency to GeForce Now servers (`cloud.gfn.games`)
- Measures basic download speed to identify connection bottlenecks
- Helps diagnose network-related performance issues

**2. Optimized GeForce Now Launcher**
- Creates `~/launch-geforce-now-optimized.sh` with advanced Chromium flags
- Enables hardware video acceleration (VaapiVideoDecoder/Encoder)
- Configures memory management and GPU rasterization
- Disables unnecessary features that could cause lag
- Sets CPU governor to performance mode during gaming
- Optimizes network buffers for reduced latency

**3. Performance Monitoring Tools**
- Creates `~/monitor-gaming-performance.sh` for real-time system monitoring
- Displays CPU/GPU temperatures and frequencies
- Shows memory usage and network statistics
- Monitors for thermal throttling (addresses overheating issues)
- Tracks gaming-related processes

**4. System Optimizations**
- Sets up tmpfs (RAM disk) for browser cache to reduce storage I/O
- Configures CPU frequency scaling for consistent performance
- Creates udev rules to reduce input device polling rates
- Optimizes GPU memory allocation
- Tunes network buffer sizes for gaming

**5. Comprehensive Troubleshooting Guide**
- Creates `~/geforce-now-troubleshooting.md` with solutions to common issues
- Addresses input lag problems reported by users like MrDuckHunt
- Provides commands for audio, video, and connection troubleshooting
- Includes emergency commands for system recovery
- Offers GeForce Now quality setting recommendations

#### Key Benefits:

- **Addresses Input Lag:** Specifically tackles the mouse/keyboard responsiveness issues reported in community forums
- **Network Optimization:** Implements Ethernet interface optimizations to reduce network latency
- **Temperature Management:** Helps prevent thermal throttling that can cause performance drops
- **Memory Efficiency:** Uses RAM disk for browser cache to improve responsiveness
- **Hardware Acceleration:** Maximizes use of Pi 5's GPU capabilities for video decoding

#### Example Optimizations Applied:

```bash
# Network buffer optimization
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem="4096 131072 134217728"

# Ethernet interface optimization  
sudo ethtool -K eth0 gro off gso off tso off

# CPU performance mode
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Input device polling optimization
echo 1000 > /sys/class/input/*/poll_msecs
```

The optimizer is particularly valuable for users experiencing the lag issues mentioned in community discussions, providing both automated fixes and diagnostic tools to identify the root cause of performance problems.

## Usage

### Normal Operation
1. Boot your Pi - it will automatically log in as the `gamer` user
2. Choose between "GeForce Now" or "Steam Big Picture" from the menu
3. For GeForce Now: Log in to your account and start gaming
4. For Steam: Access your local Steam library

### Emergency Exit
- Press `Ctrl+Alt+X` to exit kiosk mode and access a terminal
- Use this if you need to make system changes or troubleshoot

### Performance Monitoring
Run the performance monitor to check system status:
```bash
~/monitor-gaming-performance.sh
```

## Troubleshooting

### Common Issues

**Input Lag with GeForce Now:**
- Use wired mouse/keyboard instead of wireless
- Try different USB ports
- Lower GeForce Now quality settings to 720p30

**Video Stuttering:**
- Check network connection (run speed test)
- Ensure wired ethernet connection
- Close other applications
- Check system temperature: `vcgencmd measure_temp`

**Audio Issues:**
- Restart PulseAudio: `pulseaudio -k && pulseaudio --start`
- Check audio output settings in GeForce Now

**Connection Problems:**
- Verify internet connection
- Try different DNS servers (8.8.8.8, 1.1.1.1)
- Clear browser cache and cookies

### Performance Tips

1. **Network Optimization:**
   ```bash
   # Optimize ethernet interface
   sudo ethtool -K eth0 gro off gso off tso off
   ```

2. **Temperature Management:**
   - Ensure good ventilation
   - Consider adding a fan or heatsink
   - Monitor temperature: `vcgencmd measure_temp`

3. **GeForce Now Settings:**
   - Start with 720p30 for stability
   - Adjust bitrate based on your connection
   - Use "Balanced" streaming quality initially

## File Structure

After setup, you'll have these key files:

```
/home/gamer/
├── gaming-launcher.sh           # Main launcher script
├── launch-geforce-now-optimized.sh  # Optimized GeForce Now launcher
├── monitor-gaming-performance.sh     # Performance monitoring
├── geforce-now-troubleshooting.md   # Troubleshooting guide
└── .config/openbox/             # Openbox configuration
```

## Advanced Configuration

### Customizing the Gaming Menu
Edit `/home/gamer/gaming-launcher.sh` to modify the startup menu or add additional options.

### Adding More Streaming Services
The Chromium browser can be configured to launch other cloud gaming services like Xbox Cloud Gaming or Amazon Luna.

### Local Game Installation
Steam is installed and can be used for local games, though performance will vary based on the game's requirements.

## System Requirements for Different Scenarios

### GeForce Now Streaming
- **Minimum:** 15 Mbps download, <40ms latency
- **Recommended:** 25+ Mbps download, <20ms latency
- **Optimal:** 50+ Mbps download, wired connection

### Local Steam Games
- Limited to games compatible with ARM64 Linux
- Indie games and older titles typically work best
- Check ProtonDB for compatibility information

## Security Considerations

- The kiosk user has limited privileges
- Sudo access is only granted for specific system commands
- The system automatically logs in - suitable for dedicated gaming setups
- Emergency exit provides administrative access when needed

## Contributing

Found an issue or have an improvement? Feel free to submit issues or pull requests.

## Acknowledgments

- Based on community feedback from [Raspberry Pi forums](https://forums.raspberrypi.com/viewtopic.php?t=368439)
- Inspired by various gaming optimization guides for single-board computers
- Thanks to the GeForce Now and Steam communities for testing and feedback

## License

This project is open source and available under the MIT License.