### 1. Install required packages

```bash
sudo apt update  
sudo apt install build-essential linux-headers-$(uname -r)
```
### 2. Verify headers installed

```bash
ls /lib/modules/$(uname -r)/build
```

If this shows a directory → good  
If not → headers didn’t install properly

### 3. Run VMware module build
```bash
sudo /usr/bin/vmware-modconfig --console --install-all
```

### Fix option (very common)
```bash
sudo apt install git  
git clone https://github.com/mkubecek/vmware-host-modules.git  
cd vmware-host-modules  
git checkout workstation-17.6.3  
make  
sudo make install
```
Then run:
```bash
sudo vmware-modconfig --console --install-all
```

Sources:
1. Guide: https://www.if-not-true-then-false.com/2024/debian-vmware-install/#11-download-vmware-workstation-pro
2. VMware Workstation Pro: https://knowledge.broadcom.com/external/article?articleNumber=344595
3. Versions: https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true
4. ChatGPT: https://chatgpt.com/share/69c14de5-b0c8-8002-940e-b1d57dc29099

#linux 