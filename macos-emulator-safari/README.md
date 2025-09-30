# macOS Emulator with Safari

🍎 A comprehensive setup for running macOS in a virtual environment with Safari browser support.

## ⚠️ Legal Disclaimer

**IMPORTANT:** This repository is for educational and development purposes only. Running macOS on non-Apple hardware may violate Apple's Software License Agreement. Please ensure you:

- Own a legitimate macOS license
- Are aware of local laws and regulations
- Use this only for authorized purposes
- Read and comply with Apple's EULA

## 🚀 Features

- **macOS Virtual Machine Setup**: Complete virtualization environment
- **Safari Browser**: Native Safari browser support
- **Performance Optimized**: Tuned for better performance
- **Easy Installation**: Automated setup scripts
- **Docker Support**: Containerized environment option
- **Development Tools**: Pre-configured development environment

## 📋 Prerequisites

### Hardware Requirements
- **CPU**: Intel/AMD with virtualization support (VT-x/AMD-V)
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 100GB free space
- **Network**: Stable internet connection

### Software Requirements
- **Docker**: Version 20.10+
- **QEMU**: Version 6.0+
- **VirtualBox**: Version 6.1+ (alternative)
- **Git**: For cloning the repository

## 🛠️ Installation

### Option 1: Docker Setup (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/macos-emulator-safari.git
   cd macos-emulator-safari
   ```

2. **Run the setup script:**
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. **Start the container:**
   ```bash
   docker-compose up -d
   ```

### Option 2: QEMU Setup

1. **Install QEMU:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install qemu-system-x86 qemu-utils
   
   # CentOS/RHEL
   sudo yum install qemu-kvm qemu-img
   
   # macOS
   brew install qemu
   ```

2. **Run setup:**
   ```bash
   ./scripts/setup-qemu.sh
   ```

### Option 3: VirtualBox Setup

1. **Install VirtualBox:**
   ```bash
   # Ubuntu/Debian
   sudo apt install virtualbox
   
   # Or download from https://www.virtualbox.org/
   ```

2. **Configure VM:**
   ```bash
   ./scripts/setup-virtualbox.sh
   ```

## 🖥️ Usage

### Starting macOS

```bash
# Docker method
docker-compose up

# QEMU method
./scripts/start-macos.sh

# VirtualBox method
./scripts/start-virtualbox.sh
```

### Accessing Safari

1. **Wait for macOS to boot** (first boot may take 10-15 minutes)
2. **Complete macOS setup** (create user account, etc.)
3. **Open Safari** from Applications or Dock
4. **Configure Safari** using provided settings

### Remote Access

```bash
# VNC access (if configured)
vncviewer localhost:5900

# Web VNC access
http://localhost:6080
```

## 🔧 Configuration

### Performance Tuning

Edit `configs/performance.conf`:

```bash
# CPU cores (adjust based on your system)
CPU_CORES=4

# RAM allocation (in MB)
RAM_SIZE=8192

# Graphics memory
VRAM_SIZE=256

# Enable hardware acceleration
ENABLE_HW_ACCEL=true
```

### Safari Settings

Customize Safari configuration in `configs/safari.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>HomePage</key>
    <string>https://www.apple.com</string>
    <key>NewTabBehavior</key>
    <integer>1</integer>
    <key>ShowDevelopMenu</key>
    <true/>
</dict>
</plist>
```

## 🔄 Updates

### Updating macOS

```bash
# Update the system
./scripts/update-macos.sh

# Update Safari
./scripts/update-safari.sh
```

### Updating Container

```bash
# Pull latest image
docker-compose pull

# Restart with updates
docker-compose down && docker-compose up -d
```

## 🛡️ Security

- **Firewall**: Configure appropriate firewall rules
- **Network**: Use isolated network when possible
- **Updates**: Keep the system updated
- **Backups**: Regular snapshots recommended

## 📊 Monitoring

### System Performance

```bash
# Monitor resource usage
./scripts/monitor.sh

# Check logs
docker-compose logs -f
```

### Safari Performance

- **Developer Tools**: Enable Safari developer tools
- **Console Logs**: Monitor JavaScript console
- **Network Tab**: Check network requests

## 🔧 Troubleshooting

### Common Issues

1. **Boot fails**:
   ```bash
   # Check logs
   ./scripts/check-logs.sh
   
   # Reset configuration
   ./scripts/reset-config.sh
   ```

2. **Safari crashes**:
   ```bash
   # Clear Safari cache
   ./scripts/clear-safari-cache.sh
   
   # Reset Safari preferences
   ./scripts/reset-safari.sh
   ```

3. **Performance issues**:
   ```bash
   # Optimize performance
   ./scripts/optimize-performance.sh
   ```

### Getting Help

- **Check logs**: `./scripts/check-logs.sh`
- **Run diagnostics**: `./scripts/diagnose.sh`
- **Community**: Join our discussions
- **Issues**: Report bugs on GitHub

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OSX-KVM**: For macOS virtualization insights
- **Docker-OSX**: For containerization approach
- **QEMU Team**: For virtualization technology
- **Community**: For continuous support and feedback

## 📞 Support

- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Check the `docs/` directory
- **Community**: Join our Discord/Slack
- **Email**: support@your-domain.com

---

**Note**: This is an educational project. Please use responsibly and in compliance with all applicable laws and license agreements.