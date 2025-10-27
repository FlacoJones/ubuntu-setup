# VLAN 10 Configuration

This guide shows how to configure VLAN 10 on a Cisco switch with ports 1-3 as access ports and port 24 as the trunk port to the gateway/router (WLAN).

## Configuration Steps

### 1. Create VLAN 10
```
SW1> enable
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name DATA_VLAN
SW1(config-vlan)# exit
```

### 2. Configure Access Ports (Ports 1, 2, 3)
```
SW1(config)# interface range gi0/1-3
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
SW1(config-if-range)# spanning-tree portfast
SW1(config-if-range)# no shutdown
SW1(config-if-range)# exit
```

### 3. Configure Trunk Port (Port 24 - Gateway to WLAN)
```
SW1(config)# interface gi0/24
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk allowed vlan 10
SW1(config-if)# switchport trunk native vlan 1
SW1(config-if)# no shutdown
SW1(config-if)# exit
```

### 4. Configure VLAN 10 Interface (SVI) - Optional
If the switch needs an IP address for management in VLAN 10:
```
SW1(config)# interface vlan 10
SW1(config-if)# ip address 192.168.10.2 255.255.255.0
SW1(config-if)# no shutdown
SW1(config-if)# exit
```

### 5. Set Default Gateway
```
SW1(config)# ip default-gateway 192.168.10.1
SW1(config)# exit
```

### 6. Save Configuration
```
SW1# write memory
```

## Verification Commands

### Check VLAN Configuration
```
SW1# show vlan brief
```

### Check Interface Status
```
SW1# show interface status
```

### Check Trunk Configuration
```
SW1# show interface gi0/24 switchport
```

### Check Specific VLAN Interfaces
```
SW1# show vlan id 10
```

### Verify Interface VLAN Assignment
```
SW1# show interface gi0/1 switchport
```

## Expected Output

After configuration, VLAN 10 should show:
- **Ports 1-3**: Access ports in VLAN 10
- **Port 24**: Trunk port carrying VLAN 10 traffic to gateway/router

## Topology Overview
```
[Devices] --- Ports 1-3 (Access VLAN 10) --- [Switch] --- Port 24 (Trunk) --- [Router/Gateway] --- WLAN
```

## Notes
- The default gateway (typically 192.168.10.1) should be configured on the router connected to port 24
- Port 24 is configured as a trunk to allow multiple VLANs in the future
- PortFast is enabled on access ports for faster connectivity (only use on end-device ports)
- Adjust IP addresses according to your network design

