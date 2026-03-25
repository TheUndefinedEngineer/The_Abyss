## Required Hardware:
 - PI 4 or 5 with 8 GB or more RAM
 - Wired/USB Keyboard & Mouse
 - HDMI cable
 
 ## Install the image package for your target, which contains the QNX OS QSTI:
    - Raspberry Pi 4 — com.qnx.qnx800.quickstart.rpi4
    - Raspberry Pi 5 — com.qnx.qnx800.quickstart.rpi5

## Steps to Install Image

*I am installing for pi-5 and similar process for pi-4*

- Open QNX software centre.
- Select qnx800
- Then manage installation
- Search in filter with `com.qnx.qnx800.quickstart.rpi5`
- Download it.

Go to `qnx800/images/rpi5`:
```bash
chmod +x unpack_rpi5_image.sh
./unpack_rpi5_image.sh
```

It will create another `rpi5` folder and that folder has the image: `rpi5.img`.

Using `rpi-imager` flash the image -> [[rpi-imager on NixOS]] 

Sources:
https://www.qnx.com/developers/docs/qnxeverywhere/com.qnx.doc.target_images/topic/qsti/intro.html

Tags: #linux #qnx 