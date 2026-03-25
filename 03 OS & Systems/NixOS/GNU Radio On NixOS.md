## Issue(1) faced: Icon not visible in launcher but open through CLI.

Create own desktop entry:
```bash
mkdir -p ~/.local/share/applications
nano ~/.local/share/applications/gnuradio-companion.desktop
```

Add this into the `.desktop`:
```ini
[Desktop Entry]
Name=GNU Radio Companion
Comment=Signal Processing Flowgraph Tool
Exec=gnuradio-companion
Icon=gnuradio
Terminal=false
Type=Application
Categories=Development;Electronics;
```

Verify with:
```bash
ls ~/.local/share/applications
```

## Issue(2) faced: Now desktop icon is present but no logo.

Find icon path using:
```bash
find /nix/store -iname "*gnuradio*.png" 2>/dev/null
```

It will we show something like:
```bash
/nix/store/bkrlz648r78c8847ldv0x7gi7jpj9k5z-gnuradio-3.10.12.0/share/gnuradio/examples/qt-gui/gnuradio_logo.png  
/nix/store/bkrlz648r78c8847ldv0x7gi7jpj9k5z-gnuradio-3.10.12.0/share/doc/gnuradio-3.10.12.0/html/gnuradio_logo_icon.png  
/nix/store/bkrlz648r78c8847ldv0x7gi7jpj9k5z-gnuradio-3.10.12.0/lib/python3.13/site-packages/gnuradio/grc/gui_qt/resources/logo/gnuradio_logo_icon-square.png  
/nix/store/kw95qqva553fng90ny5bv4dk65df3cxs-gnuradio-wrapped-3.10.12.0/share/gnuradio/examples/qt-gui/gnuradio_logo.png  
/nix/store/kw95qqva553fng90ny5bv4dk65df3cxs-gnuradio-wrapped-3.10.12.0/share/doc/gnuradio-3.10.12.0/html/gnuradio_logo_icon.png  
/nix/store/kw95qqva553fng90ny5bv4dk65df3cxs-gnuradio-wrapped-3.10.12.0/lib/python3.13/site-packages/gnuradio/grc/gui_qt/resources/logo/gnuradio_logo_icon-square  
.png
```

Chose the last option and updated `.desktop`:
```bash
ICON=/nix/store/kw95qqva553fng90ny5bv4dk65df3cxs-gnuradio-wrapped-3.10.12.0/lib/python3.13/site-packages/gnuradio/grc/gui_qt/resources/logo/gnuradio_logo_icon-square  
.png
```

And it works after a restart!

Tags: #linux 