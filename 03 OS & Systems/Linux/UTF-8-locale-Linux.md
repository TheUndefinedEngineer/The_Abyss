# Setting UTF-8 Locale on Linux / Unix

UTF-8 is the most widely used character encoding, supporting virtually all characters from every language. This guide covers how to set and persist a UTF-8 locale on Linux and Unix systems.

---
## Table of Contents

1. [What is a Locale?](#what-is-a-locale)
2. [Check Current Locale](#1-check-current-locale)
3. [List Available Locales](#2-list-available-locales)
4. [Generate a Locale](#3-generate-a-locale-if-not-available)
5. [Set System-Wide Locale](#4-set-the-system-wide-locale)
6. [Set for Current Session](#5-set-for-current-session-only)
7. [Persist for a User](#6-persist-for-a-user)
8. [Verification](#verification)
9. [Troubleshooting](#troubleshooting)

---
## What is a Locale?

A **locale** defines the language, region, and character encoding used by the operating system and applications. It controls:

- Date and time formatting
- Number and currency formatting
- Character classification and sorting
- Text encoding (e.g., UTF-8)

A UTF-8 locale typically looks like: `en_US.UTF-8`, `en_GB.UTF-8`, `de_DE.UTF-8`, etc.

---
## 1. Check Current Locale

```bash
locale
```

---
## 2. List Available Locales

```bash
locale -a | grep -i utf8
```

---
## 3. Generate a Locale (if not available)

**Debian / Ubuntu:**

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale
```

**Arch Linux:**

```bash
# Uncomment the desired locale in /etc/locale.gen
sudo nano /etc/locale.gen
# Then generate:
sudo locale-gen
```

---
## 4. Set the System-Wide Locale

**Debian / Ubuntu:**

```bash
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
```

Or edit `/etc/default/locale` directly:

```ini
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LANGUAGE=en_US:en
```

**Red Hat / CentOS / Fedora:**

```bash
sudo localectl set-locale LANG=en_US.UTF-8
```

Or edit `/etc/locale.conf`:

```ini
LANG=en_US.UTF-8
```

---
## 5. Set for Current Session Only

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US:en
```

---
## 6. Persist for a User

Add the export lines to your shell profile:

```bash
# For Bash
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
echo 'export LC_ALL=en_US.UTF-8' >> ~/.zshrc
source ~/.zshrc
```

---
## Verification

### Check All Locale Settings

```bash
locale
```

Expected output:

```
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
...
LC_ALL=en_US.UTF-8
```

### Test UTF-8 Encoding

```bash
echo "Hello, 世界! Héllo Wörld! مرحبا" | cat
```

If characters display correctly, UTF-8 is working.

### Check File Encoding

```bash
file -i myfile.txt
# Expected: myfile.txt: text/plain; charset=utf-8
```

---
## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| `locale: Cannot set LC_ALL` | Locale not generated | Run `locale-gen en_US.UTF-8` |
| Garbled characters in terminal | Terminal not set to UTF-8 | Set terminal emulator encoding to UTF-8 |
| SSH session loses locale | SSH not forwarding locale | Add `SendEnv LANG LC_*` to `~/.ssh/config` |
| Python `UnicodeDecodeError` | System locale not UTF-8 | Set `PYTHONIOENCODING=utf-8` |

### Common Environment Variables

| Variable | Purpose |
|---|---|
| `LANG` | Default locale for all categories |
| `LC_ALL` | Overrides all other `LC_*` variables |
| `LC_CTYPE` | Character classification and encoding |
| `LANGUAGE` | Preferred languages (colon-separated fallback list) |

---
## Quick Reference

```bash
# One-liner for current session
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Permanently set system locale (systemd-based systems)
sudo localectl set-locale LANG=en_US.UTF-8

# Debian/Ubuntu permanent set
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
```

---

*UTF-8 encodes over 1.1 million Unicode characters and is backward-compatible with ASCII — making it the universal standard for modern text encoding.*

Sources:
https://claude.ai/share/d8d04f48-6247-4413-83a6-69ee3eb0c4a5

Tags: #linux #guide 