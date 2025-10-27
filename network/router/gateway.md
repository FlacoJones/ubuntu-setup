# Cisco Router Gateway Configuration

## Network Topology
```
[Switch Port 24 (Trunk VLAN 10)] ← → [Router GE 0/1] → [Router GE 0/0] ← → [WLAN Gateway Router]
      192.168.10.0/24 network                                                   Internet
```

**Router Interfaces:**
- **GE 0/1**: Connected to Switch (VLAN 10 gateway)
- **GE 0/0**: Connected to upstream WLAN gateway router

---

## Basic Gateway Configuration

### 1. Configure GE 0/1 for VLAN 10 (Switch Side)

Since the switch port 24 is configured as a trunk, use subinterface for VLAN 10:

```bash
Router> enable
Router# configure terminal

# Configure GE 0/1 as trunk interface
Router(config)# interface gi0/1
Router(config-if)# description Connection to Switch Port 24
Router(config-if)# no shutdown
Router(config-if)# exit

# Configure subinterface for VLAN 10
Router(config)# interface gi0/1.10
Router(config-subif)# description VLAN 10 Gateway
Router(config-subif)# encapsulation dot1Q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0
Router(config-subif)# no shutdown
Router(config-subif)# exit
```

**Note**: The IP address `192.168.10.1` matches the default gateway configured on the switch.

---

### 2. Configure GE 0/0 for Upstream Connection (WLAN Gateway Side)

**Option A: If WLAN Gateway provides DHCP**
```bash
Router(config)# interface gi0/0
Router(config-if)# description Connection to WLAN Gateway
Router(config-if)# ip address dhcp
Router(config-if)# no shutdown
Router(config-if)# exit
```

**Option B: If using Static IP from WLAN Gateway**
```bash
Router(config)# interface gi0/0
Router(config-if)# description Connection to WLAN Gateway
Router(config-if)# ip address 192.168.1.100 255.255.255.0
Router(config-if)# no shutdown
Router(config-if)# exit

# Set default route to WLAN gateway
Router(config)# ip route 0.0.0.0 0.0.0.0 192.168.1.1
```

*(Adjust IP addresses based on your WLAN gateway's network)*

---

### 3. Enable IP Routing

```bash
# IP routing is typically enabled by default on routers
Router(config)# ip routing
```

---

### 4. Configure NAT (Network Address Translation)

This allows devices on VLAN 10 to access the internet through the WLAN gateway:

```bash
# Define inside interface (switch side)
Router(config)# interface gi0/1.10
Router(config-subif)# ip nat inside
Router(config-subif)# exit

# Define outside interface (WLAN gateway side)
Router(config)# interface gi0/0
Router(config-if)# ip nat outside
Router(config-if)# exit

# Create access list for NAT
Router(config)# access-list 10 permit 192.168.10.0 0.0.0.255

# Configure NAT overload (PAT)
Router(config)# ip nat inside source list 10 interface gi0/0 overload
```

---

### 5. Configure DHCP Server for VLAN 10 (Optional)

If you want the router to provide DHCP to devices on VLAN 10:

```bash
# Exclude router and switch IPs from DHCP pool
Router(config)# ip dhcp excluded-address 192.168.10.1 192.168.10.10

# Create DHCP pool for VLAN 10
Router(config)# ip dhcp pool VLAN10
Router(dhcp-config)# network 192.168.10.0 255.255.255.0
Router(dhcp-config)# default-router 192.168.10.1
Router(dhcp-config)# dns-server 8.8.8.8 8.8.4.4
Router(dhcp-config)# lease 7
Router(dhcp-config)# exit
```

---

### 6. Configure Basic Security

```bash
# Set hostname
Router(config)# hostname Gateway-R1

# Set enable password
Gateway-R1(config)# enable secret YourEnablePassword

# Configure console password
Gateway-R1(config)# line console 0
Gateway-R1(config-line)# password YourConsolePassword
Gateway-R1(config-line)# login
Gateway-R1(config-line)# logging synchronous
Gateway-R1(config-line)# exit

# Configure VTY (Telnet/SSH) password
Gateway-R1(config)# line vty 0 15
Gateway-R1(config-line)# password YourVTYPassword
Gateway-R1(config-line)# login
Gateway-R1(config-line)# exit

# Set banner
Gateway-R1(config)# banner motd # Unauthorized access prohibited #
```

---

### 7. Save Configuration

```bash
Gateway-R1(config)# exit
Gateway-R1# write memory
# or
Gateway-R1# copy running-config startup-config
```

---

## Complete Configuration Example

```bash
Router> enable
Router# configure terminal

# Configure hostname
Router(config)# hostname Gateway-R1

# Configure GE 0/1 (switch side)
Gateway-R1(config)# interface gi0/1
Gateway-R1(config-if)# description Connection to Switch Port 24
Gateway-R1(config-if)# no shutdown
Gateway-R1(config-if)# exit

# Configure VLAN 10 subinterface
Gateway-R1(config)# interface gi0/1.10
Gateway-R1(config-subif)# description VLAN 10 Gateway
Gateway-R1(config-subif)# encapsulation dot1Q 10
Gateway-R1(config-subif)# ip address 192.168.10.1 255.255.255.0
Gateway-R1(config-subif)# ip nat inside
Gateway-R1(config-subif)# no shutdown
Gateway-R1(config-subif)# exit

# Configure GE 0/0 (WLAN gateway side) - Using DHCP
Gateway-R1(config)# interface gi0/0
Gateway-R1(config-if)# description Connection to WLAN Gateway
Gateway-R1(config-if)# ip address dhcp
Gateway-R1(config-if)# ip nat outside
Gateway-R1(config-if)# no shutdown
Gateway-R1(config-if)# exit

# Configure NAT
Gateway-R1(config)# access-list 10 permit 192.168.10.0 0.0.0.255
Gateway-R1(config)# ip nat inside source list 10 interface gi0/0 overload

# Configure DHCP for VLAN 10
Gateway-R1(config)# ip dhcp excluded-address 192.168.10.1 192.168.10.10
Gateway-R1(config)# ip dhcp pool VLAN10
Gateway-R1(dhcp-config)# network 192.168.10.0 255.255.255.0
Gateway-R1(dhcp-config)# default-router 192.168.10.1
Gateway-R1(dhcp-config)# dns-server 8.8.8.8 8.8.4.4
Gateway-R1(dhcp-config)# exit

# Save configuration
Gateway-R1(config)# exit
Gateway-R1# write memory
```

---

## Verification Commands

### Check Interface Status
```bash
Gateway-R1# show ip interface brief
```

### Check Routing Table
```bash
Gateway-R1# show ip route
```

### Check NAT Configuration
```bash
Gateway-R1# show ip nat translations
Gateway-R1# show ip nat statistics
```

### Check DHCP Bindings
```bash
Gateway-R1# show ip dhcp binding
Gateway-R1# show ip dhcp pool
```

### Test Connectivity from Router
```bash
# Ping switch
Gateway-R1# ping 192.168.10.2

# Ping WLAN gateway
Gateway-R1# ping 192.168.1.1

# Ping internet (test NAT)
Gateway-R1# ping 8.8.8.8
```

### Check Subinterface Configuration
```bash
Gateway-R1# show interfaces gi0/1.10
Gateway-R1# show vlans
```

---

## Troubleshooting

### No Connectivity to Switch
```bash
# Check if interface is up
Gateway-R1# show interface gi0/1
Gateway-R1# show interface gi0/1.10

# Check VLAN encapsulation
Gateway-R1# show interfaces gi0/1.10 | include encapsulation

# Check if switch port 24 is trunk
# On switch:
Switch# show interface gi0/24 switchport
```

### No Connectivity to Internet
```bash
# Check if GE 0/0 has IP address
Gateway-R1# show interface gi0/0

# Check routing table
Gateway-R1# show ip route

# Check NAT
Gateway-R1# show ip nat translations
Gateway-R1# debug ip nat
```

### DHCP Not Working
```bash
# Check DHCP pool
Gateway-R1# show ip dhcp pool

# Check for DHCP bindings
Gateway-R1# show ip dhcp binding

# Check DHCP server status
Gateway-R1# show ip dhcp server statistics

# Enable DHCP debugging
Gateway-R1# debug ip dhcp server events
```

### Devices Can't Reach Internet
1. Verify NAT is configured correctly
2. Check default route exists
3. Verify DNS servers are reachable
4. Test ping from router first, then from end devices

---

## Alternative Configuration (Without Trunk)

If you prefer to configure GE 0/1 without using 802.1Q trunking (and reconfigure switch port 24 as access port):

```bash
# Router configuration
Router> enable
Router# configure terminal
Router(config)# interface gi0/1
Router(config-if)# description Connection to Switch Port 24
Router(config-if)# ip address 192.168.10.1 255.255.255.0
Router(config-if)# ip nat inside
Router(config-if)# no shutdown
Router(config-if)# exit
```

**Then on the switch, change port 24 to access mode:**
```bash
Switch# configure terminal
Switch(config)# interface gi0/24
Switch(config-if)# switchport mode access
Switch(config-if)# switchport access vlan 10
Switch(config-if)# exit
```

---

## Notes

- The router acts as the default gateway for VLAN 10 (192.168.10.1)
- NAT allows devices on 192.168.10.0/24 to access internet via WLAN gateway
- DHCP server assigns IPs to devices connected to switch ports 1-3
- Adjust IP addresses based on your WLAN gateway's network scheme
- If WLAN gateway is on 192.168.1.0/24, GE 0/0 should be in that subnet
- Make sure there's no IP conflict between VLAN 10 network and WLAN gateway network

