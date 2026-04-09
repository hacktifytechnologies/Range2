#!/bin/bash
# ============================================================
# Operation ShadowGrid — M4: nova-scheduler Setup
# Challenge: World-Writable Cron Script Hijacking
# ============================================================
set -e
echo "[*] Setting up M4 - nova-scheduler (Cron Hijacking Challenge)"

# ---------- Install packages ----------
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server cron 2>/dev/null

# ---------- Create backup user ----------
if ! id "backup" &>/dev/null; then
    useradd -m -s /bin/bash backup
fi
echo "backup:Backups3cure" | chpasswd

# ---------- Create world-writable cron script ----------
mkdir -p /opt/scripts

cat > /opt/scripts/maintenance.sh << 'CRONSCRIPT'
#!/bin/bash
# NovaTech - Scheduled Maintenance Script
# Runs every minute as root (debug mode - ticket #5530)
# TODO: Change to daily once confirmed stable

LOGFILE="/var/log/maintenance.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Maintenance check OK" >> "$LOGFILE"

# Cleanup temp files older than 7 days
find /tmp -mtime +7 -delete 2>/dev/null

CRONSCRIPT

# INTENTIONAL MISCONFIGURATION: world-writable (debug session leftover)
chmod 777 /opt/scripts/maintenance.sh
chown root:root /opt/scripts/maintenance.sh

# ---------- Add cron job ----------
# Add to /etc/crontab (runs as root)
grep -qF "maintenance.sh" /etc/crontab ||     echo "* * * * * root /opt/scripts/maintenance.sh" >> /etc/crontab

# ---------- Generate flag ----------
FLAG="FLAG{$(openssl rand -hex 8)_cron_hijack_root}"
echo "$FLAG" > /root/flag4.txt
chmod 600 /root/flag4.txt

# Credentials for M5
cat > /root/secrets.txt << 'EOF'
[NovaTech Operations - Internal Notes]
M5 nova-archive access:
  SSH User: archivist
  SSH Pass: Arch1v1st99
  Purpose: Document archive management
EOF
chmod 600 /root/secrets.txt

# ---------- SSH config ----------
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd
systemctl enable cron

# Create maintenance log
touch /var/log/maintenance.log
chmod 644 /var/log/maintenance.log

# ---------- Record flag ----------
echo "========================================" >> /root/ctf_setup_log.txt
echo "M4 (nova-scheduler) Flag: $FLAG" >> /root/ctf_setup_log.txt
echo "Setup completed: $(date)" >> /root/ctf_setup_log.txt

echo "[✓] M4 setup complete. Flag recorded in /root/ctf_setup_log.txt"
