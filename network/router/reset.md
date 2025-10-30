# Cisco Router Complete Reset

## Quick Reset Commands

### Connect via console cable, then run:

```bash
Router> enable
Router# write erase
Router# reload
```

**When prompted:**
1. "Save? [yes/no]:" → Type **no** and press Enter
2. "Proceed with reload? [confirm]" → Press **Enter**

---

## Detailed Step-by-Step

### 1. Enter Privileged Mode
```bash
Router> enable
```

### 2. Erase Startup Configuration
```bash
Router# write erase
```

**Alternative commands (all do the same thing):**
```bash
Router# erase startup-config
Router# erase nvram:
```

When prompted:
```
Erasing the nvram filesystem will remove all configuration files! Continue? [confirm]
```
Press **Enter** to confirm.

Expected output:
```
[OK]
Erase of nvram: complete
```

### 3. Delete VLAN Database (if using VLANs)
```bash
Router# delete vlan.dat
```

Or force delete without confirmation:
```bash
Router# delete /force vlan.dat
```

### 4. Reload the Router
```bash
Router# reload
```

**Important:** You will see TWO prompts:

**First prompt - Save configuration:**
```
System configuration has been modified. Save? [yes/no]:
```
Type **no** and press Enter.

**Second prompt - Confirm reload:**
```
Proceed with reload? [confirm]
```
Press **Enter** to confirm.

### 5. Wait for Reboot
- Router will restart (2-5 minutes)
- All configuration will be cleared
- Router returns to factory defaults

---

## After Reset

### Skip Initial Setup Dialog
When router boots, you'll see:
```
Would you like to enter the initial configuration dialog? [yes/no]:
```

Type **no** and press Enter.

```
Would you like to terminate autoinstall? [yes]:
```

Press Enter (or type **yes**).

### Access Fresh Router
```bash
Router> enable
Router# configure terminal
Router(config)#
```

Router is now completely cleared and ready for fresh configuration!

---
