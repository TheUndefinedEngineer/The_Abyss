*12-05-2026* 

## Problem

Windows doesn't appear in the GRUB boot menu after installing Windows **after** Linux.

---
## Why This Happens

Debian disables `os-prober` by default to avoid issues with virtual machines. Without it, GRUB won't scan for other operating systems on your drive.

---
## Fix

### Step 1 — Enable os-prober

Edit the GRUB configuration file:
```bash
sudo nano /etc/default/grub
```

Add this line at the bottom:
```
GRUB_DISABLE_OS_PROBER=false
```

Save and exit (`Ctrl+O`, `Ctrl+X`).

### Step 2 — Scan for other OSes

```bash
sudo os-prober
```

Expected output:
```
/dev/nvme0n1p1@/EFI/Microsoft/Boot/bootmgfw.efi:Windows Boot Manager:Windows:efi
```

If Windows is found, proceed to the next step.

### Step 3 — Regenerate GRUB config

bash

```bash
sudo update-grub
```

You should see:
```
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/...
```

### Step 4 — Reboot

```bash
sudo reboot
```

Windows should now appear in the GRUB menu.

---
## Insights

- This fix is **persistent** — no need to redo it after kernel updates.
- `os-prober` works by mounting partitions and scanning for bootloaders.
- If Windows still doesn't show, make sure Windows is installed in **UEFI mode** (not legacy/MBR).


---
## !
Sources:
1. Fix by claude

Tags: #guide #linux 