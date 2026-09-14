# Forensic Stealth OSINT Environment Deployer

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
![Compliance: ISO/IEC 27037](https://img.shields.io/badge/Compliance-ISO%2FIEC%2027037-blue.svg)
[![OPSEC: NATO AJP--2.1](https://img.shields.io/badge/OPSEC-NATO%20AJP--2.1-red.svg)](#)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%20Apple%20Silicon-lightgrey.svg)](#)

[Leer en Español 🇻🇪](README-ES.md) 

 [Technical Architecture](ARCHITECTURE.md) 

 [Operational Methodology](METHODOLOGY.md)

Automated deployment framework for high-security, forensically sound Open Source Intelligence (OSINT) research environments on GNU/Linux and macOS (Apple Intel & Silicon) using **Colima** and **Debian Bookworm**.

Designed in strict compliance with international operational security (OPSEC) and digital evidence preservation standards.


<video src="https://github.com/user-attachments/assets/873a3561-01d8-4674-bddd-19db3e8eb923" controls width="100%"></video>
---

## Architecture Overview

```text
Host Platform (macOS / Colima VM | GNU/Linux Native)
 └── Ephemeral Debian Container (srv-node-<hex>)
     ├── Routing: Proxychains4 -> Tor Daemon (Port 9050)
     ├── Execution: Non-root user 'analyst' (Tmux multiplexer)
     └── Evidence Tree: /home/analyst/evidence/
         ├── raw_data/ (Downloaded artifacts + SHA-256 hashes)
         ├── proofs/   (Captures, headers, metadata)
         └── logs/     (asciinema .cast sessions & script .log text records) 
```

---

## Quick Start

### Prerequisites

* **macOS (Apple Silicon / Intel)**
  
  * with **[Homebrew](https://brew.sh/)** installed.
  
  * **Colima** & **Docker CLI**:
    
    ```bash
    brew install colima docker
    colima start
    docker context use colima
    ```
- **GNU/Linux**
  
  - Docker Native CLI:
    
    ```bash
    # Debian / Parrot OS
        sudo apt update && sudo apt install -y docker.io
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER
    
    # Arch Linux
        sudo pacman -S docker
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER    
    ```

---

## Deployment

1. **Grant execution permissions to the script:**

```
chmod +x osint-stealth-script.sh
```

2. **Deploy the stealth node:**

```
./osint-stealth-script.sh
```

---

## Destruction & Secure Purge

Destroy the container and wipe all ephemeral traces: 

```
./osint-stealth-script.sh --purge

./osint-stealth-script.sh -p
```
