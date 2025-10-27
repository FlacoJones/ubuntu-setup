# Cisco Switch Factory Reset Guide

## ⚠️ WARNING
**Factory reset will erase ALL configurations including:**
- VLAN configurations
- Port settings
- Trunk configurations
- Spanning Tree settings
- Port security settings
- QoS policies
- IP addresses and management settings
- All custom configurations

**ALWAYS backup your configuration before proceeding!**

---

## Backup Configuration First

```bash
# Cisco Switch
Switch# copy running-config tftp:
# or
Switch# copy running-config startup-config
Switch# copy startup-config tftp://[TFTP_SERVER_IP]/switch-backup.cfg

# Show current config before reset
Switch# show running-config

# Check for VLAN database
Switch# show vlan brief
```

---

## Method 1: Hardware Reset Button

### Cisco Switches (Catalyst Series)
1. Unplug power cable
2. Hold down the **MODE** button (on front panel)
3. Plug in power cable while holding button
4. Keep holding until STAT LED blinks amber (about 10 seconds)
5. Release button
6. Switch will boot with factory defaults

---

## Method 2: Console CLI Reset

### Cisco IOS Switch - Standard Reset
```bash
# Connect via console cable
# Enter privileged EXEC mode
Switch> enable

# Delete VLAN database
Switch# delete flash:vlan.dat
# Confirm deletion
Delete filename [vlan.dat]? [enter]
Delete flash:vlan.dat? [confirm] [enter]

# Erase startup configuration
Switch# write erase
# or
Switch# erase startup-config

# Confirm
Erasing the nvram filesystem will remove all configuration files! Continue? [confirm]
[OK]
Erase of nvram: complete

# Reload the switch
Switch# reload

# Confirm reload
System configuration has been modified. Save? [yes/no]: no
Proceed with reload? [confirm] [enter]
```

### Cisco Switch - Complete Reset (Alternative)
```bash
Switch> enable
Switch# write erase
Switch# delete flash:vlan.dat
Switch# delete flash:config.text
Switch# reload
```

---

## Default Settings After Reset

**Cisco Default Settings:**
- IP Address: `192.168.1.1` or unassigned (DHCP)
- Username: No username
- Password: No password or `cisco`

**Note**: Check the label on your switch for model-specific defaults.

---

## Post-Reset Configuration

### Initial Setup Steps

**1. Connect via console cable**

**2. Configure management IP address:**
```bash
Switch> enable
Switch# configure terminal
Switch(config)# interface vlan 1
Switch(config-if)# ip address 192.168.1.10 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit
```

**3. Set hostname:**
```bash
Switch(config)# hostname SW1
```

**4. Configure passwords:**
```bash
SW1(config)# enable secret YourEnablePassword

SW1(config)# line console 0
SW1(config-line)# password YourConsolePassword
SW1(config-line)# login
SW1(config-line)# exit

SW1(config)# line vty 0 15
SW1(config-line)# password YourVTYPassword
SW1(config-line)# login
SW1(config-line)# exit
```

**5. Set default gateway:**
```bash
SW1(config)# ip default-gateway 192.168.1.1
```

**6. Save configuration:**
```bash
SW1(config)# exit
SW1# write memory
# or
SW1# copy running-config startup-config
```

### Basic Security Configuration
1. Change all default passwords
2. Create VLANs as needed
3. Configure port security
4. Enable STP/RSTP
5. Configure management VLAN
6. Disable unused ports
7. Set up SSH access and disable Telnet

---

## Troubleshooting

### Cannot Access Switch After Reset
1. Check physical connections
2. Set computer to DHCP or static IP in correct subnet
3. Verify switch management VLAN is configured
4. Connect via console cable for direct access
5. Try default IP address if configured

### Reset Button Not Responding
- Verify correct button (MODE button on front panel)
- Ensure power is OFF before starting procedure
- Hold button longer (some models need 30+ seconds)
- Try with paperclip if button is recessed
- Check for physical damage to button

### Switch Won't Boot After Reset
1. Unplug power for 30 seconds
2. Check for stuck MODE button
3. Try reset procedure again
4. May require firmware recovery (see Recovery Mode below)

### Configuration Not Erased
- Ensure you deleted `vlan.dat` file (required for complete reset)
- Use `write erase` before reload
- Try hardware reset method instead
- Verify commands were executed in privileged EXEC mode

---

## VLAN.dat File (Cisco Specific)

The `vlan.dat` file stores VLAN configurations separately from main config:

```bash
# Check if vlan.dat exists
Switch# dir flash:

# Delete vlan.dat (must be done separately from erase startup-config)
Switch# delete flash:vlan.dat

# Complete reset procedure
Switch# delete flash:vlan.dat
Switch# erase startup-config
Switch# reload
```

**Important**: You MUST delete `vlan.dat` separately - it is not removed by `erase startup-config` alone!

---

## Recovery Mode (For Failed Reset)

### Cisco Switch Recovery
1. Unplug switch
2. Hold MODE button and plug in power
3. Hold until SYST LED turns amber (~10 seconds)
4. You should see `switch:` prompt

**Initialize flash filesystem:**
```bash
switch: flash_init
switch: load_helper
```

**List files:**
```bash
switch: dir flash:
```

**Rename or delete config:**
```bash
switch: rename flash:config.text flash:config.old
# or
switch: delete flash:config.text
```

**Delete VLAN database:**
```bash
switch: delete flash:vlan.dat
```

**Boot switch:**
```bash
switch: boot
```

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
- Serial settings: 9600 baud, 8 data bits, no parity, 1 stop bit
- Always delete both `config.text` (or `startup-config`) AND `vlan.dat`
- Layer 3 switches may need additional routing config cleared
- Stack configurations may need special procedures
