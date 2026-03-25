lsblk

/dev/sdb

Unmount the card
sudo umount /dev/sdb*

# Create a new partition table
sudo fdisk /dev/sdb

o   → new DOS partition table
n   → new partition
p   → primary
1   → partition number
ENTER
ENTER
t   → change type
c   → W95 FAT32 (LBA)
w   → write changes

Format the partition
sudo mkfs.vfat -F 32 /dev/sdb1
Now the SD card has a **FAT32 boot partition**.

# Mount it

sudo mkdir /mnt/pi  
sudo mount /dev/sdb1 /mnt/pi

#linux #todo 