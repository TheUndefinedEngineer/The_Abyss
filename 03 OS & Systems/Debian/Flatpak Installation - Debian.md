## Install Flatpak

A flatpak package is available in Debian 10 (Buster) and newer. To install it, run the following as root:
```bash
sudo apt install flatpak
``` 
## Install the Software Flatpak plugin

If you are running GNOME, it is also a good idea to install the Flatpak plugin for GNOME Software. To do this, run:
```bash
sudo apt install gnome-software-plugin-flatpak
```

If you are running KDE, you should instead install the Plasma Discover Flatpak backend:
```bash
sudo apt install plasma-discover-backend-flatpak
```
## Add the Flathub repository
Flathub is the best place to get Flatpak apps. To enable it, download and install the  or run the following in a terminal:
```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
## Restart
To complete setup, restart your system. Now all you have to do is [install apps](https://flathub.org/)!

Just use the discovery app. It was preinstalled.
- Installed OBS with it.

Source:
https://flatpak.org/setup/Debian

#linux