Add this to /etc/nixos/configuration:
```bash
environment.systemPackages = with pkgs; [ 
	rpi-imager 
];
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

That's it! It will run normally.

Tags: #linux 