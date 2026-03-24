# SSH Access Guide

**Setup:** Laptop connected directly to Pi via Ethernet cable (no Wi-Fi needed)

[[SSH - Secure Shell]]

---
## Overview

This guide covers how to SSH into a QNX-installed Raspberry Pi 5 from a Linux laptop using a **direct Ethernet connection** — no router or Wi-Fi required.

### Final Architecture
```
Pi ──[ Ethernet ]── Laptop ──[ Wi-Fi ]── Internet
192.168.2.2          192.168.2.1
```

## Prerequisites

- Raspberry Pi 5 with QNX installed
- Laptop running Linux
- Ethernet cable connecting Pi directly to laptop

---

## Step 1 — Assign a Static IP on the Laptop

Find your Ethernet interface name:
```bash
ip addr
```
Look for an interface like `eno1`, `eth0`, or `enp3s0` that is **not** `lo` (loopback) or `wlo1` (Wi-Fi).

Assign a static IP temporarily (to test):
```bash
sudo ip addr add 192.168.2.1/24 dev eno1
sudo ip link set eno1 up
```

### Make it Permanent (survives reboot)

Find your connection name:
```bash
sudo nmcli connection show
```
Look for the `ethernet` type entry (e.g. `Wired connection 1`).

Make it permanent:
```bash
sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.2.1/24 ipv4.method manual
sudo nmcli connection up "Wired connection 1"
```

---

## Step 2 — Assign a Static IP on the Pi

> **Do this on the Pi's monitor/keyboard directly.**

```bash
ifconfig cgem0 192.168.2.2 netmask 255.255.255.0
```

Verify it worked:
```bash
ifconfig cgem0
```
You should see `inet 192.168.2.2` in the output.

### Make it Permanent (survives reboot)

The static IP needs to be set before SSH starts at boot. Edit the SSH startup script:

```bash
su root
sed -i 's|/usr/bin/sshd|ifconfig cgem0 192.168.2.2 netmask 255.255.255.0\n/usr/bin/sshd|' /system/etc/startup/startup_ssh.sh
```

Verify the file looks correct:
```bash
cat /system/etc/startup/startup_ssh.sh
```

The last two lines should be:
```sh
ifconfig cgem0 192.168.2.2 netmask 255.255.255.0
/usr/bin/sshd -f /etc/ssh/sshd_config -D
```

---

## Step 3 — SSH into the Pi

From your laptop:
```bash
ssh qnxuser@192.168.2.2
```

Default credentials:

| Field         | Value     |
| ------------- | --------- |
| Username      | `qnxuser` |
| Password      | `qnxuser` |
| Root password | `root`    |

---

## Reboot the Pi

QNX does **not** have the standard `reboot` command. Options:

```bash
/proc/boot/shutdown
```

Or simply **physically unplug and replug the power**.

---

## Plug and Play Checklist

After completing this guide, every boot should work as follows:

- Plug in Ethernet cable between Pi and laptop
- Power on the Pi
-  Wait ~30 seconds
- `ssh qnxuser@192.168.2.2` from laptop 

---

## Troubleshooting

### SSH hangs / no response
Check if `sshd` is running on the Pi (via monitor):
```bash
pidin | grep sshd
```
If nothing shows, start it manually:
```bash
/usr/bin/sshd -f /etc/ssh/sshd_config -D &
```

### Ping fails (100% packet loss)
The IP on either side may not be set. Re-run:
- On laptop: `sudo ip addr add 192.168.2.1/24 dev eno1`
- On Pi: `ifconfig cgem0 192.168.2.2 netmask 255.255.255.0`

### `169.254.x.x` address on Pi
This is a self-assigned fallback IP — it means the Pi didn't get a proper IP. Manually set it as above.

### `Name or service not known` error
You're using a hostname like `qnxpi.local` that isn't resolving. Always use the direct IP `192.168.2.2` instead.

---

## Key QNX Differences from Linux

| Linux Command | QNX Equivalent |
|--------------|----------------|
| `ps` | `pidin` |
| `reboot` | `/proc/boot/shutdown` or unplug power |
| `ifconfig` | `ifconfig` (same, but interface names differ: `cgem0`, `bcm0`) |
| `neofetch` | Not available |
| `apt/yum` | Not available (QNX uses its own package system) |

---

## Network Interface Reference (Raspberry Pi 5 / QNX)

| Interface | Type | Notes |
|-----------|------|-------|
| `cgem0` | Ethernet (Gigabit) | Use this for SSH |
| `bcm0` | Wi-Fi | Requires `wpa_supplicant` config |
| `bcm1` | Wi-Fi (secondary) | |
| `bcm_p2pdev2` | Wi-Fi P2P | |

---

## File Locations Reference

| Purpose | Path |
|---------|------|
| SSH startup script | `/system/etc/startup/startup_ssh.sh` |
| Boot startup script | `/system/etc/st_boot.sh` |
| User profile (login) | `/etc/profile` |
| SSH config | `/etc/ssh/sshd_config` |
| Wi-Fi config | `/etc/wpa_supplicant.conf` (on SD card boot partition) |
| Startup scripts dir | `/system/etc/startup/` |
| Boot binaries | `/proc/boot/` |

Sources:
https://claude.ai/share/5a3ee1bb-c868-4172-a67a-c926b40a87c4

#linux #qnx 