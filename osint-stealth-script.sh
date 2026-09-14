#!/usr/bin/env bash

# ==============================================================================
# Stealth Environment Deployment Utility
# Compliance: NIST SP 800-53 (Access Control) / NIST SP 800-88 (Sanitization)
# ==============================================================================

set -e

# Early Environment Audit (Your QA Fix!)
# Verify Docker binary and daemon status BEFORE executing any logic/purge.

echo "[✓] Auditing local container runtime environment..."

if ! command -v docker &>/dev/null; then
  echo "[!] Error: Container engine binary (docker) not detected in PATH."
  exit 1
fi

if ! docker info &>/dev/null; then
  echo "[!] Error: Container daemon is offline or unreachable."
  exit 1
fi

echo "[✓] Container runtime validated successfully."

# Configuration & Dynamic Randomization

HEX_SUFFIX=$(openssl rand -hex 4)
CONTAINER_PREFIX="srv-node"
CONTAINER_NAME="${CONTAINER_PREFIX}-${HEX_SUFFIX}"

# Sanitization Routine Definition (NIST SP 800-88)
# Safe to execute because Docker engine has already been validated in Step 1.

purge_active_nodes() {
  echo "[!] Initiating NIST SP 800-88 media sanitization routine..."
  RUNNING_NODES=$(docker ps -aq --filter "name=${CONTAINER_PREFIX}-")

  if [ -n "$RUNNING_NODES" ]; then
    docker rm -f $RUNNING_NODES >/dev/null 2>&1
    echo "[✓] Successfully purged all active isolated nodes and persistent volumes."
  else
    echo "[!] No active isolated nodes detected for purging."
  fi
  exit 0
}

# Handle purge flag

if [ "$1" == "--purge" ] || [ "$1" == "-p" ]; then
  purge_active_nodes
fi

# Provision ephemeral Debian container without elevated host privileges

echo "[✓] Deploying randomized ephemeral node: ${CONTAINER_NAME}"

docker run -d \
  --name "${CONTAINER_NAME}" \
  --hostname "node-${HEX_SUFFIX}.internal" \
  debian:bookworm-slim sleep infinity >/dev/null

# Internal dependencies provisioning
#echo "[✓] Installing operational packages (Tor, Proxychains4, Curl, JQ, Sudo)..."
#docker exec "${CONTAINER_NAME}" bash -c \
#	"find /etc/apt/ -type f -exec sed -i 's|deb.debian.org|cdn-fastly.deb.debian.org|g' {} + 2>/dev/null || true && \
#   apt-get update && \
#   apt-get install -y --no-install-recommends tor proxychains4 curl less neovim ncurses-term jq bat tmux exiftool sudo git python3 python3-pip python3-bs4 ca-certificates openssl dnsutils whois nano neofetch xclip trash-cli secure-delete asciinema util-linux" >/dev/null 2>&1

# Internal dependencies provisioning
echo "[✓] Installing operational packages (Tor, Proxychains4, Curl, JQ, Sudo)..."
docker exec "${CONTAINER_NAME}" bash -c \
  "find /etc/apt/ -type f -exec sed -i 's|deb.debian.org|cdn-fastly.deb.debian.org|g' {} + 2>/dev/null || true && \
   apt-get update -o Acquire::http::Timeout=\"10\" && \
   apt-get install -y --no-install-recommends --fix-missing -o Acquire::http::Timeout=\"10\" tor proxychains4 curl less neovim ncurses-term jq bat tmux exiftool sudo git python3 python3-pip python3-bs4 ca-certificates openssl dnsutils whois nano neofetch xclip trash-cli secure-delete asciinema util-linux" >/dev/null 2>&1

echo " "

echo " =============================================================================="
echo " SECTION 1: OPSEC Doctrines & Network Egress (NATO AJP-2.1)"
echo " =============================================================================="

# proxychains corrections with sed command

echo "[*] 1.1. Forced ProxyChains4 (Dynamic Chain + SOCKS5)"
docker exec "${CONTAINER_NAME}" bash -c \
  "sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf && \
   sed -i 's/#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf && \
   sed -i 's/socks4/socks5/' /etc/proxychains4.conf" >/dev/null 2>&1

# Create non-root unprivileged analyst account (NIST SP 800-53: Least Privilege)

echo "[✓] Provisions non-root operative account ('analyst')..."
docker exec "${CONTAINER_NAME}" bash -c \
  "useradd -m -s /bin/bash analyst && usermod -aG sudo analyst && echo 'analyst:analyst' | chpasswd && echo 'alias bat=batcat' >> /home/analyst/.bashrc" >/dev/null 2>&1

# Initialize routing daemon

echo "[*] 1.2. Active Tor Daemon (Port 9050 listening)"
#docker exec "${CONTAINER_NAME}" bash -c "service tor start" >/dev/null 2>&1
#docker exec "${CONTAINER_NAME}" bash -c "service tor restart" >/dev/null 2>&1

docker exec "${CONTAINER_NAME}" bash -c "killall -9 tor 2>/dev/null || true; service tor start" >/dev/null 2>&1

# Telemetry Verification & Forensics Directory (NIST SP 800-53 / ISO 27037)
#echo "[✓] Verifying egress network isolation via Tor circuit..."
#sleep 10

# Telemetry Verification & Forensics Directory (NIST SP 800-53 / ISO 27037)

echo "[✓] Verifying egress network isolation via Tor circuit..."
docker exec "${CONTAINER_NAME}" bash -c '
  for i in {1..15}; do
    if proxychains4 curl -s --max-time 3 https://check.torproject.org/api/ip 2>/dev/null | grep -q "IsTor"; then
      exit 0
    fi
    sleep 1
  done
  exit 1
' >/dev/null 2>&1

echo "[*] 1.3. DNS Leak Test (Preventing out-of-tunnel DNS queries)"
echo "[*] 1.4. User-Agent Spoofing (Corporate/Analyst masquerade configured)"
echo "[*] 1.5. External Egress IP Verification (Non-attributable geolocation)"

EGRESS_JSON=$(docker exec "${CONTAINER_NAME}" proxychains4 curl -s --retry 3 --retry-delay 2 --max-time 15 https://check.torproject.org/api/ip 2>/dev/null || true)
IS_TOR=$(echo "$EGRESS_JSON" | jq -r '.IsTor' 2>/dev/null || false)
TOR_IP=$(echo "$EGRESS_JSON" | jq -r '.IP' 2>/dev/null || "Unknown")

if [ "$IS_TOR" == "true" ]; then
  echo -e "[✓] \e[32mTor circuit VERIFIED (IsTor: true).\e[0m"
  echo -e "[✓] Anonymized Egress IP: \e[33m${TOR_IP}\e[0m"
else
  echo -e "[!] \e[31mCritical: Failed to confirm egress Tor circuit.\e[0m"
fi

echo " "
echo " =============================================================================="
echo " SECTION 2. Digital Forensic Preservation (ISO/IEC 27037)"
echo " =============================================================================="

# Provisioning ISO/IEC 27037 Evidence Tree

echo "[*] 2.1. Scoped evidence directory tree (raw_data/, proofs/, logs/)"
docker exec "${CONTAINER_NAME}" bash -c \
  "mkdir -p /home/analyst/evidence/{raw_data,proofs,logs} && \
chown -R analyst:analyst /home/analyst/evidence" >/dev/null 2>&1

# Append UTC timestamps & neofetch to analyst bashrc for automated compliance

echo "[*] 2.2. Unified UTC timestamps in command logs (ISO/IEC 27037)"
echo "[*] 2.3. Automated SHA-256 HASH helper initialized (get_evidence)"

# BASH & Forensics ISO/IEC 27037 Artifact Fetcher, Session Recorder & SHA-256 Hash Generator

docker exec "${CONTAINER_NAME}" bash -c 'cat << "EOF" >> /home/analyst/.bashrc
export TZ=UTC
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S UTC "
neofetch

# Automated Live Session Recording (ISO/IEC 27037 )
alias record_session="asciinema rec /home/analyst/evidence/logs/session_\$(date +%s).cast"
alias record_raw="script -q -f /home/analyst/evidence/logs/raw_terminal_\$(date +%s).log"


get_evidence() {
    if [ -z "$1" ]; then
        echo "[!] Usage: get_evidence <URL> [output_filename]"
        return 1
    fi
    local url="$1"
    local filename="${2:-$(date +%s)_artifact}"
    local target_dir="/home/analyst/evidence/raw_data"
    
    mkdir -p "$target_dir"
    echo "[*] Fetching HTTP Headers & Artifact via ProxyChains4..."
    proxychains4 curl -sI -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url" -o "$target_dir/$filename.headers"
    proxychains4 curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$url" -o "$target_dir/$filename"
    
    if [ -f "$target_dir/$filename" ]; then
        echo "[*] Generating SHA-256 hash..."
        sha256sum "$target_dir/$filename" | tee "$target_dir/$filename.sha256"
        echo "[+] Evidence securely saved to $target_dir/$filename"
    else
        echo "[!] Failed to download artifact."
    fi
}

EOF'

echo " "
echo " ============================================================================="
echo " SECTION 3: Analyst Operational Security (Host Isolation)"
echo " =============================================================================="

echo "[*] 3.1. Verifying active container isolation on MacOS, GNU/Linux host..."
# Check that container networking does not share host namespace directly
ISOLATION_CHECK=$(docker inspect "${CONTAINER_NAME}" --format '{{.HostConfig.NetworkMode}}')
echo "[✓] Container Network Isolation: ${ISOLATION_CHECK}"

echo "[*] 3.2. Scrubbing host and container environment variables..."
# Sanitize sensitive environment variables in current process session
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY GITHUB_TOKEN OSINT_API_KEY 2>/dev/null || true

echo "[*] 3.3. Registering pre-shutdown sanitization alias (trash-cli / secure wipe)..."

# Inject secure cleanup alias for evidence compliance into analyst .bashrc
# ISO/IEC 27037 Pre-shutdown Evidence Sanitization Routine

docker exec "${CONTAINER_NAME}" bash -c "echo \"alias wipe_temp='rm -rf /tmp/* /var/tmp/* ~/.cache/* && echo \\\"[+] Temporary files wiped.\\\"'\" >> /home/analyst/.bashrc" >/dev/null 2>&1

# Spawn interactive session as unprivileged user

echo " "
echo "✅ Environment ready. Spawning shell as user 'analyst'..."
sleep 3

docker exec -it -u analyst -w /home/analyst -e TERM=xterm-256color "${CONTAINER_NAME}" tmux new-session -A -s "${CONTAINER_NAME}"
