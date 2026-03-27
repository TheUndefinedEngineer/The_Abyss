*27/03/2026*
## 1. Identify the SD Card
```bash
lsblk
```
Look for your SD card, typically `/dev/sdb`. Double check the size to confirm.

---
## 2. Unmount the Card
```bash
sudo umount /dev/sdb*
```

---
## 3. Create a New Partition Table

### FAT32 (Recommended for RPi boot)
```bash
sudo fdisk /dev/sdb
```

Inside fdisk:

| Key | Action |
|---|---|
| `o` | New DOS partition table |
| `n` | New partition |
| `p` | Primary partition |
| `1` | Partition number |
| `Enter` | Default first sector |
| `Enter` | Default last sector |
| `t` | Change partition type |
| `c` | W95 FAT32 (LBA) |
| `w` | Write changes and exit |

---
## 4. Format the Partition

### FAT32
```bash
sudo mkfs.vfat -F 32 /dev/sdb1
```

### ext4 (Linux native, good for data partitions)
```bash
sudo mkfs.ext4 /dev/sdb1
```

### exFAT (Large files, cross-platform)
```bash
sudo mkfs.exfat /dev/sdb1
```

### NTFS (Windows compatible)
```bash
sudo mkfs.ntfs /dev/sdb1
```

| Format | Max File Size | Best For |
|---|---|---|
| FAT32 | 4GB | Boot partitions, RPi |
| ext4 | 16TB | Linux data partitions |
| exFAT | 16EB | Large files, cross-platform |
| NTFS | 16EB | Windows compatibility |

---
## 5. Mount the SD Card
```bash
sudo mkdir /mnt/pi
sudo mount /dev/sdb1 /mnt/pi
```

---
## 6. Copy Boot Files
```bash
sudo cp -r /path/to/boot/files/* /mnt/pi/
```

---
## 7. Safely Unmount
```bash
sudo umount /mnt/pi
```
Always unmount before physically removing the card to avoid corruption.

---
## 8. Verify (Optional)
```bash
lsblk -f
```
Confirms the partition type and mount point.

> [!warning]
> Always double check `/dev/sdb` is your SD card and not another drive before running fdisk. Wrong device will wipe that disk.

Tags: #linux #guide 