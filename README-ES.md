# Desplegador de Entorno Stealth para OSINT Forense

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
![Compliance: ISO/IEC 27037](https://img.shields.io/badge/Compliance-ISO%2FIEC%2027037-blue.svg)
[![OPSEC: NATO AJP--2.1](https://img.shields.io/badge/OPSEC-NATO%20AJP--2.1-red.svg)](#)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS%20Apple%20Silicon-lightgrey.svg)](#)

[Read in English 🇬🇧](README.md) 

[Arquitectura Técnica](ARCHITECTURE.md) 

[Metodología Operativa](METHODOLOGY.md)

Framework de despliegue automatizado para entornos de investigación de Inteligencia de Fuentes Abiertas (OSINT) de alta seguridad y rigor forense en GNU/Linux y macOS (Apple Silicon & Intel) utilizando **Colima** y **Debian Bookworm**.

Diseñado bajo estricto cumplimiento de estándares internacionales de seguridad operativa (OPSEC) y preservación de evidencia digital.

---

## Visión General de la Arquitectura

```text
Plataforma Host (macOS / Colima VM | GNU/Linux Nativo)
 └── Contenedor Efímero Debian (srv-node-<hex>)
     ├── Enrutamiento: Proxychains4 -> Demonio Tor (Puerto 9050)
     ├── Ejecución: Non-root user 'analyst' (Tmux multiplexer)
     └── Árbol de Evidencia: /home/analyst/evidence/
         ├── raw_data/ (Artefactos descargados + Hashes SHA-256)
         ├── proofs/   (Capturas, cabeceras, metadatos)
         └── logs/     (Sesiones .cast de asciinema y registros .log) 
```

---

## Inicio Rápido

### Prerrequisitos

* **macOS (Apple Silicon / Intel)**
  
  * Requiere **[Homebrew](https://brew.sh/es/)** instalado.
  
  * **Colima** & **Docker CLI**:
    
    ```bash
    brew install colima docker
    colima start
    docker context use colima
    ```
- **GNU/Linux**
  
  - Requiere el motor **Docker Engine** y el servicio activo:
    
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

## Despliegue

1. **Conceder permisos de ejecución al script:**

```
chmod +x osint-stealth-script.sh
```

2. **Ejecutar el despliegue del nodo stealth:**

```
./osint-stealth-script.sh
```

---

## Destrucción y Purga Segura

Destruye instantáneamente el contenedor y eliminar todos los rastros efímeros:

```bash
./osint-stealth-script.sh --purge

./osint-stealth-script.sh -p
```
