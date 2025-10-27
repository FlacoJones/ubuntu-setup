# Router Setup

## Connecting to Cisco Router via Console Cable on Ubuntu

### Prerequisites
- Console cable (RJ45 to DB9 or USB-to-Serial adapter)
- Cisco router with console port
- Ubuntu system with terminal access

### Step 1: Install Required Tools
```bash
# Install minicom (most common serial terminal)
sudo apt update
sudo apt install minicom

# Alternative: Install screen (lighter option)
sudo apt install screen

# Alternative: Install cu (part of uucp package)
sudo apt install uucp
```

### Step 2: Identify Serial Port
```bash
# List all serial devices
ls /dev/ttyS* /dev/ttyUSB* /dev/ttyACM*

# Check dmesg for USB-to-Serial adapters
dmesg | grep -i usb
dmesg | grep -i serial

# Common device names:
# /dev/ttyS0 - Built-in serial port
# /dev/ttyUSB0 - USB-to-Serial adapter (FTDI, Prolific, etc.)
# /dev/ttyACM0 - USB CDC ACM device
```

### Step 3: Configure Serial Connection

#### Using Minicom (Recommended)
```bash
# Configure minicom
sudo minicom -s

# In minicom configuration:
# 1. Select "Serial port setup"
# 2. Set Serial Device: /dev/ttyUSB0 (or your device)
# 3. Set Bps/Par/Bits: 9600 8N1
# 4. Set Hardware Flow Control: No
# 5. Set Software Flow Control: No
# 6. Save setup as "df1" (default)
# 7. Exit

# Connect to router
sudo minicom -D /dev/ttyUSB0 -b 9600
sudo minicom -D /dev/ttyUSB1 -b 9600
```

#### Using Screen
```bash
# Connect with screen
screen /dev/ttyUSB0 9600

# To exit screen: Ctrl+A then K, then Y to confirm
```

#### Using cu
```bash
# Connect with cu
cu -l /dev/ttyUSB0 -s 9600

# To exit cu: type ~. and press Enter
```

### Step 4: Router Console Settings
Most Cisco routers use these default console settings:
- **Baud Rate**: 9600
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1
- **Flow Control**: None

### Step 5: Troubleshooting

#### Permission Issues
```bash
# Add user to dialout group
sudo usermod -a -G dialout $USER

# Log out and back in, or run:
newgrp dialout
```

#### Device Not Found
```bash
# Check if device is recognized
lsusb
lsmod | grep usbserial

# Load USB serial drivers if needed
sudo modprobe usbserial
sudo modprobe ftdi_sio
sudo modprobe pl2303
```

#### Connection Issues
- Verify cable is properly connected
- Try different baud rates (9600, 38400, 115200)
- Check if router is powered on
- Try different USB ports
- Test with different terminal emulator

### Step 6: Common Commands After Connection
```bash
# If router prompts for login:
# Username: (often 'admin' or 'cisco')
# Password: (check router documentation)

# Common initial commands:
Router> enable
Router# configure terminal
Router# show version
Router# show interfaces
Router# show running-config
```

### Quick Connection Script
Create a script for easy connection:
```bash
#!/bin/bash
# save as connect_router.sh
DEVICE="/dev/ttyUSB0"
BAUD="9600"

if [ -e "$DEVICE" ]; then
    echo "Connecting to router on $DEVICE at $BAUD baud..."
    minicom -D $DEVICE -b $BAUD
else
    echo "Device $DEVICE not found. Available devices:"
    ls /dev/ttyS* /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
fi
```

### Notes
- Some newer Cisco devices may use 115200 baud rate
- USB-to-Serial adapters may require specific drivers
- Console access doesn't require network connectivity
- Always check router documentation for specific console settings

