# Basic Router Configuration for WLAN Gateway

This guide configures a fresh Cisco router to connect to an upstream WLAN gateway for internet access.

## Prerequisites
- Fresh/cleared Cisco router
- Console cable connection to router
- WLAN gateway router providing internet (with DHCP)
- Ethernet cable from router gi0/0 to WLAN gateway

---

## Configuration Steps

### 1. Initial Setup

```bash
Router> enable
Router# configure terminal

# Set hostname (optional but recommended)
Router(config)# hostname R1
```

### 2. Configure gi0/0 for WLAN Gateway Connection

**Option A: Using DHCP (Recommended)**

```bash
R1(config)# interface gi0/0
R1(config-if)# description Connection to WLAN Gateway
R1(config-if)# ip address dhcp
R1(config-if)# no shutdown
R1(config-if)# exit
```

**Option B: Using Static IP**

```bash
R1(config)# interface gi0/0
R1(config-if)# description Connection to WLAN Gateway
R1(config-if)# ip address 192.168.1.100 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit

# Add default route (replace 192.168.1.254 with your WLAN gateway IP)
R1(config)# ip route 0.0.0.0 0.0.0.0 192.168.1.254
```

### 3. Configure DNS (Optional)

```bash
R1(config)# ip name-server 8.8.8.8 8.8.4.4
R1(config)# ip domain-lookup
```

### 4. Save Configuration

```bash
R1(config)# exit
R1# write memory
```

---

## Verification Commands

### Check Interface Status

```bash
R1# show ip interface brief
```

**Expected output:**
```
Interface              IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0     192.168.1.X     YES DHCP   up                    up
```

### Check DHCP Lease (if using DHCP)

```bash
R1# show dhcp lease
```

**Look for:**
- IP address assigned
- Gateway/Router IP (your WLAN gateway)
- DNS servers

### Check Routing Table

```bash
R1# show ip route
```

**Expected output should include:**
```
Gateway of last resort is 192.168.1.X to network 0.0.0.0

S*    0.0.0.0/0 [254/0] via 192.168.1.X
      192.168.1.0/24 is variably subnetted, 2 subnets, 2 masks
C        192.168.1.0/24 is directly connected, GigabitEthernet0/0
L        192.168.1.X/32 is directly connected, GigabitEthernet0/0
```

### Check ARP Table

```bash
R1# show arp
```

**Expected:** Should see WLAN gateway IP with a MAC address (not "Incomplete")

### Check Interface Details

```bash
R1# show interface gi0/0
```

**Look for:**
- `GigabitEthernet0/0 is up, line protocol is up`
- `Internet address is X.X.X.X/24`
- `0 input errors, 0 CRC, 0 frame`
- `0 output errors`

---

## Test Connectivity

### Step 1: Ping Gateway (from DHCP lease or manual config)

```bash
# Replace with your actual WLAN gateway IP
R1# ping 192.168.1.254
```

**Expected:** 5/5 successful pings

### Step 2: Ping Public DNS

```bash
R1# ping 8.8.8.8
```

**Expected:** Should succeed

### Step 3: Test DNS Resolution

```bash
R1# ping cisco.com
```

**Note:** Some domains may not respond to ping (ICMP) but DNS resolution should work

---

## Troubleshooting

### Interface is Down

```bash
R1# configure terminal
R1(config)# interface gi0/0
R1(config-if)# no shutdown
R1(config-if)# exit
R1(config)# exit
```

### No IP Address from DHCP

```bash
R1# configure terminal
R1(config)# interface gi0/0
R1(config-if)# no ip address dhcp
R1(config-if)# ip address dhcp
R1(config-if)# exit
R1(config)# exit

# Wait 10-30 seconds, then check
R1# show ip interface brief
```

### Gateway ARP is Incomplete

**Find the actual gateway IP:**

```bash
R1# show dhcp lease
```

Look at the "Router" or "Gateway" field - this is your actual WLAN gateway IP.

**Verify you can reach it:**

```bash
# Try pinging the DHCP server IP (often the gateway)
R1# show dhcp lease | include server
R1# ping <DHCP-server-IP>
```

### No Default Route

**With DHCP, default route should be automatic. If missing:**

```bash
# Get gateway IP from DHCP lease first
R1# show dhcp lease

# Then add static default route
R1# configure terminal
R1(config)# ip route 0.0.0.0 0.0.0.0 <gateway-ip>
R1(config)# exit
```

### Can Ping 8.8.8.8 but Not Other IPs

This is **often normal**:
- WLAN gateway may have firewall rules
- Some destinations block ICMP ping
- As long as 8.8.8.8 works, internet routing is functional

**Test with actual traffic instead:**
```bash
# Test from a device behind the router (not from router itself)
```

---

## Complete Configuration Example

```bash
Router> enable
Router# configure terminal
Router(config)# hostname R1

# Configure WAN interface
R1(config)# interface gi0/0
R1(config-if)# description Connection to WLAN Gateway
R1(config-if)# ip address dhcp
R1(config-if)# no shutdown
R1(config-if)# exit

# Configure DNS
R1(config)# ip name-server 8.8.8.8 8.8.4.4
R1(config)# ip domain-lookup

# Enable IP routing (usually enabled by default)
R1(config)# ip routing

# Save configuration
R1(config)# exit
R1# write memory
```

---

## Quick Verification Checklist

- [ ] `show ip interface brief` - gi0/0 is up/up with IP
- [ ] `show dhcp lease` - Shows gateway and DNS servers
- [ ] `show ip route` - Has default route (0.0.0.0/0)
- [ ] `show arp` - Gateway IP shows MAC address (not Incomplete)
- [ ] `ping <gateway-ip>` - Works
- [ ] `ping 8.8.8.8` - Works

If all checks pass, your router is connected to the internet! ✅

---

## Next Steps

After confirming WLAN connectivity works, you can:
1. Configure internal interfaces (gi0/1) for LAN
2. Set up VLANs and subinterfaces
3. Configure NAT for internal networks
4. Set up DHCP server for internal devices

See `gateway.md` for complete gateway configuration including switch connectivity.

---

## Notes

- DHCP is recommended for simplicity unless you need a static IP
- The router gets its IP from the WLAN gateway's DHCP server
- Default route is automatically configured with DHCP
- Some ICMP (ping) traffic may be blocked by WLAN gateway firewall - this is normal
- Router management (SSH/Telnet) should be configured separately for security

