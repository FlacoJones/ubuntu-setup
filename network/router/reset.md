# Cisco Router Factory Reset Guide

## ⚠️ WARNING
**Factory reset will erase ALL configurations including:**
- Network settings (IP addresses, subnets)
- Firewall rules
- NAT configurations
- DHCP settings
- Wireless settings
- Port forwarding rules
- All custom configurations

**ALWAYS backup your configuration before proceeding!**

---

## Backup Configuration First

```bash
# Cisco IOS
Router# copy running-config tftp:
# or
Router# write memory
Router# copy startup-config tftp://[TFTP_SERVER_IP]/backup.cfg

# Show current config before reset
Router# show running-config
```

---

## Method 1: Hardware Reset Button

### Cisco Routers
1. Locate the **RESET** button (usually recessed on back/bottom)
2. With router powered ON, press and hold the reset button
3. Hold for **10-30 seconds** (until LEDs flash or change pattern)
4. Release the button
5. Wait for router to fully reboot (2-5 minutes)
6. Router will be at factory defaults

### Typical Default Credentials After Reset
- IP Address: `192.168.1.1` or `192.168.0.1`
- Username: `admin` or no username
- Password: `admin`, `cisco`, or no password

---

## Method 2: Console CLI Reset

### Cisco IOS Router
```bash
# Connect via console cable
# Enter privileged EXEC mode
Router> enable

# Erase startup configuration
Router# write erase
# or
Router# erase startup-config

# Confirm when prompted
[confirm]

# Reload the router
Router# reload

# Confirm reload
Proceed with reload? [confirm]
```

### Cisco IOS-XE Router
```bash
Router> enable
Router# write erase
Router# delete /force vlan.dat
Router# reload
```

---

## Post-Reset Configuration

### Immediate Actions
1. Connect via console cable or Ethernet
2. Set your computer to obtain IP automatically (DHCP)
3. Access router at default IP address
4. Log in with default credentials
5. **IMMEDIATELY change admin password**

### Basic Initial Configuration

```bash
# Set hostname
Router> enable
Router# configure terminal
Router(config)# hostname R1

# Set enable password
R1(config)# enable secret YourNewPassword

# Configure console password
R1(config)# line console 0
R1(config-line)# password YourConsolePassword
R1(config-line)# login
R1(config-line)# exit

# Configure VTY (Telnet/SSH) password
R1(config)# line vty 0 15
R1(config-line)# password YourVTYPassword
R1(config-line)# login
R1(config-line)# exit

# Configure interface
R1(config)# interface gi0/0
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit

# Save configuration
R1(config)# exit
R1# write memory
# or
R1# copy running-config startup-config
```

---

## Troubleshooting

### Reset Button Not Working
- Ensure router is powered ON during reset
- Try holding for longer (up to 60 seconds)
- Try using a paperclip or pin for recessed buttons
- Verify you're pressing RESET button (not MODE button)

### Cannot Access Router After Reset
- Verify computer is on same subnet
- Check physical cable connections
- Try different Ethernet port
- Release/renew DHCP: `sudo dhclient -r && sudo dhclient`
- Connect via console cable for direct access

### Router Stuck in Boot Loop
1. Unplug power
2. Wait 30 seconds
3. Hold reset button while plugging power back in
4. Continue holding for 30 seconds
5. Release and wait for full boot

---

## Console Connection Settings

**Serial Port Settings:**
- Baud Rate: 9600
- Data Bits: 8
- Parity: None
- Stop Bits: 1
- Flow Control: None

**Connect using:**
```bash
# Using minicom
sudo minicom -D /dev/ttyUSB0 -b 9600

# Using screen
screen /dev/ttyUSB0 9600
```

---

## Additional Notes

- Console cable required for CLI reset (RJ45 to USB/Serial)
- Default credentials vary by model - check label on router
- Some routers may use 115200 baud rate instead of 9600
- Enterprise routers typically don't have hardware reset buttons
