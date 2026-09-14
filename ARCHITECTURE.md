[Versión en Español 🇻🇪](#versión-en-español-🇻🇪) 

[English Version 🇺🇸](#english-version-🇺🇸)

---

# Versión en Español 🇻🇪

# Arquitectura Técnica (OSINT Forense / Lazarus)

Este documento describe la arquitectura de software y el modelo de aislamiento de red implementados en `osint-stealth-script.sh` para desplegar entornos efímeros de investigación pericial.

---

## 1. Topología del Entorno y Modelo de Aislamiento

El script ejecuta un despliegue desacoplado que separa la máquina física del investigador del entorno donde se interactúa con los objetivos tácticos.

```text
 Plataforma Host (macOS via Colima VM | GNU/Linux Nativo)
                             │
                             ▼ 
        [Aislamiento de Procesos & Desvinculación de Entorno]
 ┌─────────────────────────────────────────────────────────────┐
 │ Contenedor Docker Efímero (debian:bookworm-slim)            │
 │ Nombre Dinámico: srv-node-<hex_random>                      │
 │                                                             │
 │  ┌───────────────────────────────────────────────────────┐  │
 │  │ Usuario Operativo Sin Privilegios: analyst            │  │
 │  │ Multiplexor de Terminal: Tmux (Garantiza Persistencia)│
 │  └───────────────────────────────────────────────────────┘  │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼ 
                 [Egresos de Red Forzados]
 ┌─────────────────────────────────────────────────────────────┐
 │ Capa de Red Anonimizada (NATO AJP-2.1)                      │
 │  ├── Enrutamiento: ProxyChains4 -> dynamic_chain            │
 │  ├── Túnel Local: Demonio Tor (SOCKS5 / Puerto 9050)        │
 │  └── Resolución: DNS Cifrado dentro del Circuito            │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
                    Internet Pública (Target)
```

---

## 2. Flujo Logístico de Ejecución (Pipeline del Script)

El ciclo de vida del entorno se gestiona a través de 6 fases secuenciales automatizadas:

1. **Auditoría Previa del Entorno:** Verificación e inspección del estado del motor Docker antes de instanciar recursos.
2. **Virtualización Efímera:** Creación del nodo basado en `debian:bookworm-slim` con sufijos hexadecimales aleatorios (`openssl rand -hex 4`) para romper patrones de firmas estáticas en el host.
3. **Aprovisionamiento Compartimentado:** Instalación sin interacción gráfica (`--no-install-recommends`) de herramientas de auditoría pericial (`exiftool`, `asciinema`, `proxychains4`, `tor`).
4. **Endurecimiento del Host (Hardening):** Remoción completa (`unset`) de variables críticas del analista (AWS, GitHub, APIs) en el subproceso actual para evitar filtraciones de credenciales por fugas de contexto.
5. **Verificación Operativa (Gates de Red):** Consulta automatizada a la API oficial de Tor (`https://torproject.org`) exigiendo un estado binario estricto de `IsTor: true` antes de otorgar acceso a la consola.
6. **Interrupción y Sanitización (NIST SP 800-88):** Al invocar la bandera `--purge` (o `-p`), se destruye de manera lógica el contenedor y sus volúmenes asociados, impidiendo remanentes forenses en la máquina física.

---

## 3. Gestión y Almacenamiento de Evidencia (ISO/IEC 27037)

El contenedor aprovisiona un árbol de directorios estructurado dentro de la ruta del usuario no privilegiado (`/home/analyst/evidence/`), asegurando el principio de compartimentación:

* **`/raw_data/`**: Contenedor de artefactos puros descargados y capturas de cabeceras HTTP de origen (`.headers`). Almacena los hashes SHA-256 generados en tiempo real por la función integrada `get_evidence`.
* **`/proofs/`**: Repositorio dedicado para metadatos extraídos por herramientas forenses de bajo nivel como `exiftool`.
* **`/logs/`**: Registro estricto de la sesión pericial en formatos de reproducción de terminal (`.cast` vía `asciinema`) y bitácoras de texto plano (`.log` vía `script`), listos para ser presentados ante un tribunal bajo los criterios del Artículo 22 del COPP.

---

# English Version 🇺🇸

# Technical Architecture (Forensic OSINT / Lazarus)

This document details the software architecture and network isolation model implemented in `osint-stealth-script.sh` to deploy ephemeral environments for digital forensic investigations.

---

## 1. Environment Topology & Isolation Model

The script executes a decoupled deployment that isolates the investigator's physical host machine from the environment interacting with tactical OSINT targets.



```
    Host Platform (macOS via Colima VM | GNU/Linux Native)
                             │
                             ▼ 
       [Process Isolation & Environment Decoupling]
 ┌─────────────────────────────────────────────────────────────┐
 │ Ephemeral Docker Container (debian:bookworm-slim)           │
 │ Dynamic Name: srv-node-<hex_random>                         │
 │                                                             │
 │  ┌───────────────────────────────────────────────────────┐  │
 │  │ Unprivileged Operative User: analyst                  │  │
 │  │ Terminal Multiplexer: Tmux (Ensures Persistence)      │  │
 │  └───────────────────────────────────────────────────────┘  │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼ 
                 [Forced Network Egress]
 ┌─────────────────────────────────────────────────────────────┐
 │ Anonymized Network Layer (NATO AJP-2.1)                     │
 │  ├── Routing: ProxyChains4 -> dynamic_chain                 │
 │  ├── Local Tunnel: Tor Daemon (SOCKS5 / Port 9050)          │
 │  └── Resolution: Encrypted DNS inside Circuit               │
 └──────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
                    Public Internet (Target)
```

 ---

---

## 2. Execution Logistics Pipeline (Script Pipeline)

The lifecycle of the stealth node is managed through 6 automated sequential phases:

1. **Pre-Environment Audit:** Verification and health check of the local Docker container engine before instantiating resources.

2. **Ephemeral Virtualization:** Node creation based on `debian:bookworm-slim` using randomized hexadecimal suffixes (`openssl rand -hex 4`) to eliminate static signature patterns on the host.

3. **Compartmentalized Provisioning:** Headless, non-interactive installation (`--no-install-recommends`) of forensic audit tools (`exiftool`, `asciinema`, `proxychains4`, `tor`).

4. **Host Hardening:** Complete removal (`unset`) of critical analyst host environment variables (AWS, GitHub, API keys) in the current subprocess to prevent credential leaks via context leakage.

5. **Operational Verification (Network Gates):** Automated query to Tor's official API (`https://check.torproject.org/api/ip`) enforcing a strict binary state of `IsTor: true` before opening interactive shell access.

6. **Interruption & Sanitization (NIST SP 800-88):** Upon invoking the `--purge` (or `-p`) flag, the container and its transient volumes are logically purged, preventing forensic remnants on the physical host machine.

---

## 3. Evidence Storage & Management (ISO/IEC 27037)

The container provisions a structured directory tree within the unprivileged user's workspace (`/home/analyst/evidence/`), enforcing strict compartmentalization principles:

- **`/raw_data/`**: Repository for uncompressed downloaded artifacts and full origin HTTP response headers (`.headers`). Stores real-time SHA-256 hashes generated by the built-in `get_evidence` function.

- **`/proofs/`**: Dedicated directory for metadata extracted by low-level forensic utilities like `exiftool`.

- **`/logs/`**: Rigorous record of the forensic session in terminal replay formats (`.cast` via `asciinema`) and plain text session logs (`.log` via `script`), auditable and court-ready under international procedural standards.


