Last updated: 2026-02-26
System: NixOS
## Checking Monitors

To check monitor name(s):
```bash
hyprctl monitors
```

It will typically show monitor name(s) like:
```bash
Monitor eDP-1 (Laptop)
Monitor HDMI-A-1 (External)
```

## Scaling Monitors

The first issue I faced was scaling on the external display (Samsung 32' 4K).
- 4K = 3840x2160
- Scaling = 1.25 / 1.5 (1.5 looks better for me)

To change it:
```bash
sudo nano ~/.config/hypr/hyprland.conf
```

In the config file add:
```ini
monitor = HDMI-A-1,3840x2160@60,0x0,1
```
- Monitor name
- Monitor resolution with Refresh rate
- Position
- Scale

As both the monitors are on there is need for fractional scaling of apps:
```ini
env = XCURSOR_SIZE,24
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_SCALE_FACTOR,1
env = GDK_SCALE,1
env = GDK_DPI_SCALE,1
```


## Turning off  Monitor

I couldn't figure about how to make `second screen only` work but to turn it off manually.
```ini
monitor = eDP-1,disable
```
- This turned off my laptop screen completely and didn't show anything if I disconnected HDMI.



#linux 