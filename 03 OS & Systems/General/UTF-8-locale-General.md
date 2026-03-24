# Setting UTF-8 Locale: General Guide

UTF-8 is the most widely used character encoding, supporting virtually all characters from every language. This guide covers UTF-8 configuration for macOS, Windows, Docker, and common applications and services.

> **Linux / Unix users:** See the companion guide [[UTF-8-locale-Linux]].

---

## Table of Contents

1. [macOS](#macos)
2. [Windows](#windows)
3. [Docker & Containers](#docker--containers)
4. [Application-Level Settings](#application-level-settings)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Quick Reference](#quick-reference)

---

## macOS

### Check Current Locale

```bash
locale
```

### Set via System Settings (GUI)

1. Open **System Settings** → **General** → **Language & Region**
2. Set your preferred language and region
3. macOS uses UTF-8 by default for most locales

### Set via Terminal

Add to `~/.zshrc` (default shell on modern macOS) or `~/.bash_profile`:

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

Then reload:

```bash
source ~/.zshrc
```

> **Note:** macOS defaults to UTF-8 in most cases. Issues typically arise in legacy or third-party terminal applications.

---

## Windows

### Set System Locale (GUI)

1. Open **Control Panel** → **Region**
2. Go to the **Administrative** tab
3. Click **Change system locale…**
4. Select your preferred locale
5. Check **Beta: Use Unicode UTF-8 for worldwide language support** (Windows 10/11)
6. Restart your computer

### Set via PowerShell

```powershell
# Check current settings
Get-WinSystemLocale

# Set system locale
Set-WinSystemLocale -SystemLocale en-US
```

### Enable UTF-8 in Windows Terminal / CMD

```cmd
REM Set code page to UTF-8 for the current session
chcp 65001
```

To make it permanent, add `chcp 65001` to your startup scripts or set it in the Registry:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Nls\CodePage
ACP = 65001
```

### Git Bash / WSL

For Git Bash, add to `~/.bashrc`:

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

WSL (Windows Subsystem for Linux) follows the Linux guide.

---

## Docker & Containers

### Dockerfile

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US:en
```

### docker-compose.yml

```yaml
services:
  app:
    image: my-app
    environment:
      - LANG=en_US.UTF-8
      - LC_ALL=en_US.UTF-8
```

---

## Application-Level Settings

### Python

```python
import locale
locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')

# Or ensure UTF-8 I/O
import sys
sys.stdout.reconfigure(encoding='utf-8')
```

### Java

```bash
java -Dfile.encoding=UTF-8 -jar myapp.jar
```

Or set in environment:

```bash
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
```

### MySQL / MariaDB

```sql
SET NAMES 'utf8mb4';
SET CHARACTER SET utf8mb4;
```

In `my.cnf`:

```ini
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
```

### PostgreSQL

```sql
-- Check encoding
SHOW server_encoding;

-- Set client encoding
SET client_encoding TO 'UTF8';
```

### Nginx

```nginx
charset utf-8;
```

### Apache

```apache
AddDefaultCharset UTF-8
```

---

## Verification

### Test UTF-8 Encoding (macOS / Linux terminal)

```bash
echo "Hello, 世界! Héllo Wörld! مرحبا" | cat
```

If characters display correctly, UTF-8 is working.

### Check File Encoding

```bash
file -i myfile.txt
# Expected: myfile.txt: text/plain; charset=utf-8
```

### Windows — Check Active Code Page

```cmd
chcp
REM Should return: Active code page: 65001
```

---

## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| Garbled characters in terminal | Terminal not set to UTF-8 | Set terminal emulator encoding to UTF-8 |
| Python `UnicodeDecodeError` | System locale not UTF-8 | Set `PYTHONIOENCODING=utf-8` |
| Docker container garbled output | Missing locale in image | Add `locale-gen` to Dockerfile |
| Windows CMD garbled output | Wrong code page | Run `chcp 65001` |
| macOS terminal shows `?` boxes | Font missing glyphs | Switch to a Unicode-complete font (e.g., Menlo, SF Mono) |

---

## Quick Reference

```bash
# macOS: Add to shell profile
echo 'export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8' >> ~/.zshrc && source ~/.zshrc

# Windows CMD: Enable UTF-8 for session
chcp 65001

# Docker: Set in Dockerfile
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Python: Force UTF-8 output
export PYTHONIOENCODING=utf-8

# Java: Force UTF-8
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
```

---

*UTF-8 encodes over 1.1 million Unicode characters and is backward-compatible with ASCII — making it the universal standard for modern text encoding.*

Sources:
https://claude.ai/share/d8d04f48-6247-4413-83a6-69ee3eb0c4a5

#general 
