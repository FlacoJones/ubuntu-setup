# Basic Cisco Switch Commands

## 1. Enter Privileged EXEC Mode
```
Switch> enable
```

## 2. Enter Global Configuration Mode
```
Switch# configure terminal
```

## 3. Set Switch Hostname
```
Switch(config)# hostname SW1
```

## 4. Set Enable Password
```
SW1(config)# enable secret <password>
```

## 5. Configure Console Password
```
SW1(config)# line console 0
SW1(config-line)# password <password>
SW1(config-line)# login
SW1(config-line)# exit
```

## 6. Configure VLAN Interface (SVI)
```
SW1(config)# interface vlan 1
SW1(config-if)# ip address 192.168.1.2 255.255.255.0
SW1(config-if)# no shutdown
```

## 7. Configure Access Port
```
SW1(config)# interface gi0/1
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
```

## 8. Configure Trunk Port
```
SW1(config)# interface gi0/24
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk allowed vlan all
```

## 9. View VLAN Information
```
SW1# show vlan brief
```

## 10. View MAC Address Table
```
SW1# show mac address-table
```

## 11. Save Configuration
```
SW1# copy running-config startup-config
```
or
```
SW1# write memory
```

## 12. Exit Configuration Mode
```
SW1(config)# exit
SW1# exit
```

