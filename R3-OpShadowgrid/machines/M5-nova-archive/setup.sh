#!/bin/bash
# ============================================================
# Operation ShadowGrid — M5: nova-archive Setup
# Challenge: SUID Binary with Path Traversal (strstr bypass)
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[*] Setting up M5 - nova-archive (SUID Binary Challenge)"

# ---------- Install packages ----------
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server gcc build-essential 2>/dev/null

# ---------- Create archivist user ----------
if ! id "archivist" &>/dev/null; then
    useradd -m -s /bin/bash archivist
fi
echo "archivist:Arch1v1st99" | chpasswd

# ---------- Create archive directory with sample files ----------
mkdir -p /opt/archive

cat > /opt/archive/quarterly_report.txt << 'EOF'
[NovaTech Industries - Q3 2024 Report]
Revenue: $14.2M (+8% YoY)
Infrastructure spend: $2.1M
Headcount: 187 employees
Status: On track for year-end targets.
EOF

cat > /opt/archive/system_status.txt << 'EOF'
[NovaTech System Status - October 2024]
All core services operational.
Scheduled maintenance window: Nov 2, 02:00-04:00 UTC.
EOF

chmod 755 /opt/archive
chmod 644 /opt/archive/*.txt

# ---------- Compile SUID binary ----------
gcc -o /usr/local/bin/safereader "$SCRIPT_DIR/safereader.c" -Wall 2>/dev/null ||     gcc -o /usr/local/bin/safereader "$SCRIPT_DIR/safereader.c"

chown root:root /usr/local/bin/safereader
chmod 4755 /usr/local/bin/safereader   # SUID root + world-executable

# ---------- Generate final flag ----------
FLAG="FLAG{$(openssl rand -hex 8)_suid_traversal_final}"
echo "$FLAG" > /root/flag5.txt
chmod 600 /root/flag5.txt

# Give archivist a hint about the tool
cat > /home/archivist/README.txt << 'EOF'
[NovaTech - Archive Server]
Welcome to the document archive server.

A utility called 'safereader' is available for reading archived documents.
It has elevated privileges to access all archive files.

Usage: safereader /opt/archive/<filename>
Example: safereader /opt/archive/quarterly_report.txt

For issues, contact: archive-admin@novatech.internal
EOF
chown archivist:archivist /home/archivist/README.txt

# ---------- SSH config ----------
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd

# ---------- Record flag ----------
echo "========================================" >> /root/ctf_setup_log.txt
echo "M5 (nova-archive) Flag: $FLAG" >> /root/ctf_setup_log.txt
echo "FINAL CHALLENGE - Setup completed: $(date)" >> /root/ctf_setup_log.txt

echo "[✓] M5 setup complete. Flag recorded in /root/ctf_setup_log.txt"
