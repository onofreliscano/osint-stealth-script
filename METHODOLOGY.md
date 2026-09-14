[Versión en Español 🇻🇪](#versión-en-español-🇻🇪) 
[English Version 🇺🇸](#english-version-🇺🇸)

---

# Versión en Español 🇻🇪

# Metodología Operativa y Filosofía de Arquitectura (OSINT Forense / [Lazarus](https://www.lazarus.com.ve/))

## I. Fundamentación Jurídica y Admisibilidad de la Evidencia (Sana Crítica)

En la informática forense y el derecho procesal (Art. 22 del COPP), la validez de un hallazgo depende de la **transparencia, auditabilidad e integridad**.

El desarrollo del script `osint-stealth-script.sh` articula la agilidad de la consola (terminal) con el rigor probatorio que exige un proceso judicial:

- **Automatización vs. Manejo Manual:** Elimina el error humano, la telemetría de navegadores GUI y cookies, generando evidencia inmutable.

- **Auditabilidad Extremo a Extremo:** Permite a jueces, fiscales o auditores verificar que la recolección proviene de fuentes públicas sin vulnerar accesos no autorizados.

---

## II. Fundamentos Normativos y Pilares Operativos del Script (`osint-stealth-script.sh`)

La arquitectura del script se sostiene sobre tres pilares normativos internacionales de ciberseguridad y forense digital:

### A. Preservación Digital Forense (ISO/IEC 27037)

Para garantizar la cadena de custodia y asegurar que los hallazgos en terminal no sean desestimados en un tribunal:

- **Estructura de Evidencia Delimitada:** Se aprovisiona automáticamente un árbol de trabajo aislado en `/home/analyst/evidence/`:
  - `raw_data/`: Almacena el código fuente o artefacto original junto con sus cabeceras HTTP completas de origen (`.headers`).
  - `proofs/`: Guarda capturas, metadatos (`exiftool`) y volcados de contexto.
  - `logs/`: Registra la sesión continua del analista en formatos `.cast` (`asciinema`) y `.log` (`script`).
- **Integridad Criptográfica (SHA-256):** La función inyectada `get_evidence` descarga la evidencia, extrae las cabeceras HTTP de origen y calcula simultáneamente el hash **SHA-256**, vinculando el artefacto a una marca temporal unificada en formato **UTC**.
- **Auditabilidad y Replicabilidad de Extremo a Extremo:** Mediante los alias de grabación continua (`record_session` y `record_raw`), la contraparte judicial puede auditar cada comando ejecutado en la consola, descartando la siembra o alteración arbitraria de pruebas.

### B. Seguridad Operativa y Anonimato No Atribuible (NATO AJP-2.1 / NIST SP 800-53)

Garantiza la protección de la infraestructura del investigador y evita la contaminación de datos:

- **Principio de Mínimo Privilegio y Aislamiento del Host (NIST SP 800-53 - Access Control):** 
  - El entorno no se ejecuta como `root`. El script crea y conmuta automáticamente la sesión al usuario sin privilegios `analyst` dentro del contenedor `srv-node-<hex>`.
  - **Limpieza de Entorno Host:** Se desvinculan automáticamente (`unset`) las variables de entorno de la máquina personal del investigador (como llaves de API o credenciales de AWS/GitHub), evitando su exposición accidental.
- **Doctrinas de Salida de Red y Anonimización (NATO AJP-2.1):**
  - **ProxyChains4 + Tor Daemon:** Enrutamiento forzado mediante cadena dinámica (`dynamic_chain`) sobre el demonio local de Tor (`SOCKS5` en puerto 9050).
  - **Prevención de Fugas DNS (DNS Leak Test):** Resolución de nombres forzada dentro del túnel cifrado.
  - **User-Agent Spoofing:** Mascarada de navegador corporativo preconfigurada en las peticiones HTTP.
  - **Verificación de IP de Salida:** Validación automatizada previa al despliegue interactivo (`https://check.torproject.org/api/ip`) exigiendo `IsTor: true`.

### C. Higiene Operativa y Sanitización Segura (NIST SP 800-88 Rev. 1)

- **Sanitización mediante Borrado Lógico (*Clear*)**:
  - Dentro de la sesión, el analista cuenta con rutinas locales de limpieza efímera (`wipe_temp` y `trash-cli`).
  - Ante el cierre de la investigación, la bandera `--purge` (o `-p`) ejecuta una rutina de sanitización bajo la norma **NIST SP 800-88**, destruyendo instantáneamente el nodo aislado `srv-node-<hex>` y sus volúmenes asociados para impedir la fuga de información o la contaminación cruzada entre casos.

---

## III. Matriz de Mapeo: Requisito Jurídico vs. Implementación en Script

| Criterio de Sana Crítica / OPSEC | Riesgo en Navegación Web Manual                                                                | Solución Automatizada en Script                                                                                                                       |
|:-------------------------------- |:---------------------------------------------------------------------------------------------- |:----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Integridad de Evidencia**      | Modificación manual de archivos o descarga incompleta.                                         | Función get_evidence con descarga de artefacto, extracción de cabeceras HTTP (.headers) y cálculo de Hash SHA-256.                                    |
| **Cadena de Custodia**           | Marcas de tiempo locales inconsistentes o falta de registro del momento exacto de recolección. | Variables de entorno TZ=UTC e HISTTIMEFORMAT forzadas en .bashrc para trazabilidad temporal unificada.                                                |
| **Auditabilidad**                | Capturas de pantalla simples fáciles de falsificar.                                            | Grabación continua de sesión en terminal (asciinema rec / script) y registro completo de comandos en formatos .cast y .log.                           |
| **Fuga de Identidad (OPSEC)**    | Rastreadores web, cookies y telemetría de navegadores GUI.                                     | Enrutamiento Tor forzado por `proxychains4`(cadena dinámica en SOCKS5), prueba anti-fugas DNS y mascarada User-Agent.                                 |
| **Contaminación del Host**       | Residuos temporales guardados en la máquina personal.                                          | Aislamiento en contenedor efímero (analyst), desvinculación de credenciales (unset) y sanitización lógica bajo norma NIST SP 800-88 Rev. 1 (--purge). |

## IV. Consideraciones de OPSEC Local: Gestión de Metadatos del Host (`neofetch`)

- **Aislamiento Externo (Público):** Los servidores web investigados **solo** registran las IPs de los nodos de salida de Tor y los *User-Agents* falsificados. La salida visual de `neofetch` jamás se transmite a través de la red.
- **Protección de Identidad Interna (Informes):** `neofetch` despliega localmente metadatos de la máquina física del investigador (por ejemplo: `Host`, `CPU`, núcleo/kernel). 
- Al incluir capturas de pantalla de la terminal en informes forenses oficiales, los analistas deben filtrar o suprimir estos banners para evitar la fuga de información sobre la infraestructura privada del investigador.

--- 

 --- 

# English Version 🇺🇸

# Operational Methodology & Architecture Philosophy (Forensic OSINT / [Lazarus](https://www.lazarus.com.ve/))

## I. Legal Foundations & Evidence Admissibility *(Sound Criticism)*

In digital forensics and procedural law, the validity of a finding depends on its **transparency, auditability, and integrity**, while guaranteeing the **non-attributability of the investigator's infrastructure**.

The development of `osint-stealth-script.sh` articulates CLI agility with the evidentiary rigor required in judicial proceedings: 

- **Standardization vs. Manual Handling:** Eliminates human error, GUI browser telemetry, and tracking cookies, generating immutable and repeatable evidence. 

- **End-to-End Auditability:** Enables judges, prosecutors, or auditors to verify that collection originates exclusively from open, public sources without unauthorized access or privacy violations.

---

## II. Standards Framework & Operational Pillars of the Script (`osint-stealth-script.sh`)

The script's architecture is built upon three international cybersecurity and digital forensics standards:

### A. Digital Forensic Evidence Preservation (ISO/IEC 27037)

To ensure the chain of custody and guarantee that CLI findings are not dismissed in court:

- **Delimited Evidence Structure:** Automatically provisions an isolated, compartmentalized workspace at `/home/analyst/evidence/`: 
  - `raw_data/`: Stores original source code/artifacts along with full origin HTTP response headers (`.headers`). 
  - `proofs/`: Stores captures, metadata (`exiftool`), and contextual dumps.
  - `logs/`: Records continuous analyst sessions in `.cast` (`asciinema`) and `.log` (`script`) formats. 
- **Cryptographic Integrity (SHA-256):** The injected `get_evidence` function fetches evidence, extracts origin HTTP headers, and simultaneously computes the **SHA-256** hash, binding the artifact to a unified **UTC** timestamp. 
- **End-to-End Auditability & Replicability:** Through continuous recording aliases (`record_session` and `record_raw`), judicial auditors can inspect every command executed in the console, ruling out arbitrary evidence tampering.

### B. Operational Security & Non-Attributable Anonymity (NATO AJP-2.1 / NIST SP 800-53)

Guarantees investigator infrastructure protection and prevents data contamination: 

- **Least Privilege & Host Isolation (NIST SP 800-53 - Access Control):**
  
  - **Environment does not run as `root`**. The script creates and automatically switches the session to the unprivileged `analyst` user inside container `srv-node-<hex>`. 
  
  - **Host Environment Scrubbing:** Automatically unsets (`unset`) host environment variables (such as API keys or AWS/GitHub credentials), preventing accidental exposure. 

- **Egress Network Doctrines & Anonymization (NATO AJP-2.1):** 
  
  - **ProxyChains4 + Tor Daemon:** Enforced routing via dynamic chain (`dynamic_chain`) over local Tor daemon (`SOCKS5` on port 9050). 
  
  - **DNS Leak Prevention:** Name resolution forced inside the encrypted tunnel. 
  
  - **User-Agent Spoofing:** Pre-configured corporate browser masquerade on HTTP requests. 
  
  - **External IP Verification:** Automated pre-session check (`https://check.torproject.org/api/ip`) enforcing `IsTor: true`.

### C. Operational Hygiene & Secure Sanitization (NIST SP 800-88 Rev. 1)

-  **Sanitization via Logical Erasure (*Clear*):**
  
  - In-session local ephemeral cleanup via `wipe_temp` and `trash-cli`. 
  
  - Upon case closure, the `--purge` (or `-p`) flag executes a **NIST SP 800-88 Rev. 1 (Level *Clear*)** sanitization routine, immediately destroying the isolated `srv-node-<hex>` container and its transient volumes to prevent data leaks or cross-investigation contamination.

---

### III. Mapping Matrix: Legal Requirement vs. Script Implementation

| Judicial / OPSEC Criteria | Manual Web Browsing Risk                                                                 | Automated CLI Solution                                                                                                                           |
| ------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Evidence Integrity**    | Manual file alteration, incomplete downloads, or source code tampering.                  | `get_evidence` function with artifact fetch, HTTP header extraction (`.headers`), and automatic SHA-256 hashing.                                 |
| **Chain of Custody**      | Inconsistent local timestamps or lack of exact collection time records                   | Forced `TZ=UTC` and `HISTTIMEFORMAT` environment variables in `.bashrc` for unified temporal traceability.                                       |
| **Judicial Auditability** | Simple screenshots or isolated images that are easily manipulated.                       | Continuous terminal recording (`asciinema rec` / `script`) and full command logs in `.cast` and `.log` formats.                                  |
| **Identity Leak (OPSEC)** | Web trackers, cookies, digital fingerprints, and GUI browser telemetry.                  | Tor routing forced by `proxychains4` (dynamic chain SOCKS5), anti-DNS leak check, and *User-Agent* spoofing.                                     |
| **Host Contamination**    | Transient residual files, tracking cookies, and credentials exposed on physical machine. | Ephemeral container isolation (`analyst`), credential unsetting (`unset`), and logical sanitization under **NIST SP 800-88 Rev. 1** (`--purge`). |

---

### IV. Local OPSEC Considerations: Host Metadata Management (`neofetch`)

- **External Isolation (Public):** Investigated web servers **only** log Tor exit node IPs and fake *User-Agents*. Visual output from `neofetch` is never transmitted across the network. 

- **Internal Identity Protection (Reports):** `neofetch` locally displays metadata from the investigator's physical machine (e.g., `Host`, `CPU`, kernel). 

- When including terminal screenshots in official forensic reports, analysts must filter or suppress these banners to avoid leaking private investigator infrastructure.


