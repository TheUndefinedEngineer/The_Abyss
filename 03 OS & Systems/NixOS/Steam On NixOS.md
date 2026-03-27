To install Steam on NixOS, add the following configuration to your `/etc/nixos/configuration.nix`:
```ini
programs.steam = {
  enable = true;
  gamescopeSession.enable = true; # Optional: enables features like resolution upscaling
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  localNetworkGameTransfers.openFirewall = true;
};   
```

After adding this, rebuild your system configuration:
```bash
sudo nixos-rebuild boot
```

Tags: #linux #guide 