#!/bin/bash
# ============================================================
# Operation ShadowGrid — M2: nova-ftpvault Setup
# Challenge: Anonymous FTP — Credential Exposure
# ============================================================
set -e
echo "[*] Setting up M2 - nova-ftpvault (Anonymous FTP Challenge)"

# ---------- Install vsftpd ----------
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y vsftpd 2>/dev/null

# ---------- Create FTP directory and files ----------
mkdir -p /srv/ftp

# Staff handover note with credentials for M3
cat > /srv/ftp/staff_handover.txt << 'EOF'
[NovaTech IT - Staff Handover Note]
From: j.morrison@novatech.internal
To:   it-team@novatech.internal
Date: 2024-09-28

Team,

Leaving these creds for the gateway server so the new hire can log in.
Please update after I'm off-boarded (IT ticket #4421).

SSH Gateway (nova-gateway): 
  User: devops
  Pass: N0vaTech@24

The sudo config was left as-is for now — edit access to vim needs to stay
for config file editing.

- James
EOF

# Generate unique flag
FLAG="FLAG{$(openssl rand -hex 8)_anon_ftp_creds_exposed}"
echo "$FLAG" > /srv/ftp/flag2.txt

cat > /srv/ftp/README.txt << 'EOF'
[NovaTech File Share - IT Operations]
This server hosts temporary shared files for the ops team.
For questions, contact: storage-team@novatech.internal
EOF

chmod 755 /srv/ftp
chmod 644 /srv/ftp/*.txt

# ---------- Configure vsftpd ----------
cat > /etc/vsftpd.conf << 'VSFTPD'
# vsftpd configuration - NovaTech File Share
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=NO
anon_root=/srv/ftp
anon_upload_enable=NO
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
xferlog_file=/var/log/vsftpd.log
connect_from_port_20=YES
idle_session_timeout=300
data_connection_timeout=120
ftpd_banner=NovaTech Industries File Share v2.1
# Note: anonymous_enable=YES was "temporary" during migration (ticket #3812)
VSFTPD

systemctl restart vsftpd
systemctl enable vsftpd

# ---------- Record flag ----------
echo "========================================" >> /root/ctf_setup_log.txt
echo "M2 (nova-ftpvault) Flag: $FLAG" >> /root/ctf_setup_log.txt
echo "Setup completed: $(date)" >> /root/ctf_setup_log.txt

echo "[✓] M2 setup complete. Flag recorded in /root/ctf_setup_log.txt"
