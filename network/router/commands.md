# Basic Cisco Router Commands

## 1. Enter Privileged EXEC Mode
```
Router> enable
```

## 2. Enter Global Configuration Mode
```
Router# configure terminal
```

## 3. Set Router Hostname
```
Router(config)# hostname R1
```

## 4. Set Enable Password
```
R1(config)# enable secret <password>
```

## 5. Configure Console Password
```
R1(config)# line console 0
R1(config-line)# password <password>
R1(config-line)# login
R1(config-line)# exit
```

## 6. Configure Interface IP Address
```
R1(config)# interface gi0/0
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown
```

## 7. View Running Configuration
```
R1# show running-config
```

## 8. View Interface Status
```
R1# show ip interface brief
```

## 9. Save Configuration
```
R1# copy running-config startup-config
```
or
```
R1# write memory
```

## 10. Set Banner Message
```
R1(config)# banner motd # Unauthorized access prohibited #
```

## 11. Configure Static Route
```
R1(config)# ip route <destination-network> <subnet-mask> <next-hop-ip>
```

## 12. Exit Configuration Mode
```
R1(config)# exit
R1# exit
```


